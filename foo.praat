foo$ = "1"
foo$ += "2"
writeInfoLine: foo$

Create Sound from formula: "sine", 1, 0.0, 1.0, 44100, "1/2 * sin(2*pi*377*x)"
bar = Get nearest zero crossing: 1, 0.5
writeInfoLine: bar

lua_val = Lua something
writeInfoLine: lua_val
