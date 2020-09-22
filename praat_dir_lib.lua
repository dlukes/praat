local dir_sep = package.config:sub(1, 1)
local my_lib = PRAAT_DIR..dir_sep.."lua"..dir_sep.."my_lib.lua"

io.output(my_lib)
io.write([[
print("-- Successfully required ]]..my_lib..[[.")

local function my_func()
  print("-- Running my_func from ]]..my_lib..[[.")
end

return my_func
]])
io.close()

local my_func = require("my_lib")
my_func()

os.remove(my_lib)
