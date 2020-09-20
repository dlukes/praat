extern "C" {
	#include <lua.h>
	#include <lualib.h>
	#include <lauxlib.h>
}

#include "Interpreter.h"

autostring32 luapraat_run(const char32 *script_path, Interpreter *interpreter);
