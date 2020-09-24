# Lua
local sine = praat.Create_Sound_from_formula("sine", 1, 0.0, 1.0, 44100, "1/2 * sin(2*pi*377*x)")
print("object ID: ", sine)
praat.Create_iris_data_set()
praat.select(sine)
local zc = praat.Get_nearest_zero_crossing(1, 0)
print("nearest zero crossing: ", zc)
print("nearest zero crossing + 2: ", zc + 2)

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
