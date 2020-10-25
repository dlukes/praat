#ifndef _LuaPraat_h_
#define _LuaPraat_h_

#include "Interpreter.h"

#include <lua.hpp>

class LuaPraat {
private:
	lua_State *L;

	void cleanup();
	void do_run(int load_error);

public:
	LuaPraat(Interpreter interpreter);
	~LuaPraat();

	LuaPraat(LuaPraat&& other) noexcept;
	LuaPraat& operator=(LuaPraat&& other) noexcept;

	// disable copying
	LuaPraat(const LuaPraat&) = delete;
	LuaPraat& operator=(const LuaPraat&) = delete;

	void run_file(const char32 *script_path);
	void run_chunk(const char32 *chunk);
};

#endif
