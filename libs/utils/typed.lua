--- A module to aid in allowing for typed code
---@module typed
local typed = {}

--- If typed should panic on invalid types
typed.panic = true

---@type stringx
local stringx = require 'utils/stringx'

---@type Array
local Array = require 'classes/Array'

---@type discordia
local discordia = require 'discordia'

local class = discordia.class

--- Is this an array?
---@param tbl table<any, any>
---@return boolean
function typed.isArray(tbl)
   for i in pairs(tbl) do
      if type(i) ~= 'number' then
         return false
      end
   end

   return true
end

--- What is this specific item?
---@param this any
---@return string
function typed.whatIs(this)
   if class.isObject(this) then
      return class.type(this)
   else
      if type(this) == 'table' then
         if typed.isArray(this) then
            if #this > 0 then
               local currentType = typed.whatIs(this[1])

               for _, v in pairs(this) do
                  if typed.whatIs(v) ~= currentType and currentType ~= 'any' then
                     currentType = 'any'
                  end
               end

               return currentType .. '[]'
            else
               return 'unknown[]'
            end
         else
            local keyType
            local valueType

            for i, v in pairs(this) do
               if not keyType then
                  keyType = typed.whatIs(i)
                  valueType = typed.whatIs(v)
               end

               if typed.whatIs(i) ~= keyType and keyType ~= 'any' then
                  keyType = 'any'
               end

               if typed.whatIs(v) ~= valueType and valueType ~= 'any' then
                  valueType = 'any'
               end
            end

            return 'table<' .. keyType .. ', ' .. valueType .. '>'
         end
      else
         return type(this)
      end
   end
end

--- Create a new function to validate types
---@param validator string
---@param pos number | nil
---@param name string | nil
---@return fun(x: any):boolean, nil | string
function typed.resolve(validator, pos, name)
   local parts = Array(stringx.split(validator, '|'))

   parts = parts:map(function(x)
      return stringx.trim(x)
   end)

   local expects = 'bad argument #' .. (pos or 1) .. ' to \'' .. (name or '?') .. '\' (' ..
                       table.concat({parts:unpack()}, ' | ') .. ' expected, got %s)'

   return function(x)
      local matches = parts:find(function(y)
         return typed.whatIs(x) == y
      end)

      if matches == nil then
         return nil, string.format(expects, typed.whatIs(x))
      else
         return true
      end
   end
end

--- Create a new typed function
---@param name string
---@vararg string
---@return fun(...):void
function typed.func(name, ...)
   local info = debug.getinfo(2)

   typed.resolve('string | nil', 1, 'typed.func')(name or info.name)

   for i, v in pairs {...} do
      assert(typed.resolve('string', i + 1, 'typed.func')(v))
   end

   local arr = {...}

   return function(...)
      local input = {...}
      for i = 1, #arr do
         local newInfo = debug.getinfo(2)

         local succ, err = typed.resolve(arr[i], i, name or newInfo.name)(input[i])

         if not succ then
            if not _TEST then
               print(debug.traceback(string.format('Uncaught exception:\n%s:%u: %s', newInfo.short_src,
                                                   newInfo.currentline, err), 3))
            else
               -- Instead store the error within os
               os.error = err
            end

            if typed.panic then
               os.exit(-1)
            else
               print 'The code is now unstable now as panicking has been disabled!'
            end
         end
      end
   end
end

return typed
