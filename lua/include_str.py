from pathlib import Path

root = Path(__file__).parent
praat_lua = (root / "praat.lua").read_text("utf-8").strip("\n")
luapraat_in = (root / "luapraat.in").read_text("utf-8")
luapraat_out = luapraat_in.replace('include_str!("praat.lua");', praat_lua)
(root / "luapraat.cpp").write_text(luapraat_out, "utf-8")
