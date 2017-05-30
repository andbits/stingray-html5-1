#include "stingray_api.h"

#include "html5_lua_events.h"
#include <plugin_foundation/string.h>
#include <plugin_foundation/vector.h>

namespace PLUGIN_NAMESPACE {

	LuaEventPtr LuaEventHandler::add_event(const char *name, const char *data)
	{
		LuaEventPtr event = MAKE_NEW(allocator, LuaEvent, allocator);
		event->name = name;
		event->data = data;

		events.push_back( event );

		return event;
	}

	LuaEventPtr LuaEventHandler::consume_one()
	{
		if ( stack_idx < events.size() ) {
			return events[stack_idx++];
		}

		stack_idx = 0;
		events.clear();
		return nullptr;
	}

	LuaEventHandler *event_handler()
	{
		return LuaEventHandler::instance;
	}

	void setup_lua_event_table()
	{
		LuaEventHandler::instance =
			MAKE_NEW(allocator, LuaEventHandler, allocator);
	}

	void shutdown_lua_event_table()
	{
		MAKE_DELETE_TYPE(LuaEventHandler::instance->allocator,
						 LuaEventHandler,
						 LuaEventHandler::instance);
	}

	LuaEventHandler* LuaEventHandler::instance = nullptr;
};
