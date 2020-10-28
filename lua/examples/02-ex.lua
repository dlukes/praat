#!Lua
-- If a script starts with the special comment `#!Lua`, Praat will hand
-- it off to Lua to run.

-- The global table `praat` provides an interface to Praat. Since we'll
-- be using it a lot, let's give it a shorter name, `p`.
local p = praat

-- (Another global variable provided by the Praat/Lua runtime is
-- `PRAAT_DIR` -- the path to the directory where your Praat
-- preferences, plugins etc. live.)

-- Praat commands can be called as functions in the `praat` table.
p.clearinfo()



-- The `print` function is a shortcut to `praat.appendInfoLine`.
print("---------------------------------------------------------------")
print("---------------------------- Running commands, creating objects")


-- Just substitute spaces in the command with underscores (" " -> "_")
-- and provide any arguments the command needs as function arguments.
local sine = p.Create_Sound_from_formula("sine", 1, 0.0, 0.005, 44100, "1/2 * sin(2*pi*377*x)")

-- Praat objects print nicely for convenience (thanks to a `__tostring`
-- metamethod).
print("Praat object: ", sine)

-- The object's unique ID and non-unique name can be accessed through
-- the `id` and `name` keys.
print(string.format("%d. %s", sine.id, sine.name))

-- The last object we created is selected, so we can implicitly use it
-- as the object to run the next command on.
local zc = p.Get_nearest_zero_crossing(1, 0)
print("Nearest zero crossing: ", zc)

-- Praat hands off values to Lua as strings, but when you use these
-- strings in numeric contexts, they will be converted to a number.
-- (This autoconversion is more lenient than the default one in Lua, it
-- allows any trailing characters, so as to match the string-to-number
-- conversion behavior of Praat.)
print("The time of the nearest zero crossing is a ", type(zc), ": ", zc)
local len = p.Get_total_duration()
print("The total duration of the sound is a ", type(len), ": ", len)
local zc_rel = zc / len
print(string.format(
  "When you divide one by the other, you get the relative position "..
  "of the nearest zero crossing within the sound, which is a %s: %f.",
  type(zc_rel),
  zc_rel
))
print(string.format(
  "This means you can easily format it e.g. as a percentage: %0.2f%%",
  zc_rel * 100
))



print("---------------------------------------------------------------")
print("---------------------------------------- (De)selecting objects ")


-- As mentioned, creating a new object selects it, and unselects any
-- previously created objects.
local iris = p.Create_iris_data_set()
print("The iris dataset has ", p.Get_number_of_rows(), ".")

-- You can select a previously created object as you would in Praat,
-- just pass it to the `select` command.
p.select(sine)
print("Nearest zero crossing is still: ", p.Get_nearest_zero_crossing(1, 0))

-- The `select`, `plus` and `minus` commands always return the currently
-- selected objects, which you can inspect as a sanity check.
local selected = p.plus(iris)
p.appendInfo(#selected, " currently selected object(s): ")
-- The `inspect` function pretty-prints a value.
p.inspect(selected)

-- When there's only one selected object, it's not wrapped in a
-- (one-element) array, it's returned by itself. For convenience though,
-- it still reports a length of 1 via the `#` operator.
selected = p.minus(sine)
p.appendInfo(#selected, " currently selected object(s): ")
p.inspect(selected)

selected = p.minus(iris)
p.appendInfo(#selected, " currently selected object(s): ")
p.inspect(selected)



print("---------------------------------------------------------------")
print("------------------------------ Calling methods on Praat objects")


-- Instead of manually selecting and deselecting objects though, you
-- might want to take advantage of calling commands as methods on the
-- Praat objects they should apply to via the `:` operator. This
-- performs the required selection automatically behind the scenes.
print("Nearest zero crossing called as method: ", sine:Get_nearest_zero_crossing(1, 0))

-- You can also create groups of objects and call commands which require
-- or allow multiple objects to be selected, as methods on the entire
-- group.
local group = p.group(sine, iris)
print("IDs of objects in the group (Praat sees them as a vector): ", group)
p.appendInfo("Detailed info about the group: ")
p.inspect(group)
group:Remove()

-- The group can also be passed to commands which accept a vector of
-- object IDs as one of their arguments. (TODO: an example of that?)



print("---------------------------------------------------------------")
print("----------------------------------------------------- Functions")


-- Lua makes it easy to wrap Praat commands in functions which let you
-- vary only some parameters while keeping others constant.
local function sine_sound(duration)
  return p.Create_Sound_from_formula("sine", 1, 0.0, duration, 44100, "1/2 * sin(2*pi*377*x)")
end

local longer_sine = sine_sound(10)
print("Duration of longer sine: ", longer_sine:Get_total_duration())



print("---------------------------------------------------------------")
print("-------------------------------------- Pretty-printing examples")


-- Here are a few additional examples of how `inspect` pretty-prints
-- things.
p.inspect(1)
p.inspect("foo")
p.inspect({1, 2, 3})
p.inspect(sine_sound)
p.inspect({funcs = {sine_sound, tonumber}, numbers = {1, 2}, strings = {"foo", "bar"}})

-- `inspect` makes sure that printing a self-referential table doesn't
-- recurse endlessly.
local t = {}
t[t] = 1
t[2] = t
p.inspect(t)



print("---------------------------------------------------------------")
print("--------------------- Running (almost) arbitrary Praat snippets")


-- Another way to run (almost) arbitrary snippets of Praat script code
-- is to call the `praat` table as a function and pass them in as
-- strings.
praat('appendInfoLine: "Hi there!"')

-- You can take advantage of the fact that Lua allows parentheses to be
-- omitted when calling functions with a single string argument. If
-- you've also added the `p` shortcut for `praat`, it all becomes fairly
-- succinct.
p'appendInfoLine: "Hi again!"'

-- Single line commands try to return sensible values where appropriate
-- and possible.
local another_sine = p'Create Sound from formula: "sine", 1, 0.0, 0.005, 44100, "1/2 * sin(2*pi*377*x)"'
print("Another way to create a sine wave: ", another_sine)



print("---------------------------------------------------------------")
print("---------------------- Using Praat forms and variables from Lua")


-- The above means you can easily create a Praat form from Lua. Use the
-- `[[...]]` Lua string syntax to enclose the Praat snippet, because
-- that allows you to use literal newlines inside the string.
p[[
form Sink it
  sentence Name_of_the_ship Titanic
  real Distance_to_the_iceberg_(m) 500.0
  natural Number_of_people 1800
  natural Number_of_boats 10
endform

appendInfoLine: "Praat says: The ship was called ", name_of_the_ship$, " and carried ", number_of_people, " passengers."
]]

-- Retrieving the values of the variables created by the form for
-- further use inside your Lua script is also easy.
local ship = p"name_of_the_ship$"
local num_people = p"number_of_people"
print("Lua agrees: It was the ", ship, " with ", num_people, " passengers.")



print("---------------------------------------------------------------")
print("--------------------------- Primitive vector and matrix support")


-- If a Praat command requires or accepts a vector or a matrix, you can
-- pass in a Lua array of numbers or array of arrays of numbers.
print({1, 2, 3})
print({{1, 2}, {3, 4}})



print("---------------------------------------------------------------")
print("-------------------------------------------- External libraries")


-- If you have any Lua libraries you'd like to (re)use across your
-- scripts, you can place them under `PRAAT_DIR/lua`.

-- This example is a bit more complicated than the others because we
-- first need to create a library under `PRAAT_DIR/lua`, so that we can
-- demonstrate that we're able to `require` it. This part wouldn't
-- typically be part of your scripts, you'd install the libraries
-- manually just once.
local dir_sep = package.config:sub(1, 1)
local my_lib = PRAAT_DIR..dir_sep.."lua"..dir_sep.."my_lib.lua"

io.output(my_lib)
io.write([[
local function my_func()
  print("Running my_func from ]]..my_lib..[[.")
end

print("Successfully required ]]..my_lib..[[.")
return my_func
]])
io.close()

-- The library is installed, now let's try loading it! The following two
-- lines of code is what you'd have in your scripts in order to use the
-- library.
local my_func = require("my_lib")
my_func()

-- And this final line is just cleanup which again wouldn't typically be
-- part of your scripts; in this case, we don't want to leave the test
-- library we created above lying around on your filesystem, so we
-- remove the file.
os.remove(my_lib)



--[[---------------------------------------------------- Further reading


That's it for an overview of what you can do with Lua inside Praat. If
you'd like to learn more about the features of Lua which are not
specific to Praat, check out these resources:

- A quick overview of the Lua language: https://learnxinyminutes.com/docs/lua/
- The official Programming in Lua book, whose first edition is freely
  available online: https://www.lua.org/pil/contents.html. Please note
  that this edition is for version 5.0 of the language, whereas the Lua
  interpreter available in Praat is LuaJIT 2.1.0-beta3, an alternative
  implementation of Lua with a JIT compiler which aims for compatibilty
  with version 5.1 of the language, with some extensions (see below).
- A comprehensive one-stop shop for Lua 5.1 information is the reference
  manual: https://www.lua.org/manual/5.1/. In particular, you can use it
  to quickly look up all of the functions in the standard library:
  https://www.lua.org/manual/5.1/manual.html#5.
- LuaJIT's extensions over Lua 5.1 are documented here: https://luajit.org/extensions.html.
  They cover some backwards compatible features from Lua 5.2, plus some
  additional custom ones specific to LuaJIT.
- In general, LuaJIT-specific information is available at https://luajit.org/.

--]]
