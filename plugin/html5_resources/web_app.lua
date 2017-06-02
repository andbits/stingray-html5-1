-- HTML5 Web App bootstrapper
-- The main page to be loaded is defined in settings.ini

local web_app

local test_events = false

local app_settings = stingray.Application.settings() or {}
local web_app_url = app_settings.web_app_url or "stingray://app/main.html"
if not stingray.Script.exists(web_app_url) then
	print("Using default web app URL", web_app_url)
end

function init()

	if LEVEL_EDITOR_TEST and not LEVEL_EDITOR_TEST_READY then
		print("Waiting for test level initialization...")
		return
	end

	web_app = stingray.WebApp.create(web_app_url)
end

function shutdown()
	stingray.WebApp.destroy(web_app)
end

if test_events then
	function update(dt)
		stingray.WebApp.update(web_app, dt)
		local events = stingray.WebApp.consume_events()
		for i=1,#events,1 do
			print( 'name: ' .. events[i].name )
			print( 'data: ' .. events[i].data )
		end
		index = stingray.Keyboard.button_id("x")
		local x_pressed = index and stingray.Keyboard.pressed( index )
		if x_pressed then
			-- Send an event to the web app
			--
			stingray.WebApp.emit(web_app, "eventFire", '"sayhello"' )
		end
	end
else
	function update(dt)
		stingray.WebApp.update(web_app, dt)
	end
end

function render()
	stingray.WebApp.render(web_app)
end
