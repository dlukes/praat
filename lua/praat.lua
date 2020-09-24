local M = {}


------------------------------ Allow loading modules from $PRAAT_DIR/lua

local dir_sep = package.config:sub(1, 1)
local pat_sep = package.config:sub(3, 3)
local glob = package.config:sub(5, 5)
local praat_lua = PRAAT_DIR..dir_sep.."lua"..dir_sep
package.path = (
  praat_lua..glob..".lua"
    ..pat_sep..
  praat_lua..glob..dir_sep.."init.lua"
    ..pat_sep..
  package.path
)


------------------------------ Praat-like string-to-number conversion...

local function praat_tonumber(val)
  return type(val) == "string" and tonumber(string.match(val, "^(%S+)%s")) or val
end

-- ... performed automatically when doing arithmetic on strings (Lua
-- already has string-to-number autoconversion, but it's too strict, it
-- doesn't allow trailing garbage)
local string_meta = getmetatable("")
function string_meta.__add(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__sub(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__mul(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__div(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__mod(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__pow(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__unm(a, b) return praat_tonumber(a) + praat_tonumber(b) end
function string_meta.__idiv(a, b) return praat_tonumber(a) + praat_tonumber(b) end


--------------------------------------------- Printing & pretty-printing

function M.print(...)
  if select("#", ...) > 0 then
    M.appendInfoLine(...)
  else
    -- without arguments, Praat would parse the command as a variable
    M.appendInfoLine("")
  end
end

function M.inspect(value, indent, tables_seen)
  indent = indent or 2
  tables_seen = tables_seen or {}
  if type(value) == "table" and not tables_seen[value] then
    tables_seen[value] = true
    print("{")
    for k, v in pairs(value) do
      M.appendInfo(string.rep(" ", indent)..tostring(k).." = ")
      M.inspect(v, indent + 2, tables_seen)
      print()
    end
    indent = indent - 2
    local close = indent > 0 and "}," or "}\n"
    M.appendInfo(string.rep(" ", indent)..close)
  else
    local close = indent > 2 and "," or "\n"
    -- unfortunately, can't figure out name if value is a function;
    -- there's debug.getinfo, but that only works (somewhat) reliably
    -- when invoked from inside a call to that function
    M.appendInfo(tostring(value)..close)
  end
end

-- remap global print to write to the Praat info window
print, _print = M.print, print


------------------------------------------------ Praat command execution

-- TODO: any other legacy commands that should be remapped?
local cmd_map = {
  echo = "writeInfoLine",
  printline = "writeInfoLine",
  select = "selectObject",
  plus = "plusObject",
  minus = "minusObject",
}

setmetatable(cmd_map, {
  __index = function(_, cmd)
    return cmd
  end
})

local praat_obj_meta = {
  __tostring = function(o)
    return '"{ id = '..o.id..", name = "..o.name:gsub('"', '""')..' }"'
  end,

  __index = function(o, key)
    if key == "__praat_object" then
      return true
    else
      return function(self, ...)
        -- this function is supposed to be called via the : syntactic
        -- sugar; if self ~= o, then it was called with . and self is in
        -- fact an argument meant for the Praat command; if Praat
        -- doesn't get it, it might error out or silently compute a
        -- different value, so better throw an error
        if self ~= o then
          error(string.format(
            "Use the `:` operator to call commands on Praat objects: "..
            "`obj:%s(...)`, not `obj.%s(...)`.", key, key
          ))
        end
        M.select(o)
        -- the key is a Praat command to run
        local ans = M[key](...)
        M.minus(o)
        return ans
      end
    end
  end,
}

local function praat_cmd(...)
  local ans = _praat_cmd(...)
  if type(ans) == "table" then
    -- this means the Praat command returned an array of Praat objects;
    -- let's set them up for comfortable use from within Lua
    local total, last_obj
    for i, obj in ipairs(ans) do
      setmetatable(obj, praat_obj_meta)
      total, last_obj = i, obj
    end
    -- if there's only one object, don't wrap it in an array, but do
    -- return an empty array if there's none
    return total == 1 and last_obj or ans
  else
    return ans
  end
end

local function stringify_array(array, lvl)
  -- nesting level can be at most 2, corresponding to a Praat matrix
  lvl = lvl or 1
  local ans = "{"
  for i, v in ipairs(array) do
    local sep = i > 1 and "," or ""
    if type(v) == "table" and lvl < 2 then
      ans = ans..sep..stringify_array(v, lvl + 1)
    else
      ans = ans..sep..tostring(v)
    end
  end
  return ans.."}"
end

local function stringify_args(is_info, ...)
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
    elseif t == "table" then
      if arg.__praat_object then
        if is_info then
          arg = tostring(arg)
        else
          arg = arg.id
        end
      else
        arg = stringify_array(arg)
      end
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
      cmd = cmd:gsub("_", " ")
      cmd = cmd_map[cmd]
      local is_info = cmd:find("^writeInfo") or cmd:find("^appendInfo")
      local args = stringify_args(is_info, ...)
      local cmd_and_args = #args > 0 and string.format("%s: %s", cmd, args) or cmd
      return praat_cmd(cmd_and_args)
    end
  end,

  -- allow alternate syntax for calling Praat commands which writes them
  -- out in the same way as in a Praat script: `praat "Command: Arg1 Arg2"`
  __call = function(_, cmd_or_script)
    if cmd_or_script:find("\n") then
      _praat_script(cmd_or_script)
    else
      return praat_cmd(cmd_or_script)
    end
  end,
})


------------------------------------------------------------------------

return M
