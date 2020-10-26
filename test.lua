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

-- Praat variables can be created and accessed from Lua, or at least
-- they should be able to, but there seems to be a bug in the hash table
-- holding the variables (or maybe I'm just using it in an unsupported
-- way?) which leads to whichever variable being defined first in the
-- following three lines of code, disappearing. But since this was
-- primarily intended to enable access to variables created by forms,
-- and it seems to work fine with those (see below), let's not worry
-- about that right now.
-- praat [[age = 21]]
-- praat [[name$ = "John Doe"]]
-- print("My name is ", praat"name$", " and I am ", praat"age", " years old.")

-- Also, vector and matrix access currently isn't implemented and throws
-- an error.
-- praat [[vector# = {1, 2, 3}]]
-- praat"vector#"

-- Still, all of the above was primarily meant as a means to access
-- values input by users into forms, and for that, it seems to be
-- working fine:
praat [[
form Sink it
  sentence Name_of_the_ship Titanic
  real Distance_to_the_iceberg_(m) 500.0
  natural Number_of_people 1800
  natural Number_of_boats 10
endform

appendInfoLine: "Praat says: The ship was called ", name_of_the_ship$, " and carried ", number_of_people, " passengers."
]]

local ship = praat"name_of_the_ship$"
local num_people = praat"number_of_people"
print("Lua agrees: It was the ", ship, " with ", num_people, " passengers.")
