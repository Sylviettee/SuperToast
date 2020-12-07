-- Converts Discordia doc comments into EmmyLua doc comments for types
-- Uses code from Discordia doc generator
-- CONSTANTS --
local HANDWRITTEN_IN = './other.template'
local OUT = './libs/types/discordia.lua'
local IN = './deps/discordia/libs'

-- Fun time --

local fs = require('fs')
local pathjoin = require('pathjoin')

local insert, sort, concat = table.insert, table.sort, table.concat
local f = string.format
local pathJoin = pathjoin.pathJoin

local function scan(dir)
   for fileName, fileType in fs.scandirSync(dir) do
      local path = pathJoin(dir, fileName)
      if fileType == 'file' then
         coroutine.yield(path)
      else
         scan(path)
      end
   end
end

local function match(s, pattern) -- only useful for one capture
   return assert(s:match(pattern), s)
end

local function gmatch(s, pattern, hash) -- only useful for one capture
   local tbl = {}
   if hash then
      for k in s:gmatch(pattern) do
         tbl[k] = true
      end
   else
      for v in s:gmatch(pattern) do
         insert(tbl, v)
      end
   end
   return tbl
end

local function matchType(s)
   return s:match('^@(%S+)')
end

local function matchComments(s)
   return s:gmatch('--%[=%[%s*(.-)%s*%]=%]')
end

local function matchClassName(s)
   return match(s, '@c (%S+)')
end

local function matchMethodName(s)
   return match(s, '@m (%S+)')
end

local function matchDescription(s)
   return match(s, '@d (.+)'):gsub('%s+', ' ')
end

local function matchParents(s)
   return gmatch(s, 'x (%S+)')
end

local function matchReturns(s)
   return gmatch(s, '@r (%S+)')
end

local function matchTags(s)
   return gmatch(s, '@t (%S+)', true)
end

local function matchMethodTags(s)
   return gmatch(s, '@mt (%S+)', true)
end

local function matchProperty(s)
   local a, b, c = s:match('@p (%S+) (%S+) (.+)')
   return {name = assert(a, s), type = assert(b, s), desc = assert(c, s):gsub('%s+', ' ')}
end

local function matchParameters(s)
   local ret = {}
   for optional, paramName, paramType in s:gmatch('@(o?)p (%S+) (%S+)') do
      insert(ret, {paramName, paramType, optional == 'o'})
   end
   return ret
end

local function matchMethod(s)
   return {
      name = matchMethodName(s),
      desc = matchDescription(s),
      parameters = matchParameters(s),
      returns = matchReturns(s),
      tags = matchTags(s)
   }
end

----

local docs = {}

local function newClass()

   local class = {methods = {}, statics = {}, properties = {}}

   local function init(s)
      class.name = matchClassName(s)
      class.parents = matchParents(s)
      class.desc = matchDescription(s)
      class.parameters = matchParameters(s)
      class.tags = matchTags(s)
      class.methodTags = matchMethodTags(s)
      assert(not docs[class.name], 'duplicate class: ' .. class.name)
      docs[class.name] = class
   end

   return class, init

end

for f in coroutine.wrap(scan), IN do

   local d = assert(fs.readFileSync(f))

   local class, initClass = newClass()
   for s in matchComments(d) do
      local t = matchType(s)
      if t == 'c' then
         initClass(s)
      elseif t == 'm' then
         local method = matchMethod(s)
         for k, v in pairs(class.methodTags) do
            method.tags[k] = v
         end
         method.class = class
         insert(method.tags.static and class.statics or class.methods, method)
      elseif t == 'p' then
         insert(class.properties, matchProperty(s))
      end
   end
end

local writing = f('-- Do not touch, automatically generated!\n-- Generated on %s\n\n', os.date())

local function convert(tp)
   if tp == 'uv_timer' then
      return 'userdata'
   elseif not tp:match('%-') then
      return tp:gsub('/', ' | '):gsub('*', 'any')
   elseif tp:lower():match('id') then
      local resolving, id = tp:match('(%w+)%-.-%-(%w*)')

      local multi = false

      if id:sub(#id, #id) == 's' then
         resolving = resolving .. '[]'
         multi = true
      end

      return resolving .. ' | string' .. (multi and '[]' or '')
   else

      if tp == 'Base64-Resolveable' or tp == 'Base64-Resolvable' then
         return 'string'
      elseif tp == 'Permission-Resolvables' then
         return 'number[]'
      elseif tp == 'Color-Resolvable' then
         return 'number | Color'
      elseif tp == 'Emoji-Resolvable' then
         return 'Emoji | Reaction | string'
      elseif tp == 'Permissions-Resolvable' then
         return 'Permissions | number'
      elseif tp == 'Permissions-Resolvables' then
         return 'Permissions[] | number[]'
      elseif tp == 'Message-Flag-Resolvable' then
         return 'number'
      end
   end
end

local function descFunc(method)
   local func = '---' .. method.desc .. '\n'
   local inParen = ''

   for i, param in pairs(method.parameters) do
      if param[1] ~= '...' then
         func = func .. f('---@param %s %s\n', param[1], convert(param[2]))
      else
         func = func .. f('---@vararg %s\n', convert(param[2]):gsub('%[%]', ''))
      end

      inParen = inParen .. f('%s%s', param[1], i == #method.parameters and '' or ', ')
   end

   local new = {}

   for i, v in pairs(method.returns) do
      new[i] = convert(v)
   end

   func = func .. f('---@return %s\n', concat(new, ' '))

   return func, inParen
end

local function descInlineFunc(method)
   local func = 'fun('

   for i, param in pairs(method.parameters) do
      if param[1] ~= '...' then
         func = func .. f('%s: %s%s', param[1], convert(param[2]), i ~= #method.parameters and ', ' or '')
      else
         func = func .. '...'
      end
   end

   local new = {}

   for i, v in pairs(method.returns) do
      new[i] = convert(v)
   end

   return func .. '):' .. concat(new, ', ')
end

for _, class in pairs(docs) do
   writing = writing .. f('---%s\n---@class %s', class.desc, class.name)

   -- Handle parents

   for _, parent in pairs(class.parents) do
      writing = writing .. ': ' .. parent
   end

   writing = writing .. '\n'

   -- Fields

   for _, fields in pairs(class.properties) do
      writing = writing .. f('---@field public %s %s %s\n', fields.name, convert(fields.type), fields.desc)
   end

   -- Create table

   writing = writing .. f('local %s = {}\n---@type %s | %s\n%s = %s\n', class.name, class.name, descInlineFunc({
      parameters = class.parameters,
      returns = {class.name}
   }), class.name, class.name)

   -- Methods

   for _, method in pairs(class.methods) do
      local func, inParen = descFunc(method)

      writing = writing .. f('%sfunction %s:%s(%s) end\n', func, class.name, method.name, inParen)
   end

   for _, method in pairs(class.statics) do
      local func, inParen = descFunc(method)

      writing = writing .. f('%sfunction %s.%s(%s) end\n', func, class.name, method.name, inParen)
   end

   -- Init method
   local func, inParen = descFunc({
      desc = f('Create a new %s', class.name),
      parameters = class.parameters,
      returns = {class.name}
   })
   writing = writing .. f('%sfunction %s:%s(%s) end\n', func, class.name, '__init', inParen)

   writing = writing .. '\n'
end

-- Fill out mixin

local handWritten = fs.readFileSync(HANDWRITTEN_IN)

local discordia = require('discordia')

local enums = discordia.enums

local enum_descs = {}
local fields = {}

for i, v in pairs(enums) do
   if i ~= 'enum' then
      table.insert(fields, '---@field public ' .. i .. ' enums.' .. i)
      local desc = '--- ' .. i .. ' enum'

      desc = desc .. '\n---@class enums.' .. i

      for name, val in pairs(v) do
         desc = desc ..
                    f('\n---@field public %s %s | "%s"', name, type(val),
                      type(val) == 'string' and f('\'%s\'', val) or val)
      end

       desc = desc .. '\n\n'

      table.insert(enum_descs, desc)
   end
end

-- Fill out package

local typed = require('typed')
local package = discordia.package
local whatIs = typed.whatIs

local desc = '---@class package\n'

for i, v in pairs(package) do
   local val = (type(v) == 'table' and '') or ' | "' .. ((type(v) == 'string' and f('\'%s\'', v)) or tostring(v)) .. '"'
   desc = desc .. f('---@field public %s %s%s\n', i, whatIs(v), val)
end

handWritten = handWritten:gsub('%-%-%s?@enums', table.concat(enum_descs, '\n') .. table.concat(fields, '\n'))
handWritten = handWritten:gsub('%-%-%s?@package', desc)

writing = writing .. '\n\n' .. handWritten

fs.writeFileSync(OUT, writing)
