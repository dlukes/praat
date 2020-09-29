#ifndef _luapraat_h_
#define _luapraat_h_

#include "Interpreter.h"

void luapraat_run_file(const char32 *script_path, Interpreter interpreter);
void luapraat_run_chunk(const char32 *chunk, Interpreter interpreter);

#endif
