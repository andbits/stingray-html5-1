
local Window = stingray.Window;
local Application = stingray.Application;
local World = stingray.World;
local WebView = stingray.WebView;

local web_page_url = "http://www.google.com"
local web_view_material_resource_name = "html5_resources/web_view_2d"

Html5ExampleHudViewport = class(Html5ExampleHudViewport)

function Html5ExampleHudViewport:init(id, editor, window)
    self._id = id
    self._editor = editor
    self._window = window

    self._world = Application.new_world(stingray.Application.DISABLE_APEX_CLOTH)
    self._viewport = Application.create_viewport(self._world, "default")
    self._gui = World.create_screen_gui(self._world, "immediate")
    self._light = self._editor:create_preview_light(self._world)
    self._shading_environment = World.create_shading_environment(self._world)
    self._editor_camera = EditorCamera.create_viewport_editor_camera(self._id, self._world, {"QuakeStyleMouseLook", "MayaStylePan"})
    self._camera = self._editor_camera._camera
end

function Html5ExampleHudViewport:shutdown()
    WebView.destroy(self._web_view)
    World.destroy_unit(self._world, self._light)
    Application.destroy_viewport(self._world, self._viewport)
    World.destroy_shading_environment(self._world, self._shading_environment)
    Application.release_world(self._world)
    Window.close(self._window)

    self._web_view = nil
    self._viewport = nil
    self._window = nil
end

function Html5ExampleHudViewport:update(editor_viewport, dt)
    WebView.update(self._web_view, dt)
    World.update(self._world, dt)
end

function Html5ExampleHudViewport:render(editor_viewport, lines, lines_no_z)
    -- Render HTML4 HUD
    local maxw, maxh = Gui.resolution(self._viewport, self._window)
    WebView.render(self._web_view)
    Gui.bitmap(self._gui, web_view_material_resource_name, Vector2(0, 0), Vector2(maxw, maxh))

    -- Render viewport content
    Application.render_world(self._world, self._editor_camera:camera(), self._viewport, self._shading_environment, self._window)
end

function Html5ExampleHudViewport:world() return self._world end
function Html5ExampleHudViewport:editor_camera() return self._editor_camera end
function Html5ExampleHudViewport:shading_environment() return self._shading_environment end
function Html5ExampleHudViewport:is_dirty() return true end
function Html5ExampleHudViewport:is_accepting_drag_and_drop() return false end
function Html5ExampleHudViewport:selected_units() return {} end

local run = function ()
    local viewport_id = "67F13D18-D573-4CCE-BA47-EC571AAA4F54"

    -- Destroy preview viewport if any.
    local viewport = Editor:viewport(viewport_id)
    if viewport then
        Editor:destroy_viewport(viewport_id)
    end

    -- Create new viewport to host the HTML5 example
    viewport = Editor:create_viewport(viewport_id, "Html5ExampleHudViewport", nil, {
        visible = true,
        width = 1280,
        height = 720,
        title = "HTML5 HUD"
    })

    Window.set_show_cursor(viewport._window, true, false)
    Window.set_clip_cursor(viewport._window, false)

    -- Create the HTML5 web view that will be the window viewport head-up display.
    local web_view_material = Gui.material(viewport._behavior._gui, web_view_material_resource_name)
    viewport._behavior._web_view = WebView.create(web_page_url, viewport._window, web_view_material)

    return "Loaded web view "..web_page_url
end

-- Override editor viewport creator to fill missing window parametrization
-- TODO: Port this to core repo
function Editor:create_viewport(id, behavior_class, parent_handle, options)
	local constructor = _G[behavior_class]
	assert(constructor ~= nil, "Tried creating viewport, but viewport behavior class could not be found.")

	-- Create the viewport default window.
	local window = nil
	if Window then
		if parent_handle then
			window = Window.open{
				parent = parent_handle,
				explicit_resize = true,
				pass_key_events_to_parent = true,
				layered = true,
				title = behavior_class,
				visible = false
			}
		elseif options then
			window = Window.open(options)
		else
			window = Window.open{ visible = false, explicit_resize = true, title = behavior_class }
		end
	end

	assert(self._viewports[id] == nil, "Trying to create already existing viewport.")
	local behavior = constructor(id, self, window)
	local viewport = EditorViewport(id, behavior, window)
	self._viewports[id] = viewport

	if Window then
		Application.console_send{ type = "viewport_handle", id = id, handle = Window.id(window) }
	end

	return viewport
end

return run
