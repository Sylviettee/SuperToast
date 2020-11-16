local class = require('discordia').class
local Array = require('classes/Array')

local f = string.format

--- A typed version of an array only allowing certain elements within
---@class TypedArray: Array
---@field public type function The type of the data
local TypedArray, get = class('TypedArray', Array)

function TypedArray:__init(arrType, starting)
   Array.__init(self, starting)

   assert(type(arrType) == 'string' or type(arrType) == 'function',
          f('Expected string | function, instead got %s', type(arrType)))

   self._type = type(arrType) == 'string' and function(v)
      return class.type(v) == arrType -- Allow classes to be their own type without defining new functions
   end or arrType

   self._desc = type(arrType) == 'string' and arrType or 'array type'
end

--- A typed version of the push method
---@param item any The type of the item should be the specified type
function TypedArray:push(item)
   assert(self._type(item), f('The item passed must be %s', self._desc))

   table.insert(self._data, item)
end

function get:type()
   return self._type
end

return TypedArray
