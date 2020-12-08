local class = require('discordia').class

local f = string.format

local function getInfo(v)
   local vType, name, default

   if type(v) == 'string' or type(v) == 'function' then
      vType = type(v) == 'string' and function(val)
         return type(val) == v
      end or v

      name = type(v) == 'string' and v or 'option type'
   elseif type(v) == 'table' then
      -- Validate table
      local autoName

      vType, autoName = getInfo(v[1])

      name = v[2] or autoName

      default = v[3]
   else
      error(f('Expected value to be a string | function | table, instead got %s', type(v)))
   end

   return vType, name, default, v[4]
end

--- A class to typecheck option listings
---@class Option
---@deprecated
local Option = class('Option')

function Option:__init(dict)
   -- Typecheck array
   local newDict = {}

   for i, v in pairs(dict) do
      assert(type(i) == 'string', f('Expected key %s to be a string', tostring(i)))

      newDict[i] = {getInfo(v)}
   end

   self._options = newDict
end

--- Validate a dictionary, it will error if it meets an invalid type!
---@param dict table<string, any>
---@return nil
function Option:validate(dict)
   local parsed = {}

   for i, v in pairs(self._options) do
      if dict[i] == nil and not v[3] then
         error(f('The option value, %s, is nil and no default was found', i))
      elseif dict[i] == nil and v[3] then
         dict[i] = v[3]
      end

      assert(v[1](dict[i]), f('The option value, %s, must be %s', i, v[2]))

      parsed[i] = dict[i]
   end

   return parsed
end

--- Returns a string representing the options as an EmmyLua class
---@return string
function Option:toTable()
   local str = '---@class Options\n'

   for i, v in pairs(self._options) do
      str = str .. f('---@field public %s %s%s\n', i, v[2], (function()
         if v[3] == nil then
            return ''
         else
            if type(v[3]) == 'string' then
               return ' | "\'' .. v[3] .. '\'"'
            elseif type(v[3]) ~= 'table' then
               return ' | "' .. tostring(v[3]) .. '"'
            else
               return ' | "' .. (v[4] or v[2] or tostring(v[3])) .. '"'
            end
         end
      end)())
   end

   return str
end

return Option
