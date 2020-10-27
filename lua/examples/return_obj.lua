local praat_obj = praat.Create_Sound_from_formula("sine", 1, 0.0, 1.0, 44100, "1/2 * sin(2*pi*377*x)")
-- When returning the Praat object to Praat, return either its ID
-- (preferably, because it's unique) or its name
return praat_obj.id
