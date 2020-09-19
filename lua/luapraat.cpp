#include "melder.h"
#include "luapraat.h"

// 1. Wrap Praat command running function in a Lua C function wrapper.
// 2. Load it into Lua as a global variable, e.g. _praat.
// 3. Use it in our praat Lua lib.
// 4. Load that lib into Lua at startup. Either include the string in
// the binary (which looks hard to do in C++ unlike in Rust, for some
// reason), or put it in <Praat dir>/lua and load from there. But having
// it be on the file system is error prone. Plus now that I think of it,
// Praat comes as a single executable download which writes that dir on
// first startup, so nope.
//
// Cf. <https://www.lua.org/pil/26.1.html>

static const char *luapraat_lib = R"(
local M = {}

setmetatable(M, {
	__index = function(_, cmd)
		return function(...)
			local args = table.concat({...}, " ")
			cmd = cmd:gsub("_", " ")
			cmd = cmd:gsub("^%l", string.upper)
			cmd = string.format("%s: %s", cmd, args)
			print(cmd)	-- TODO: make Praat run this instead, obviously
		end
	end
})

return M
)";

autostring32 luapraat_run(const char32 *script_path) {
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	luaL_dostring(L, luapraat_lib);
	lua_setglobal(L, "praat");

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
