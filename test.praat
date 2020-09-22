clearinfo

foo$ = "1"
foo$ += "2"
appendInfoLine: "# ", foo$

lua_val = Lua return.lua
appendInfoLine: "# ", lua_val

lua_obj = Lua create_obj.lua
appendInfoLine: "# object created through Lua: ", lua_obj
select lua_obj
zc$ = Get nearest zero crossing: 1, 0
appendInfoLine: "# nearest zero crossing in Praat: ", zc$
zcn = number(zc$)
appendInfoLine: "# nearest zero crossing + 2 in Praat: ", zcn + 2

Lua call.lua

appendInfoLine: "# And that's all, folks!"
