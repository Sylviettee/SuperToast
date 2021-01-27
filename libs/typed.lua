-- Lets just add a functional one

--- # Typed
---
--- A module to aid in allowing for typed code
---
--- Typed gives clean errors that look like errors from misused standard functions
---
--- ```
--- bad argument #1 to 'tostring' (string | function expected, got nil)
--- ```
---
--- ## Quick example
---
--- ```lua
--- local typed = require 'typed'
---
--- local function hi(msg)
---    typed.func(_, 'string')(msg)
---
---    print(msg)
--- end
---
--- hi('hello') -- No errors
--- hi(1) -- bad argument #1 to 'hi' (string expected, got number)
--- ```
---
--- Typed can automatically figure out the name of the function, however,
--- if you want to replace it, you pass the first argument.
---
--- ## Tables and arrays
---
--- Typed also supports arrays and tables in its definitions.
---
--- An array is `type` followed by `[]` while a table is `table<keyType, valueType>`.
---
--- By default, an empty table `{}` would be `unknown[]`. This is as it can't be inferred what it is.
---
--- ## Logical statements
---
--- Currently typed only supports the `or` logical operator.
---
--- ```lua
--- local typed = require 'typed'
---
--- local function hi(msg)
---    typed.func(_, 'string | number')(msg)
---
---    print(msg)
--- end
---
--- hi('hello') -- No errors
--- hi(1) -- No errors
--- ```
---
--- Here is the first example using the `or` operator represented with `|`.
---
--- It does exactly what you would think it does, it will accept strings **or** numbers.
---
---@class typed
local typed = {}
local f = string.format

--- If typed should panic on invalid types.
---
--- When set to `false`, the code might be unstable.
typed.panic = true

-- Utilities

---@alias void nil

local function split(str, separator)
   local ret = {}

   if not str then
      return ret
   end

   if not separator or separator == '' then
      for c in string.gmatch(str, '.') do
         table.insert(ret, c)
      end

      return ret
   end

   local n = 1

   while true do
      local i, j = string.find(str, separator, n)

      if not i then
         break
      end

      table.insert(ret, string.sub(str, n, i - 1))

      n = j + 1
   end

   table.insert(ret, string.sub(str, n))

   return ret
end

local function trim(str)
   return string.match(str, '^%s*(.-)%s*$')
end

local function tblTypesEq(left, right)
   local key, val = left:match('table<(.-), (.-)>')
   local rKey, rVal = right:match('table<(.-), (.-)>')

   if key == 'any' and val == rVal then
      return true
   elseif val == 'any' and key == rKey then
      return true
   elseif key == 'any' and val == 'any' then
      return true
   elseif key:match('table') and rKey:match('table') then
      return tblTypesEq(key, rKey)
   elseif val:match('table') and rVal:match('table') then
      return tblTypesEq(val, rVal)
   else
      -- TODO; handle primitives
      return false
   end
end


--- Is this an array?
---@param tbl table<any, any>
---@return boolean
function typed.isArray(tbl)
   if type(tbl) ~= 'table' then return false end

   for i in pairs(tbl) do
      if type(i) ~= 'number' then
         return false
      end
   end

   return true
end

--- What is this specific item?
---
--- Note: This can be overridden with `__name` or `__type` field.
---
--- Arrays are represented with `type[]` and tables with `table<keyType, valueType>`.
---@param this any
---@return string
function typed.whatIs(this)
   if type(this) == 'table' and (this.__name or this.__type) then
      local given = this.__name or this.__type
      if given == 'Array' then
         return typed.whatIs(this._data)
      else
         return given
      end
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
---
--- This is commonly piped into assert and should be used in environments without `debug`.
---
---@param validator string The validation string like `string | number`
---@param pos number | nil The position of where this is argument is (defaults to 1)
---@param name string | nil The name of the function (defaults to ?)
---@return fun(x: any):boolean, nil | string
function typed.resolve(validator, pos, name)
   local parts = split(validator, '|')

   for i, v in pairs(parts) do
      parts[i] = trim(v)
   end

   local expects = 'bad argument #' ..
      (pos or 1) .. ' to \'' .. (name or '?') ..
      '\' (' .. table.concat(parts, ' | ') .. ' expected, got %s)'

   return function(x)
      local matches = typed.is(validator, x)

      if matches == false then
         return nil, string.format(expects, typed.whatIs(x))
      else
         return true
      end
   end
end

--- Check if the `value` matches the `validator`.
---
--- Used internally by `typed.resolve
---@param validator string
---@param value any
---@return boolean
function typed.is(validator, value)
   -- Handle logical or statements by recalling the function until one of them is true or we go through them all
   if validator:match('|') then
      for _, v in pairs(split(validator, '|')) do
         local part = trim(v)

         if typed.is(part, value) then
            return true
         end
      end

      return false
   end

   -- Any checks are troublesome as they can be anywhere
   if validator == 'any' then
      return true
   end

   -- We match the amount of `[]` as arrays can be nested
   if validator:sub(0, 3) == 'any' and type(value) == 'table' and typed.isArray(value) then
      local left, right = validator:match('.-([%[%]].*)'), typed.whatIs(value):match('.-([%[%]].*)')

      if left:match('table') and right:match('table') then
         return tblTypesEq(left, right)
      elseif left:match('table') or right:match('table') then
         return false -- If something has a table while something else doesn't, they can't be similar
      else
         return left == right:sub(0, #left) -- Since its any, any[][] should accept any[][][] as any is anything
      end
   end

   -- Table checks are handled differently due to them being able to be nested
   -- Recursion is used to handle the nesting
   if validator:match('table') and type(value) == 'table' and not typed.isArray(value) then
      return tblTypesEq(validator, typed.whatIs(value))
   end

   -- Logical not
   if validator:sub(0, 1) == '!' then
      return validator:sub(2, #validator) ~= typed.whatIs(value)
   end

   return validator == typed.whatIs(value)
end

--- Create a new typed function.
---
--- **This function uses the debug library**
---
--- You can override the inferred name by passing a first argument.
---
--- The rest of the arguments are validation strings.
---
--- This returns a function which would take those arguments defined in the validation string.
---@param name string | nil
---@vararg string
---@return fun(...):void
function typed.func(name, ...)
   local info = debug.getinfo(2)

   assert(typed.resolve('string | nil', 1, 'typed.func')(name or info.name))

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
            -- Testing
            if not rawget(_G, '_TEST') then
               print(debug.traceback(string.format('Uncaught exception:\n%s:%u: %s', newInfo.short_src,
                                                   newInfo.currentline, err), 3))
            else
               -- Instead store the error within os
               rawset(os, 'error', err)
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

--- Create a typed dictionary allowing only specific key and value types
---@param keyType string
---@param valueType string
---@return table<any, any>
function typed.typedDict(keyType, valueType)
   local tbl = {}

   tbl.__name = 'table<' .. keyType .. ', ' .. valueType .. '>'
   tbl.__keys = keyType
   tbl.__values = valueType

   local mt = {}

   function mt:__newindex(k, v)
      typed.func(nil, self.__keyType, self.__valueType)(k, v)
      tbl[k] = v
   end

   setmetatable(tbl, mt)

   return tbl
end

---@type class
local class = require('discordia').class

--- The schema object used to validate tables
---@class Schema
local Schema, get = class 'Schema'

---@type Schema | fun(name: string): Schema
Schema = Schema

Schema.schemas = {}
Schema.__name = 'Schema' -- Typed

--- Create a new schema
---@param name string
---@return Schema
function Schema:__init(name)
   typed.func(nil, 'string')(name)

   assert(not Schema.schemas[name], 'The schema name must be unique!')

   self._name = name

   Schema.schemas[name] = self
   self._fields = {}
end

--- Create a new field within the schema
---@param name string
---@param value string | Schema
---@param default any
---@return Schema
function Schema:field(name, value, default)
   typed.func(nil, 'string', 'string | Schema')(name, value)

   if default ~= nil then
      if type(value) == 'table' then
         assert(value._id[1]:validate())
      else
         typed.func(nil, 'string', 'string | Schema', value)(name, value, default)
      end
   end

   self._fields[name] = {value, default}

   return self
end

--- Validate a table to see if it matches the schema
---@param tbl table<any, any>
---@return table<any, any> | boolean
---@return string | nil
function Schema:validate(tbl)
   local _, err = typed.resolve('table<string, any>', 1, 'validate')(tbl)

   --- Ignore if it is some sort of table since `any` works weird for some reason
   if not typed.whatIs(tbl):match('table') and not typed.whatIs(tbl):match('unknown') then
      return false, err
   end

   local obj = {}

   for i, v in pairs(self._fields) do
      tbl[i] = tbl[i] or v[2]

      obj[i] = tbl[i]

      if tbl[i] == nil and v[2] == nil then -- Defaults
         return false, f('Non-null value %s was not found', i)
      elseif type(v[1]) ~= 'table' and not typed.is(v[1], tbl[i]) then -- Type checks
         return false, f('Expected %s, got %s on field %s', v[1], typed.whatIs(tbl[i]), i)
      elseif type(v[1]) == 'table' and not v[1]:validate(tbl[i]) then
         local _, newErr = v[1]:validate(tbl[i])
         return false, f('Expected %s, got %s on field %s; %s', v[1].name, 'Malformed ' .. v[1].name, i, newErr)
      end
   end

   -- Extra fields

   for i in pairs(tbl) do
      if not self._fields[i] then
         return false, f('Unexpected field %s', i)
      end
   end

   return obj
end

function get:name()
   return self._name
end

typed.Schema = Schema

return typed
