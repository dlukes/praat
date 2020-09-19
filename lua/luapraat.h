extern "C" {
	#include <lua.h>
	#include <lualib.h>
	#include <lauxlib.h>
}

extern lua_State *L;
const char32 *luapraat_run(char32 *script_path);
