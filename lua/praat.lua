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
function string_meta.__sub(a, b) return praat_tonumber(a) - praat_tonumber(b) end
function string_meta.__mul(a, b) return praat_tonumber(a) * praat_tonumber(b) end
function string_meta.__div(a, b) return praat_tonumber(a) / praat_tonumber(b) end
function string_meta.__mod(a, b) return praat_tonumber(a) % praat_tonumber(b) end
function string_meta.__pow(a, b) return praat_tonumber(a)^praat_tonumber(b) end
function string_meta.__unm(a) return -praat_tonumber(a) end


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
    M.appendInfo("{")
    local was_empty = true
    for k, v in pairs(value) do
      M.appendInfo("\n"..string.rep(" ", indent)..tostring(k).." = ")
      M.inspect(v, indent + 2, tables_seen)
      was_empty = false
    end
    indent = indent - 2
    local nl = was_empty and "" or "\n"
    local close = indent > 0 and "}," or "}\n"
    M.appendInfo(nl..string.rep(" ", indent)..close)
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


------------------------------ Praat object wrappers & utility functions

local praat_obj_meta = {
  __tostring = function(obj)
    return "{ id = "..obj.id..", name = "..obj.name:gsub('"', '""').." }"
  end,

  -- for consistency, Praat objects pretend to the # operator that
  -- they're a one-element array of Praat objects (cf. the praat_cmd
  -- function for a detailed explanation why)
  __len = function() return 1 end,

  __index = function(obj, key)
    if key == "__praat_object" then
      return true
    else
      return function(self, ...)
        -- this function is supposed to be called via the : syntactic
        -- sugar; if self ~= o, then it was called with . and self is in
        -- fact an argument meant for the Praat command; if Praat
        -- doesn't get it, it might error out or silently compute a
        -- different value, so better throw an error
        if self ~= obj then
          error(string.format(
            "Use the `:` operator to call commands on Praat objects: "..
            "`obj:%s(...)`, not `obj.%s(...)`.", key, key
          ))
        end
        M.select(obj)
        -- the key is a Praat command to run
        local ans = M[key](...)
        -- don't worry about cleaning up by deselecting with minus, the
        -- command might have removed the objects for all you know
        return ans
      end
    end
  end,
}

local praat_obj_group_meta = {
  -- no custom __tostring needed, it's handled by stringify_array and
  -- only the IDs are printed, which is less noisy in case there are
  -- many objects

  __index = function(group, key)
    if key == "__praat_object" then
      -- without this, looking up __praat_object will return the
      -- function below, which is truthy, which confuses stringify_args
      return false
    else
      -- NOTE: The same comments apply as in the analogous function in
      -- praat_obj_meta above.
      return function(self, ...)
        if self ~= group then
          error(string.format(
            "Use the `:` operator to call commands on Praat object groups: "..
            "`group:%s(...)`, not `group.%s(...)`.", key, key
          ))
        end
        for i, o in ipairs(group) do
          if i == 1 then
            M.select(o)
          else
            M.plus(o)
          end
        end
        local ans = M[key](...)
        return ans
      end
    end
  end,
}

function M.group(...)
  local group = {...}
  setmetatable(group, praat_obj_group_meta)
  return group
end


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
    if total == 1 then
      -- If there's only one object, return it directly instead of
      -- wrapping it in an array. This is somewhat unfortunate /
      -- inconsistent from the perspective of select / minus / plus
      -- commands, but needed because we want commands that create an
      -- object to return that object, and not a one-element array. The
      -- inconsistency is somewhat mitigated by praat_obj_meta having a
      -- __len metamethod which returns 1, i.e.  they sort of pretend
      -- like they're a one-element array.
      ans = last_obj
    end
  end
  return ans
end

local function stringify_array(array, lvl)
  -- nesting level can be at most 2, corresponding to a Praat matrix
  lvl = lvl or 1
  local ans = "{"
  for i, v in ipairs(array) do
    local sep = i > 1 and "," or ""
    local t = type(v)
    if t == "table" and v.__praat_object then
      ans = ans..sep..v.id
    elseif t == "table" and lvl < 2 then
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
    -- the second check detects NaN's
    if t == "nil" or arg ~= arg then
      arg = "undefined"
    elseif t == "number" then
    elseif t == "boolean" then
      arg = arg and 1 or 0
    elseif t == "string" then
      arg = arg:gsub('"', '""'):gsub("\n", '", newline$, "')
      arg = '"'..arg..'"'
    elseif t == "table" then
      if arg.__praat_object then
        if is_info then
          arg = '"'..tostring(arg)..'"'
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

  -- allow alternate syntax for evaluating Praat snippets which writes them
  -- out in the same way as in a Praat script: `praat "Command: Arg1 Arg2"`
  __call = function(_, snippet)
    if snippet:find("^%s*[%w_]+[$#]?#?%s*$") then
      -- snippet is a variable name
      return _get_praat_var(snippet)
    elseif snippet:find("\n") or snippet:find("%s*%S+%s*=") then
      -- a (series of) statement(s) which only runs for side effects
      _praat_script(snippet)
    else
      -- an expression (command) which returns a useful value
      return praat_cmd(snippet)
    end
  end,
})


------------------------------------------------------------------------

return M
