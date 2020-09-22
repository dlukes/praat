extern "C" {
	#include <lua.h>
	#include <lualib.h>
	#include <lauxlib.h>
}

#include "Interpreter.h"

void luapraat_run_file(const char32 *script_path, Interpreter interpreter);
void luapraat_run_chunk(const char32 *chunk, Interpreter interpreter);
