local praat_obj = praat.Create_Sound_from_formula("sine", 1, 0.0, 1.0, 44100, "1/2 * sin(2*pi*377*x)")
print("Praat object ID: ", praat_obj)
local zc = praat.Get_nearest_zero_crossing(1, 0)
print("nearest zero crossing from Lua: ", zc)
print("nearest zero crossing + 2 from Lua: ", zc + 2)
return praat_obj
