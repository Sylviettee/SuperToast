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
---@module typed
local typed = {}
local f = string.format

-- We use rawget for strict.lua and linting
local unpack = rawget(_G, "unpack") or rawget(table, 'unpack')


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

local function isLuvit()
   local succ = pcall(require, 'core')

   -- If a module called core exists, set the LUA environment variable
   if rawget(_G, 'LUA') then
      return false
   end

   return succ
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
      typed.func(_, self.__keyType, self.__valueType)(k, v)
      tbl[k] = v
   end

   setmetatable(tbl, mt)

   return tbl
end

-- Detect a luvit environment and use the correct class system
local class = require((isLuvit() and './' or '') .. 'middleclass')

-- Classes

--- An array to store data within
---@class Array
local Array = class 'Array'

Array.__name = 'Array'

--- Create a new array
---@param starting any[]
---@return Array
function Array:initialize(starting)
   self._data = starting or {}
end

--- Get the length of the array
---
--- Warning: This requires lua5.2 compat, use :len instead if you don't have 5.2 compat
---@return number
function Array:__len()
   return #self._data
end

--- Loop over the array
---
--- Warning: This requires lua5.2 compat, use :forEach or :pairs instead if you don't have 5.2 compat
function Array:__pairs()
   local function func(tbl, k)
      local v
      k, v = next(tbl, k)

      if v then
         return k, v
      end
   end

   return func, self._data, nil
end

--- Get the length of the array without metamethods
---@return number
function Array:len()
   return #self._data
end

--- Loop over the array without metamethods
function Array:pairs()
   local i = 0

   return function()
      i = i + 1

      return self._data[i] and i or nil, self._data[i]
   end
end

--- Get an item at a specific index
---@param k number The key to get the value of
---@return any
function Array:get(k)
   return self._data[k]
end

--- Set an item at a specific index
---@param k number
---@param v any
function Array:set(k, v)
   self._data[k] = v
end

--- Iterate over an array
function Array:iter()
   local i = 0

   return function()
      i = i + 1

      return self._data[i]
   end
end

--- Unpack the array
function Array:unpack()
   return unpack(self._data)
end

--- Add an item to the end of an array
---@param item any The item to add
function Array:push(item)
   table.insert(self._data, item)
end

--- Concat an array
---@param sep string
function Array:concat(sep)
   return table.concat(self._data, sep)
end

--- Pop the item from the end of the array and return it
---@param pos number The position to pop
function Array:pop(pos)
   return table.remove(self._data, pos)
end

--- Loop over the array and call the function each time
---@param fn fun(val:any, key: number):void
function Array:forEach(fn)
   for i, v in self:pairs() do
      fn(i, v)
   end
end

--- Loop through each item and each item that satisfies the function gets added to an array and gets returned
---@param fn fun(val:any):void
---@return Array
function Array:filter(fn)
   local arr = Array()

   for _, v in self:pairs() do
      if fn(v) then
         arr:push(v)
      end
   end

   return arr
end

--- Return the first value which satisfies the function
---@param fn fun(val:any):boolean
---@return any,number | nil
function Array:find(fn)
   for i, v in self:pairs() do
      if fn(v) then
         return v, i
      end
   end
end

--- Similar to array:find except returns what the function returns as long as its truthy
---@param fn fun(val:any):any
---@return any, number | nil
function Array:search(fn)
   for i, v in self:pairs() do
      local res = fn(v)

      if res then
         return res, i
      end
   end
end

--- Create a new array based on the results of the passed function
---@param fn fun(val:any):any
---@return Array
function Array:map(fn)
   local arr = Array()

   for _, v in self:pairs() do
      arr:push(fn(v))
   end

   return arr
end

--- Slice an array using start, stop, and step
---@param start number The point to start the slice
---@param stop number The point to stop the slice
---@param step number The amount to step by
---@return Array
function Array:slice(start, stop, step)
   local arr = Array()

   for i = start or 1, stop or #self, step or 1 do
      arr:push(self._data[i])
   end

   return arr
end

--- Copy an array into a new array
---@return Array
function Array:copy()
   local ret = {}

   for k, v in self:pairs() do
      ret[k] = v
   end

   return Array:new(ret)
end

--- Reverse an array, does not affect original array
---@return Array
function Array:reverse()
   local clone = self:copy()
   local tbl = {}

   for i = 1, clone:len() do
      tbl[i] = clone:pop()
   end

   return Array:new(tbl)
end

typed.Array = Array

--- A typed version of an array only allowing certain elements within
---@class TypedArray: Array
local TypedArray = class ('TypedArray', Array)

--- Create a new typed array
---@param arrType string
---@param starting string
---@return TypedArray
function TypedArray:initialize(arrType, starting)
   Array.initialize(self)

   typed.func(_, 'string')(arrType)

   self._type = typed.func(_, arrType)

   self.__name = 'TypedArray<' .. arrType .. '>'

   for _, v in pairs(starting or {}) do
      self:push(v)
   end
end

--- A typed version of the push method
---@param item any The type of the item should be the specified type
function TypedArray:push(item)
   self._type(item)

   table.insert(self._data, item)
end

typed.TypedArray = TypedArray

--- The schema object used to validate tables
---@class Schema
local Schema = class 'Schema'

Schema.schemas = {}
Schema.__name = 'Schema' -- Typed

--- Create a new schema
---@param name string
---@return Schema
function Schema:initialize(name)
   typed.func(_, 'string')(name)

   assert(not Schema.schemas[name], 'The schema name must be unique!')

   self.name = name

   Schema.schemas[name] = self
   self._fields = {}
end

--- Create a new field within the schema
---@param name string
---@param value string | Schema
---@param default any
---@return Schema
function Schema:field(name, value, default)
   typed.func(_, 'string', 'string | Schema')(name, value)

   if default ~= nil then
      if type(value) == 'table' then
         assert(value._id[1]:validate())
      else
         typed.func(_, 'string', 'string | Schema', value)(name, value, default)
      end
   end

   self._fields[name] = {value, default}

   return self
end

--- Validate a table to see if it matches the schema
---@param tbl table<any, any>
---@return table<any, any> | boolean, string | nil
function Schema:validate(tbl)
   local _, err = typed.resolve('table<string, any>', 1, 'validate')(tbl)

   --- Ignore if it is some sort of table since `any` works weird for some reason
   if not typed.whatIs(tbl):match('table') then
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

typed.Schema = Schema

return typed
