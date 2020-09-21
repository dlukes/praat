local M = {}

local function stringify_args(...)
  local nargs = select("#", ...)
  local stringified = {}
  for i = 1, nargs do
    local arg = select(i, ...)
    local t = type(arg)
    if t == "number" then
    elseif t == "boolean" then
      arg = arg and 1 or 0
    elseif t == "nil" then
      arg = "undefined"
    elseif t == "string" then
      arg = arg:gsub('"', '""'):gsub("\n", '", newline$, "')
      arg = '"'..arg..'"'
    else
      error("Missing implementation for passing arguments of type "..t.." to Praat.")
    end
    stringified[i] = arg
  end
  return table.concat(stringified, ", ")
end

setmetatable(M, {
  __index = function(_, cmd)
    return function(...)
      local args = stringify_args(...)
      cmd = cmd:gsub("_", " ")
      local cmd_and_args = #args > 0 and string.format("%s: %s", cmd, args) or cmd
      return _praat(cmd_and_args)
    end
  end
})

print, _print = M.appendInfoLine, print

return M
