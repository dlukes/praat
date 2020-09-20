local M = {}

setmetatable(M, {
  __index = function(_, cmd)
    return function(...)
      local args = table.concat({...}, " ")
      cmd = cmd:gsub("_", " ")
      cmd = cmd:gsub("^%l", string.upper)
      local cmd_and_args = string.format("%s: %s", cmd, args)
      return _praat(cmd_and_args)
    end
  end
})

print, _print = M.appendInfo, print

return M
