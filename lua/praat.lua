local M = {}

local function praat_tonumber(val)
  return type(val) == "string" and tonumber(string.match(val, "^(%S+)%s")) or val
end

local string_meta = getmetatable("")
function string_meta.__add(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__sub(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__mul(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__div(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__mod(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__pow(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__unm(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__idiv(a, b) return praat_tonumber(a) + praat_tonumber(b) end

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
  -- dynamically generate calls to Praat commands
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
