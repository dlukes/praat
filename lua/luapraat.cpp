#include "melder.h"
#include "luapraat.h"

lua_State *L;

// maybe there shouldn't be a global lua_State and this function should
// instead return it to the caller, who would then pop the result off
// the stack and/or do anything else they need to do with it? this would
// be safer in case Praat Script does something fancy with multiple
// threads; a global variable is obviously not threadsafe. on the flip
// side, no state can then be shared between invocations (which is
// probably fine?), the caller has to remember to free the state and
// deal with Lua stack manipulation.
char *luapraat_run() {
		L = luaL_newstate();
		luaL_openlibs(L);

		int status = luaL_loadfile(L, "script.lua");
		if (status) {
			/* If something went wrong, error message is at the top of */
			/* the stack */
			Melder_throw(U"Couldn't load file: ", Melder_peek8to32(lua_tostring(L, -1)));
		}

		return "42";
}
