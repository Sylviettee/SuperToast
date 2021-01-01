---@type discordia
local discordia = require('discordia')

local stringx = require('utils/stringx')
local tablex = discordia.extensions.table

--- Default command handler
---@param client SuperToastClient
---@param msg Message
return function(client, msg)
   local pre = client.config.prefix

   if msg.author.bot then
      return
   end

   if type(pre) == 'function' then
      pre = pre(msg)
   end

   pre = type(pre) == 'string' and {pre} or pre

   local foundPre

   for _, v in pairs(pre) do
      if stringx.startswith(msg.content, v) then
         foundPre = v
         break
      end
   end

   if not foundPre then
      return
   end

   local cleaned = foundPre:gsub('[%(%)%.%%%+%-%*%?%[%]%^%$]', function(c)
      return '%' .. c
   end)

   local command = msg.content:gsub('^' .. cleaned, '')

   local split = stringx.split(command, ' ')

   command = split[1]

   if not command or command == '' then
      return
   end

   local args = tablex.slice(split, 2)

   local found = client.commands:find(function(cmd)
      return cmd.name == command or cmd.aliases:find(function(alias)
         return alias == command
      end)
   end)

   if found then
      local toRun, errMsg = found:toRun(msg, args, client)

      if type(toRun) == 'string' then
         msg:reply(client.config.errorResolver(found, toRun, errMsg))
      else
         local succ, err = pcall(toRun, msg, args, client)

         if not succ then
            msg:reply('Something went wrong, try again later')

            client:error(err)
         end
      end
   end
end
