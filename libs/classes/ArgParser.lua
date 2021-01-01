---@type discordia
local discordia = require('discordia')
---@type stringx
local stringx = require('utils/stringx')

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

local function between(str, id, start, stop)
   local gotStart = where(str, id, start)
   local gotStop = where(str, id, stop)

   local part = str:sub(gotStart, gotStop)

   local tooMuchStart, tooMuchEnd = #part:match('(%s*).*'), #part:match('^.-(%s*)$')

   return gotStart + tooMuchStart, gotStop - tooMuchEnd
end

local function buildError(code, msg, topMsg, input, start, stop)
   local builder = f('error[%s]: %s\n   ┌─ input\n   │\n   │ %s\n   │ ', code, topMsg, input)

   local below = string.rep(' ', start - 1) ..
      string.rep('^', stop - start + 1) ..
      ' ' .. msg

   return builder .. below
end

local function merge(tbl1, tbl2)
   local res = {}

   for i = 1, #tbl1 do
      table.insert(res, tbl1[i])
   end

   for i = 1, #tbl2 do
      table.insert(res, tbl2[i])
   end

   return res
end

local conversions = {
   -- + Too many
   -- - Too little
   -- nil Matches
   --
   -- Read until too many or a flag appears
   {
      '%?',
      function(ctx, args)
         return #args < 2 and args or nil,
            #args > 1 and 'Expected 0 or 1 ' .. ctx.type .. 's' or nil,
            #args > 1 and '+' or nil
      end,
      '0 or 1'
   },
   {
      '%*',
      function(_, args)
         return args -- No way * can fail since its 0+
      end,
      '0 or more'
   },
   {
      '%+',
      function(ctx, args)
         return #args > 0 and args or nil,
            #args == 0 and 'Expected 1 or more ' .. ctx.type .. 's' or nil,
            #args == 0 and '-' or nil
      end,
      '1 or more'
   },
   {
      '(%d+)%-(%d+)',
      function(ctx, args, min, max)
         min = tonumber(min)
         max = tonumber(max)

         return #args >= min and #args <= max and args or nil,
            #args < min or #args > max and f('Expected %s to %s %ss', min, max, ctx.type),
            min >= #args and '-' or max < #args and '+' or nil
      end,
      '%s'
   },
   {
      '(%d+)',
      function(ctx, args, count)
         count = tonumber(count)

         return #args == count and args or nil,
            #args ~= count and f('Expected %s %ss', count, ctx.type) or nil,
            count > #args and '-' or count < #args and '+' or nil
      end,
      '%s'
   }
}

--- An argument parser which can be used in part with commands
---@class ArgParser
---@field private _flags ArgParser.modifiers[]
local ArgParser = discordia.class('ArgParser')

--- struct
---@class ArgParser.rawArgs
---@field public flags table<string, string[]>
---@field public arguments string[]
local _rawArgs = {} -- shut documentation generator

--- Modify how flags are parsed
---@class ArgParser.modifiers
---@field public required fun(bool: boolean): ArgParser.modifiers Changes if the flag is required or not
---@field public args fun(amount: string): ArgParser.modifiers Changes the amount of required arguments
---@field public finish fun(): ArgParser Finish configuring the flag and return back to the parser
---@field private status fun(args: string[]): ArgParser.statuses
---@field private humanArg string
local _modifiers = {}

---@alias ArgParser.statuses
---| "'+'"
---| "'-'"

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
   local usage = ''

   for i = 1, #self._arguments do
      usage = usage .. ' <' .. self._arguments[i][2] .. '>'
   end

   for i, v in pairs(self._flags) do
      if v._ctx.required then
         usage = usage .. ' --' .. i .. ' <' .. v._ctx.type .. '>'
      else
         usage = usage .. ' [--' .. i .. (v._ctx.type == 'boolean' and '' or '<' .. v._ctx.type .. '>' ) .. ']'
      end
   end

   command:usage(usage)

   command:check(function(_, args, client)
      local succ, err = self:parse(table.concat(args, ' '), client)
      return succ and true or 'PARSE_FAIL', err and '```\n' .. err .. '\n```' or nil
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
---@return ArgParser.modifiers
function ArgParser:flag(name, func, typeName)
   local check, flagType

   if type(func) == 'function' then
      check = func
      flagType = typeName
      -- self._flags[name] = {func, typeName}
   elseif type(func) == 'string' then
      check = ArgParser.types[func]
      flagType = func
      -- self._flags[name] = {ArgParser.types[func], func}
   else
      error 'Expected function or string!'
   end

   self._flags[name] = self:_createModifier({
      type = flagType,
      original = check
   })

   return self._flags[name]
end

--- Parse the input, typechecking it along the way
---@param str string
---@param client Client
---@return table | nil
---@return string | nil
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
            f('Argument %s is required', i),
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

            table.insert(errors, buildError(
               'incorrect_argument_type',
               err,
               f('Unable to convert argument %s to %s', i, self._arguments[i][2]),
               str,
               start,
               stop
            ))
         else
            table.insert(res.arguments, succ)
         end
      end
   end

   missing = 0

   for i, v in pairs(self._flags) do
      if not raw.flags[i] and v._ctx.required then
         table.insert(errors, buildError(
            'missing_required_flag',
            f('Expected %s, got nothing', v._ctx.type),
            f('Flag %s is a required flag', i),
            str,
            #str + (missing * 3) + 1,
            #str + ((missing + 1) * 3)
         ))

         missing = missing + 1
      elseif raw.flags[i] or v._ctx.type == 'boolean' then
         local flag = raw.flags[i]

         local data, start, stop

         local succ, err, went

         local topErr = 'incorrect_flag_type'

         if v._ctx.type == 'boolean' then
            went = true
            succ = flag and true or false
         elseif #flag == 1 then
            data = {flag[1][1]}
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
            succ, err = v.check(data, client)
         end

         if succ == nil then
            local part = str:sub(start, stop)

            local tooMuchStart, tooMuchEnd = #part:match('(%s*).*'), #part:match('^.-(%s*)$')

            start = start + tooMuchStart
            stop = stop - tooMuchEnd

            table.insert(errors, buildError(
               topErr,
               err,
               f('Unable to convert flag %s to %s', i, v._ctx.type),
               str,
               start,
               stop
            ))
         else
            res[i] = succ
         end
      end
   end

   return #errors == 0 and res or nil, #errors > 0 and table.concat(errors, '\n') or nil
end

--- Internal function for creating modifier packages
---@param ctx table
---@return ArgParser.modifiers
function ArgParser:_createModifier(ctx)
   function ctx.argCheck(args)
      return args
   end

   local modifiers = {
      _ctx = ctx
   }

   if ctx.type == 'boolean' then
      ctx.required = false
   end

   function modifiers.required(bool)
      ctx.required = bool

      return modifiers
   end

   function modifiers.choices(choices)
      ctx.choices = choices

      return modifiers
   end

   function modifiers.args(count)
      for i = 1, #conversions do
         local pat, func, human = conversions[i][1], conversions[i][2], conversions[i][3]

         if count:match(pat) then
            modifiers.argCheck = function(passedCtx, args)
               return func(passedCtx, args, count:match(pat))
            end

            if human:match('%%') then
               modifiers.humanArg = f(human, count)
            else
               modifiers.humanArg = human
            end

            break
         end
      end

      return modifiers
   end

   function modifiers.finish()
      modifiers.status = function(args)
         local _, _, status = modifiers.argCheck(ctx, args)

         return status
      end

      modifiers.check = function(args, ...)
         local succ, err = modifiers.argCheck(ctx, args)

         if not succ then
            return nil, err
         else
            local new = {}

            for i = 1, #args do
               local originalSucc, originalErr = ctx.original(args[i], ...)

               if not originalSucc then
                  return nil, originalErr
               else
                  table.insert(new, originalSucc)
               end
            end

            return new
         end
      end

      return self
   end

   return modifiers
end

--- Internal function for parsing arguments, doesn't enforce types or anything else
---
--- It also leaves a lot of fragments like symbol positions
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

   local currentFlag

   local errors = {}

   local i = 1

   while i < #split + 1 do
      local v = split[i]

      local lastI = i

      if v:sub(0, 1) ~= '-' then
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
         local name = v:match('%-%-?(.*)')

         if name:sub(0, 1) == '-' then
            table.insert(errors, buildError(
               'invalid_flag',
               f('Expected 1 or 2 dashes, got %s', #v:match('([%-]*)')),
               'Flags start with either 1 or 2 dashes',
               str,
               where(str, ' ', lastI - 1),
               where(str, ' ', lastI - 1) + #v:match('([%-]*)')
            ))
         elseif not self._flags[name] then
            local names = {}

            for flagName in pairs(self._flags) do
               table.insert(names, flagName)
            end

            local last = table.remove(names)

            local namesStr = table.concat(names, ', ')

            table.insert(errors, buildError(
               'invalid_flag_name',
               f('Expected %s, got %s', (namesStr ~= '' and namesStr .. ' or ' or '') .. last, name),
               f('Unable to locate flag with the name of %s', name),
               str,
               between(str, ' ', lastI - 1, i)
            ))
         else
            currentFlag = name

            res.flags[currentFlag] = {pos = {where(str, ' ', i - 1), where(str, ' ', i)}}

            -- We can ditch skipping by eating until i == nil, i + 1 == '+' or another flag appears

            local flag = self._flags[currentFlag]

            local check = flag.status

            local args = {}

            local matched = false

            local k = i + 1

            while k < #split + 1 do
               local part = split[k]

               local lastK = k

               if part:sub(0, 1) == '"' or part:sub(0, 1) == "'" then
                  local quoted, _, ate, err = eatUntilEnd(table.concat(split, ' ', k):sub(2), part:sub(0, 1), ' ')

                  part = quoted

                  k = k + ate

                  if err then
                     table.insert(errors, err)
                  end
               end

               if part:sub(0, 1) == '-' then
                  -- Start of new flag
                  k = k - 1 -- Rewind to not eat flag
                  break
               end

               table.insert(args, {part, where(str, ' ', lastK - 1), where(str, ' ', k)})

               local currentI, peekedI = check(args), check(merge(args, {split[k + 1]}))

               if currentI == nil and peekedI == '+' then
                  matched = true
                  break -- Stop reading, next is too many
               elseif currentI == nil then
                  matched = true
               end

               k = k + 1
            end

            args.pos = {between(str, ' ', lastI - 1, i)}

            if not matched then
               table.insert(errors, buildError(
                  'invalid_argument_amount',
                  f('Found only %s argument%s', #args, #args ~= 0 and 's' or ''),
                  f('There should be %s arguments, got %s', flag.humanArg, #args),
                  str,
                  args.pos[1],
                  where(str, ' ', k) - 1
               ))
            end

            -- Not our job to typecheck them
            res.flags[currentFlag] = args

            i = k
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