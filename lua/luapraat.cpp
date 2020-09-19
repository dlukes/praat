#include "melder.h"
#include "luapraat.h"

lua_State *L = NULL;

// maybe there shouldn't be a global lua_State and this function should
// instead return it to the caller, who would then pop the result off
// the stack and/or do anything else they need to do with it? this would
// be safer in case Praat Script does something fancy with multiple
// threads; a global variable is obviously not threadsafe. on the flip
// side, no state can then be shared between invocations (which is
// probably fine?), the caller has to remember to free the state and
// deal with Lua stack manipulation.
const char32 *luapraat_run(char32 *script_path) {
	if (L == NULL) {
		L = luaL_newstate();
	}
	luaL_openlibs(L);

	const char *script_path_c = Melder_peek32to8(script_path);
	int load_error = luaL_loadfile(L, script_path_c);
	if (load_error) {
		// If something went wrong, error message is at the top of the stack
		Melder_throw(U"Couldn't load file: ", Melder_peek8to32(lua_tostring(L, -1)));
	}

	int call_error = lua_pcall(L, 0, LUA_MULTRET, 0);
	if (call_error) {
		Melder_throw(U"Failed to run script: ", Melder_peek8to32(lua_tostring(L, -1)));
	}

	const char *result_c = lua_tostring(L, -1);

	// NOTE: Can't call lua_close here because that would free the memory
	// we're returning a pointer to. I should probably put a lua_close
	// somewhere at the end of the interpreter loop? Or maybe when Praat
	// exits?
	// lua_close(L);

	// NOTE: For the same reason, it might not be a good idea to call
	// lua_pop. The string might then be garbage collected and the pointer
	// invalidated. This could be an argument in favor of allocating a
	// copy of the string and returning it by value, but maybe not since
	// we don't need to keep it around long.
	while (lua_gettop(L) > 0) lua_pop(L, 1);
	// Melder_casual(U"2: number of elements left on stack: ", lua_gettop(L));

	return Melder_peek8to32(result_c);
}
