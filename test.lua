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
