clearinfo

# Lua scripts can be called from a Praat script with the `Lua:` command
# (cf. the Praat -> Goodies menu in the GUI).
Lua: "call.lua"

# The scripts can also return values to the parent Praat script if
# needed.
num_from_lua = Lua: "return.lua"
appendInfoLine: "Lua return value interpreted as a number: ", num_from_lua
str_from_lua$ = Lua: "return.lua"
appendInfoLine: "Lua return value interpreted as a string: ", str_from_lua$

# Praat objects can be created in Lua and their ID can be returned to
# the parent Praat script, which makes it possible to further work with
# them.
obj_from_lua = Lua: "return_obj.lua"
appendInfoLine: "Object ID of object created in Lua: ", obj_from_lua
select obj_from_lua
zc$ = Get nearest zero crossing: 1, 0
appendInfoLine: "Nearest zero crossing: ", zc$
