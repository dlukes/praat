local M = {}

setmetatable(M, {
  __index = function(_, cmd)
    return function(...)
      local args = table.concat({...}, " ")
      cmd = cmd:gsub("_", " ")
      cmd = cmd:gsub("^%l", string.upper)
      cmd = string.format("%s: %s", cmd, args)
      _print(cmd) -- TODO: make Praat run this instead, obviously
    end
  end
})

print, _print = M.appendInfo, print

return M
