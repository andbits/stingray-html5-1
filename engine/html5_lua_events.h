#pragma once

#include "shared_ptr.h"

#include <engine_plugin_api/plugin_api.h>

#include <plugin_foundation/allocator.h>
#include <plugin_foundation/string.h>
#include <plugin_foundation/vector.h>

namespace PLUGIN_NAMESPACE {

	using namespace stingray_plugin_foundation;

	struct LuaEvent {
		ALLOCATOR_AWARE;

		explicit LuaEvent( Allocator &a )
			: allocator(a),
			name(a),
			data(a)
		{
		}

		Allocator    &allocator;
		DynamicString name;
		DynamicString data;
	};
	typedef shared_ptr<LuaEvent> LuaEventPtr;

	struct LuaEventHandler {

		ALLOCATOR_AWARE;
		explicit LuaEventHandler(Allocator &a)
			: allocator(a),
			  events(a),
			  stack_idx(0)
		{
		}

		LuaEventPtr add_event(const char *name, const char *data);
		LuaEventPtr consume_one();

		Allocator            &allocator;
		Vector<LuaEventPtr>   events;
		unsigned			  stack_idx;
		static LuaEventHandler* instance;
	};

	LuaEventHandler * event_handler();
	void setup_lua_event_table();
	void shutdown_lua_event_table();

} // end namespace
