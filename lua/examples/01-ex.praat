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

# Note that due to the way Praat scripts handle return values from
# commands, if the Lua script returns a value, but that value is not
# assigned to a variable on the Praat script side, it will instead be
# printed to the Info window.
appendInfoLine: "Result is not assigned, so it gets printed: "
Lua: "return.lua"
appendInfoLine: newline$, "^^^^^^^^^^^^^^^^^ Here it is."

# If you don't need the result but also don't want it showing up in the
# output, just assign it to a throwaway variable you won't use.

# Praat objects can be created in Lua and their ID can be returned to
# the parent Praat script, which makes it possible to further work with
# them.
obj_from_lua = Lua: "return_obj.lua"
appendInfoLine: "Object ID of object created in Lua: ", obj_from_lua
select obj_from_lua
zc$ = Get nearest zero crossing: 1, 0
appendInfoLine: "Nearest zero crossing: ", zc$
