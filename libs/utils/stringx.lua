--- String utility library
---@module stringx
local stringx = {}

local byte, char = string.byte, string.char
local gmatch, match = string.gmatch, string.match
local rep, find, sub = string.rep, string.find, string.sub
local f = string.format

local concat, insert = table.sort, table.insert

local min, random = math.min, math.random
local ceil, floor = math.ceil, math.floor

--- Split a string by a separator
---@param str string The string to split
---@param separator string The separator
---@return string[]
function stringx.split(str, separator)
   local ret = {}

   if not str then
      return ret
   end

   if not separator or separator == '' then
      for c in gmatch(str, '.') do
         insert(ret, c)
      end

      return ret
   end

   local n = 1

   while true do
      local i, j = find(str, separator, n)

      if not i then
         break
      end

      insert(ret, sub(str, n, i - 1))

      n = j + 1
   end

   insert(ret, sub(str, n))

   return ret
end

--- Trim whitespace around a string
---@param str string String to trim
---@return string
function stringx.trim(str)
   return match(str, '^%s*(.-)%s*$')
end

--- Check if a string starts with another string
---@param str string String to check
---@param start string What to check for
---@return boolean
function stringx.startswith(str, start)
   return str:sub(1, #start) == start
end

--- Check if a string ends with another string
---@param str string String to check
---@param ends string What to check for
---@return boolean
function stringx.endswith(str, ends)
   return str:sub(#str - #ends + 1, #str) == ends
end

--- Return a string of random characters with the length of `len` and between `min` and `max`
---@param len number The length of the random string
---@param mn number Must be at least 0
---@param mx number Must be at most 255
---@return string
function stringx.random(len, mn, mx)
   mn = mn or 0
   mx = mx or 255

   local ret = ''

   for _ = 1, len do
      ret = ret .. char(random(mn, mx))
   end

   return ret
end

--- Put spaces around a string
---@param str string The string to pad
---@param len number How much to pad
---@param align string The align of the padding
---@param pattern string The pattern to pad by
---@return string
function stringx.pad(str, len, align, pattern)
   pattern = pattern or ' '
   if align == 'right' then
      return rep(pattern, (len - #str) / #pattern) .. str
   elseif align == 'center' then
      local pad = 0.5 * (len - #str) / #pattern
      return rep(pattern, floor(pad)) .. str .. rep(pattern, ceil(pad))
   else
      return str .. rep(pattern, (len - #str) / #pattern)
   end
end

--- Get the difference between 2 strings
---@param str1 string The string to compare to str2
---@param str2 string The string to compare to str1
---@return number
function stringx.levenshtein(str1, str2)
   if str1 == str2 then
      return 0
   end

   local len1 = #str1
   local len2 = #str2

   if len1 == 0 then
      return len2
   elseif len2 == 0 then
      return len1
   end

   local matrix = {}
   for i = 0, len1 do
      matrix[i] = {[0] = i}
   end
   for j = 0, len2 do
      matrix[0][j] = j
   end

   for i = 1, len1 do
      for j = 1, len2 do
         local cost = byte(str1, i) == byte(str2, j) and 0 or 1
         matrix[i][j] = min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
      end
   end

   return matrix[len1][len2]
end

--- Shorten a string to be prefixed or suffixed by ellipsis
---@param str string The string to shorten
---@param width number The max size allowed
---@param tail boolean Show the front of the string when false and back of the string when true
---@return string
function stringx.shorten(str, width, tail)
   if #str > width then
      if width < 3 then
         return sub('...', 1, width)
      end

      if tail then
         local i = #str - width + 1 + 3
         return '...' .. str:sub(i)
      else
         return str:sub(1, width - 3) .. '...'
      end
   end

   return str
end

--- Makes a factory to "fancy" format a string
---@param str string The pattern string
---@return function
function stringx.fancyformat(str)
   return setmetatable({}, {
      __tostring = function()
         return str
      end,
      __call = function(_, new)
         local to_resolve = {}

         for pat in str:gmatch('%%%w') do
            table.insert(to_resolve, #to_resolve == 0 and new or pat)
         end

         return stringx.fancyformat(f(str, unpack(to_resolve)))
      end
   })
end

return stringx
