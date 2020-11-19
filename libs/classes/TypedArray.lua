local class = require('discordia').class
local Array = require('classes/Array')
local typed = require('utils/typed')

local f = string.format

--- A typed version of an array only allowing certain elements within
---@class TypedArray: Array
---@field public type function The type of the data
local TypedArray, get = class('TypedArray', Array)

function TypedArray:__init(arrType, starting)
   Array.__init(self, starting)

   typed.func(_, 'string')(arrType)

   self._type = typed.func(_, arrType)
end

--- A typed version of the push method
---@param item any The type of the item should be the specified type
function TypedArray:push(item)
   self._type(item)

   table.insert(self._data, item)
end

function get:type()
   return self._type
end

return TypedArray
