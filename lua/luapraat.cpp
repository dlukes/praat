#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
/* #include <stdlib.h> */
/* #include <stdio.h> */

#include "melder.h"
#include "luapraat.h"

char *luapraat_run() {
		L = luaL_newstate();
		luaL_openlibs(L);

		int status = luaL_loadfile(L, "script.lua");
		if (status) {
				/* If something went wrong, error message is at the top of */
				/* the stack */
				Melder_throw(U"Couldn't load file: ", Melder_peek8to32(lua_tostring(L, -1)));
		}

		return "3.1415";
}
