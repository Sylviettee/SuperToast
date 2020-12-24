---@type discordia
local discordia = require('discordia')
---@type stringx
local stringx = require('utils/stringx')

local Color = discordia.Color

local f = string.format

local function eatUntilEnd(str, stop, count)
   local newStr = ''
   local ignoreNext

   local ate = 0
   local counted = 0

   local err = f('Unmatched `%s`', stop)

   for char in str:gmatch('.') do
      ate = ate + 1
      if char == stop and not ignoreNext then
         err = nil
         break
      elseif char == '\\' and not ignoreNext then
         ignoreNext = true
      else
         ignoreNext = false
         newStr = newStr .. char
      end

      if char == count then
         counted = counted + 1
      end
   end

   return newStr, ate, counted, err
end

local function where(str, id, count)
   local counted = 0
   local currentPos = 0

   for char in str:gmatch('.') do
      currentPos = currentPos + 1

      if char == id then
         counted = counted + 1
      end

      if counted == count then
         break
      end
   end

   return currentPos
end

local function buildError(code, msg, input, start, stop)
   local builder = f('error[%s]\n   ┌─ input\n   │\n   │ %s\n   │ ', code, input)

   local below = string.rep(' ', start - 1) ..
      string.rep('^', stop - start + 1) ..
      ' ' .. msg

   return builder .. below
end

--- An argument parser which can be used in part with commands
---@class ArgParser
local ArgParser = discordia.class('ArgParser')

---@class ArgParser.rawArgs
---@field public flags table<string, string[]>
---@field public arguments string[]

---@alias ArgParser.types
---| "'string'"      # Do nothing
---| "'number'"      # Attempt to typecast to number
---| "'boolean'"     # Attempt to typecast to boolean
---| "'int'"         # Attempt to typecast to a whole number (math.floor(input) == input)
---| "'command'"     # Check if the input is the name of a valid command then typecast
---| "'user'"        # Check if the input is either a user id, user mention, or username then typecast to a User

ArgParser.types = {
   string = function(input)
      return input
   end,
   number = function(input)
      return tonumber(input), not tonumber(input) and f('Cannot convert `%s` to a number', input)
   end,
   boolean = function(input)
      local lowered = input:lower()

      if lowered == 'true' or lowered == 'false' then
         return lowered == 'true'
      else
         return nil, f('`%s` is not a boolean (true/false)', input)
      end
   end,
   int = function(input)
      if tonumber(input) then
         input = tonumber(input)

         if math.floor(input) == input then
            return input
         else
            return nil, f('`%s` is floating point number', input)
         end
      else
         return nil, f('Cannot convert %s to a number', input)
      end
   end,
   command = function(input, client)
      local args = stringx.split(input, ' ')

      local cmd = client.commands:search(function(comm)
         local q = args[1]

         local inAliases = comm.aliases:find(function(x)
            return x == q
         end)

         if comm.name == q or inAliases then
            if #args >= 2 then
               return comm.subcommands:find(function(x)
                  return x.name == args[2]
               end)
            else
               return comm
            end
         end
      end)

      return cmd, not cmd and f('Unable to find the command by the name of `%s`', input)
   end,
   user = function(input, client)
      local user = client.users:get(input)

      if user then
         return user
      end

      if input:find('<@%d+>') then
         user = client:getUser(input:match('<@%d+>'))
      elseif input:find('#', 1, true) then
         local username, discriminator = input:match('(.*)#(%d+)$')

         if username and discriminator then
            user = client.users:find(function(u)
               return u.username == username and u.discriminator == discriminator
            end)
         end
      end

      if user then
         return user
      end

      local distance = math.huge
      local lowered = input:lower()

      local closest

      for u in client.users:iter() do
         if u.username:lower():find(lowered, 1, true) then
            local dist = stringx.levenshtein(u.username, input)

            if dist == 0 then
               return u
            elseif dist < distance then
               closest = u
               distance = dist
            end
         end
      end

      return nil, closest and f('Did you mean `%s`?', closest.username) or
         f('Unable to find anybody with the username of `%s`.', input)
   end
}

---@type ArgParser | fun(): ArgParser
ArgParser = ArgParser

function ArgParser:__init()
   self._arguments = {}
   self._flags = {}
end

--- Attach the parser to a command, should be after all flags and arguments
---@param command Command
---@return ArgParser
function ArgParser:attach(command)
   local usage = command.name

   for i = 1, #self._arguments do
      usage = usage .. ' <' .. self._arguments[i][2] .. '>'
   end

   for i, v in pairs(self._flags) do
      if v[2] == 'boolean' then
         usage = usage .. ' [--' .. i .. ']'
      else
         usage = usage .. ' --' .. i .. ' <' .. v[2] .. '>'
      end
   end

   command:usage(usage)

   command:check(function(_, args, client)
      local succ, err = self:parse(table.concat(args, ' '), client)
      return succ and true or nil, err and '```\n' .. err .. '\n```' or nil
   end)

   local oldExecute = command._execute

   command:execute(function(msg, args, client)
      local newArgs = self:parse(table.concat(args, ' '), client)

      oldExecute(msg, newArgs, client)
   end)

   return self
end

--- Register a function to check a passed argument
---@param func function
---@param name string
---@overload fun(func: ArgParser.types)
---@return ArgParser
function ArgParser:arg(func, name)
   if type(func) == 'function' then
      table.insert(self._arguments, {func, name})
   elseif type(func) == 'string' then
      table.insert(self._arguments, {ArgParser.types[func], func})
   else
      error 'Expected function or string!'
   end

   return self
end

--- Register a function to check a passed flag
---
--- If the flag type is set as a boolean, the presence of the flag is counted as true
---@param name string
---@param func function
---@param typeName string
---@overload fun(name: string, func: ArgParser.types)
---@return ArgParser
function ArgParser:flag(name, func, typeName)
   if type(func) == 'function' then
      self._flags[name] = {func, typeName}
   elseif type(func) == 'string' then
      self._flags[name] = {ArgParser.types[func], func}
   else
      error 'Expected function or string!'
   end

   return self
end

--- Parse the input, typechecking it along the way
---@param str string
---@param client Client
---@return table | nil, string | nil
function ArgParser:parse(str, client)
   local raw, parseErr = self:_parse(str)

   if not raw then
      return nil, 'Parse error: \n' .. parseErr
   end

   local res = {
      arguments = {}
   }

   local errors = {}

   local missing = 0

   for i = 1, #self._arguments do
      if not raw.arguments[i] then
         table.insert(errors, buildError(
            'missing_required_argument',
            f('Expected %s, got nothing', self._arguments[i][2]),
            str,
            #str + (missing * 3) + 1,
            #str + ((missing + 1) * 3)
         ))

         missing = missing + 1
      else
         local v, start, stop = raw.arguments[i][1], raw.arguments[i][2], raw.arguments[i][3]
         local succ, err = self._arguments[i][1](v, client)

         if succ == nil then
            local part = str:sub(start, stop)

            local tooMuchStart, tooMuchEnd = #part:match('(%s*).*'), #part:match('^.-(%s*)$')

            start = start + tooMuchStart
            stop = stop - tooMuchEnd

            table.insert(errors, buildError('incorrect_argument_type', err, str, start, stop))
         else
            table.insert(res.arguments, succ)
         end
      end
   end

   missing = 0

   for i, v in pairs(self._flags) do
      if not raw.flags[i] and v[2] ~= 'boolean' then
         table.insert(errors, buildError(
            'missing_required_flag',
            f('Expected %s, got nothing', v[2]),
            str,
            #str + (missing * 3) + 1,
            #str + ((missing + 1) * 3)
         ))

         missing = missing + 1
      else
         local flag = raw.flags[i]

         local data, start, stop

         local succ, err, went

         local topErr = 'incorrect_argument_type'

         if v[2] == 'boolean' then
            -- start = flag[1][2]
            -- stop = flag[1][3]

            went = true
            succ = flag and true or false
         elseif #flag == 1 then
            data = flag[1][1]
            start = flag[1][2]
            stop = flag[1][3]
         elseif #flag == 0 then
            went = true
            succ = nil
            err = f('Expected a flag argument of type %s, got nothing', v[2])
            topErr = 'missing_required_flag_argument'

            start = flag.pos[1] + (flag.pos[2] - flag.pos[1]) + 2
            stop = flag.pos[2] + 4
         else
            data = {}

            start = flag[1][2]
            stop = flag[#flag][3]

            for k = 1, #flag do
               table.insert(data, flag[k][1])
            end
         end

         if not went then
            succ, err = v[1](data, client)
         end

         if succ == nil then
            local part = str:sub(start, stop)

            local tooMuchStart, tooMuchEnd = #part:match('(%s*).*'), #part:match('^.-(%s*)$')

            start = start + tooMuchStart
            stop = stop - tooMuchEnd

            table.insert(errors, buildError(topErr, err, str, start, stop))
         else
            res[i] = succ
         end
      end
   end

   return #errors == 0 and res or nil, #errors > 0 and table.concat(errors, '\n') or nil
end

--- Internal function for parsing arguments, doesn't enforce types or anything else
---@param str string
---@return ArgParser.rawArgs
function ArgParser:_parse(str)
   local res = {
      arguments = {},
      flags = {}
   }

   local split = stringx.split(str, ' ')

   if #split == 1 and split[1] == '' then
      split = {}
   end

   local skipNext = false
   local currentFlag

   local errors = {}

   local i = 1

   while i < #split + 1 do
      local v = split[i]

      local lastI = i

      if not skipNext and v:sub(0, 1) ~= '-' then
         if v:sub(0, 1) == '"' or v:sub(0, 1) == "'" then
            local quoted, _, ate, err = eatUntilEnd(table.concat(split, ' ', i):sub(2), v:sub(0, 1), ' ')

            v = quoted

            i = i + ate

            if err then
               table.insert(errors, err)
            end
         end

         table.insert(res.arguments, {v, where(str, ' ', lastI - 1), where(str, ' ', i)})
      elseif v:sub(0, 1) == '-' then
         currentFlag = v:match('%-%-?(.*)')

         if currentFlag:sub(0, 1) == '-' then
            table.insert(errors, 'Flags must start with either 1 or 2 dashes `-`')
         else
            res.flags[currentFlag] = {pos = {where(str, ' ', i - 1), where(str, ' ', i)}}

            skipNext = true
         end
      else
         if v:sub(0, 1) == '"' or v:sub(0, 1) == "'" then
            local quoted, _, ate, err = eatUntilEnd(table.concat(split, ' ', i):sub(2), v:sub(0, 1), ' ')

            v = quoted

            i = i + ate

            if err then
               table.insert(errors, err)
            end
         end

         table.insert(res.flags[currentFlag], {v, where(str, ' ', lastI - 1), where(str, ' ', i)})
      end

      i = i + 1
   end

   return #errors == 0 and res or nil, #errors > 0 and table.concat(errors, '\n') or nil
end

return ArgParser