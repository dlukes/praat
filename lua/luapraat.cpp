#include "melder.h"
#include "luapraat.h"

autostring32 luapraat_run(const char32 *script_path) {
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);

	const char *script_path_fs = Melder_peek32to8_fileSystem(script_path);
	int load_error = luaL_loadfile(L, script_path_fs);
	if (load_error) {
		// If something went wrong, error message is at the top of the stack
		Melder_throw(U"Couldn't load file: ", Melder_8to32(lua_tostring(L, -1)).get());
	}

	int call_error = lua_pcall(L, 0, LUA_MULTRET, 0);
	if (call_error) {
		Melder_throw(U"Failed to run script: ", Melder_8to32(lua_tostring(L, -1)).get());
	}

	const char *result_c = lua_tostring(L, -1);
	// NOTE: The conversion assumes UTF-8 output from Lua.
	autostring32 result = Melder_8to32(result_c);
	// Melder_casual(U"number of elements left on stack: ", lua_gettop(L));
	while (lua_gettop(L) > 0) lua_pop(L, 1);
	lua_close(L);
	return result;
}
