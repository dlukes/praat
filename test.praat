clearinfo

foo$ = "1"
foo$ += "2"
appendInfoLine: foo$

Create Sound from formula: "sine", 1, 0.0, 1.0, 44100, "1/2 * sin(2*pi*377*x)"
bar = Get nearest zero crossing: 1, 0.5
appendInfoLine: bar

lua_val = Lua lua/return.lua
appendInfoLine: lua_val

lua_obj = Lua lua/create_obj.lua
appendInfoLine: "object created from Lua: ", lua_obj
select lua_obj
zc = Get nearest zero crossing: 1, 0
appendInfoLine: zc

Lua lua/call.lua

appendInfoLine: "And that's all, folks!"
