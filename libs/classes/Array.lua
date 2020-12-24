local class = require('discordia').class

--- An array to store data within
---@class Array
local Array = class('Array')

---@type Array | fun(starting: any): Array
Array = Array

function Array:__init(starting)
   self._data = starting or {}
end

--- Get the length of the array
---@return number The length of the array
function Array:__len()
   return #self._data
end

--- Loop over the array
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
   for i, v in pairs(self) do
      fn(i, v)
   end
end

--- Loop through each item and each item that satisfies the function gets added to an array and gets returned
---@param fn fun(val:any):void
---@return Array
function Array:filter(fn)
   local arr = Array()

   for _, v in pairs(self) do
      if fn(v) then
         arr:push(v)
      end
   end

   return arr
end

--- Return the first value which satisfies the function
---@param fn fun(val:any):boolean
---@return any,number|nil
function Array:find(fn)
   for i, v in pairs(self) do
      if fn(v) then
         return v, i
      end
   end
end

--- Similar to array:find except returns what the function returns as long as its truthy
---@param fn fun(val:any):any
---@return any, number|nil
function Array:search(fn)
   for i, v in pairs(self) do
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

   for _, v in pairs(self) do
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

   for k, v in pairs(self._data) do
      ret[k] = v
   end

   return Array(ret)
end

--- Reverse an array, does not affect original array
---@return Array
function Array:reverse()
   local clone = self:copy()
   local tbl = {}

   for i = 1, #clone do
      tbl[i] = clone:pop()
   end

   return Array(tbl)
end

return Array
