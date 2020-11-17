--- Dotenv parsing module
---@module dotenv
local dotenv = {}

local stringx = require 'utils/stringx'

local match, gsub
do
   local _obj_0 = require('rex')
   match, gsub = _obj_0.match, _obj_0.gsub
end

local readFileSync = require('fs').readFileSync
local resolve = require('path').resolve

local NEWLINE = '\n'
local RE_INI_KEY_VAL = [[^\s*([\w.-]+)\s*=\s*(.*)?\s*$]]
local RE_NEWLINES = [[\\n]]

--- Parse a dotenv file and return the data
---@param src string
---@param options table<string, boolean>
---@return table<string, any>
function dotenv.parse(src, options)
   local debug = options and options.debug
   local obj = {}
   for idx, line in pairs(stringx.split(src, NEWLINE)) do
      local keyValueArr = {match(line, RE_INI_KEY_VAL)}
      if keyValueArr ~= nil and #keyValueArr ~= 0 then
         local key = keyValueArr[1]
         local value = keyValueArr[2] or ''
         local endPos = #value
         local isDoubleQuoted = value:sub(1, 1) == '"' and value:sub(endPos, endPos) == '"'
         local isSingleQuoted = value:sub(1, 1) == '\'' and value:sub(endPos, endPos) == '\''
         if isSingleQuoted or isDoubleQuoted then
            value = value:sub(2, endPos - 1)
            if isDoubleQuoted then
               value = gsub(value, RE_NEWLINES, NEWLINE)
            end
         else
            value = stringx.trim(value)
         end
         obj[key] = value
      elseif debug then
         print('Line ' .. tostring(idx) .. ' >> ' .. tostring(line) .. '\nFailed to parse')
      end
   end
   return obj
end

--- Load a .env file into the current env
---@param options table<string, any>
function dotenv.config(options)
   if options == nil then
      options = {}
   end

   local path = options.path or resolve(process.cwd(), '.env')
   local encoding = options.encoding or 'utf8'
   local debug = options.debug or false
   local succ, parsed = pcall(function()
      parsed = dotenv.parse(readFileSync(path, {encoding = encoding}), {debug = debug})
      for i, v in pairs(parsed) do
         if not process.env[i] then
            process.env[i] = v
         else
            print(tostring(i) .. ' is already defined in process.env and will not be overwritten')
         end
      end
      return parsed
   end)

   if succ then
      return parsed
   else
      return {error = parsed}
   end
end

return dotenv
