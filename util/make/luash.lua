local json = require 'json'
local uv = require 'uv'
local fs = require 'fs'

local pathjoin = require'pathjoin'.pathJoin

local f = string.format

-- Utilities
local function slice(tbl, start, stop, step)
   local ret = {}

   for i = start or 1, stop or #tbl, step or 1 do
      table.insert(ret, tbl[i])
   end

   return ret
end

local function clamp(n, minValue, maxValue)
   return math.min(math.max(n, minValue), maxValue)
end

local function pad(str, len, align, pattern)
   pattern = pattern or ' '
   if align == 'right' then
      return string.rep(pattern, (len - #str) / #pattern) .. str
   elseif align == 'center' then
      local padding = 0.5 * (len - #str) / #pattern
      return string.rep(pattern, math.floor(padding)) .. str .. string.rep(pattern, math.ceil(padding))
   else -- left
      return str .. string.rep(pattern, (len - #str) / #pattern)
   end
end

local env = {}

env.PWD = uv.cwd()

-- Change functions to be cross-platform

-- Change cd to uv cd
function env.cd(path)
   uv.chdir(path)

   env.PWD = uv.cwd()
end

-- Change exit to os.exit to allow strings `exit '1'`
function env.exit(code)
   os.exit(tonumber(code))
end

-- Change echo to print + string.format
function env.echo(str, ...)
   print(f(tostring(str), ...))
end

-- Special color formatting
local colors = {
   black = '[30m',
   red = '[31m',
   green = '[32m',
   yellow = '[33m',
   blue = '[34m',
   magenta = '[35m',
   cyan = '[36m',
   white = '[37m',
   reset = '[0m',
   bright_black = '[30;1m',
   bright_red = '[31;1m',
   bright_green = '[32;1m',
   bright_yellow = '[33;1m',
   bright_blue = '[34;1m',
   bright_magenta = '[35;1m',
   bright_cyan = '[36;1m',
   bright_white = '[37;1m'
}

for i, v in pairs(colors) do
   colors[i] = '\27' .. v
end

function env.pretty(text)
   local formatted = text:gsub('$([%w_]+) ', function(color)
      return '\27' .. colors[color]
   end)

   print(formatted .. '\27' .. colors.reset)
end

-- === Magic function ===
-- * returns status
-- * doesn't print output
-- * has parsing options
function env._(cmd)
   local file = io.popen(cmd)

   local res = {}

   res.out = file:read('a*')

   setmetatable(res, {
      __tostring = function(self)
         return self.out
      end
   })

   local succ, _, code = file:close()

   res.status = code
   res.ok = succ

   res.json = function(self)
      return json.decode(self.out)
   end

   return res
end

-- Checks the first argument to see if it matches the name
function env.task(name, fn)
   if args[1] == name then
      fn()

      os.exit()
   end
end

-- Checks if the item is within the PATH or not
function env.pathed(file)
   local path = os.getenv('PATH')

   local splitter = jit.os == 'Windows' and ';' or ':'

   for dir in path:gmatch('([^' .. splitter .. ']*)') do
      if fs.existsSync(pathjoin(dir, file)) then
         return true
      end
   end

   return false
end

-- Change mkdir to uv mkdir
env.mkdir = uv.fs_mkdir

-- Change touth to uv touch
env.touch = function(path)
   fs.writeFileSync(path, '')
end

-- _G.require != require
env.require = require

return function(toLoad)
   toLoad = type(toLoad) == 'function' and string.dump(toLoad) or toLoad
   local fn, syntax = load(toLoad, 'Lua.sh', 'bt', setmetatable(env, {
      __index = function(_, key)
         if rawget(_G, key) then
            return rawget(_G, key)
         else
            if rawget(env, key) then
               return rawget(env, key)
            end

            return function(args)
               local file = io.popen(key .. ' ' .. args)

               for line in file:lines() do
                  print(line)
               end

               local succ, _, code = file:close()

               if not succ then
                  os.exit(code)
               end
            end
         end
      end
   }))

   if not fn then
      -- Parse syntax error for prettier output
      local lineN, err = syntax:match('.*:(%d*):(.*)')
      lineN = tonumber(lineN)

      local split = {}

      for part in toLoad:gmatch('([^\n]*)') do
         table.insert(split, part)
      end

      local start = clamp(lineN - 3, 1, #split)

      local lines = slice(split, start, clamp(lineN + 3, 1, #split))

      local displayed = ''

      for i, line in pairs(lines) do
         displayed = displayed .. '$white | ' .. pad(tostring(i + start), #tostring(#lines) + 1, 'right') ..
                         ' |$reset  ' .. line .. (i ~= #lines and '\n' or '')
      end

      env.pretty(f('$bright_red error:$white %s$reset \n%s', err, displayed))

      os.exit(1)
   end

   local succ, err = pcall(fn)

   if not succ then
      print('Failed to run script', err)
      os.exit(1)
   end
end
