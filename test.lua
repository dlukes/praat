# Lua
local sine = praat.Create_Sound_from_formula("sine", 1, 0.0, 1.0, 44100, "1/2 * sin(2*pi*377*x)")
print("object: ", sine)
local iris = praat.Create_iris_data_set()
praat.select(sine)
local zc = praat.Get_nearest_zero_crossing(1, 0)
print("nearest zero crossing: ", zc)
print("nearest zero crossing + 2: ", zc + 2)

-- select/plus/minus return the currently selected objects
local selected = praat.plus(iris)
praat.appendInfo("currently selected object(s): ")
praat.inspect(selected)
selected = praat.minus(sine)
-- special case: when there's only one, it's not wrapped in an array
praat.appendInfo("currently selected object(s): ")
praat.inspect(selected)
print("Praat objects also have a __tostring for convenience: ", selected)
selected = praat.minus(iris)
praat.appendInfo("currently selected object(s): ")
praat.inspect(selected)

-- there's also pseudo-OO sugar for calling commands as "methods" on
-- Praat objects
zc = sine:Get_nearest_zero_crossing(1, 0)
print("nearest zero crossing OO: ", zc)

-- as well as a way of creating groups of objects and calling commands
-- on those
local group = praat.group(sine, iris)
print("IDs of objects in the group (Praat sees them as a vector): ", group)
praat.appendInfo("inspect group: ")
praat.inspect(group)
group:Remove()
-- the group can also be passed to commands which accept a vector of IDs
-- as one of their arguments; TODO an example of that?

praat.inspect({1, 2, 3})
praat.inspect("foo")
praat.inspect(1)
praat.inspect(unpack)
praat.inspect({funcs = {unpack, _praat}, numbers = {1, 2}, strings = {"foo", "bar"}})
--- self-referential table doesn't recurse endlessly
local t = {}
t[t] = 1
t[2] = t
praat.inspect(t)

praat 'appendInfoLine: "Pass any command to Praat directly as a string."'

-- serializing arrays to Praat vector and matrix literals
print({1, 2, 3})
print({{1, 2}, {3, 4}})

praat [[
form Sink it
  sentence Name_of_the_ship Titanic
  real Distance_to_the_iceberg_(m) 500.0
  natural Number_of_people 1800
  natural Number_of_boats 10
endform
]]
