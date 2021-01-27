---@type discordia
local discordia = require('discordia')

---@type Command
local command = require('classes/Command')
local sub = require('classes/Subcommand')

local stringx = require('utils/stringx')
local ms = require('utils/ms')

local tablex = discordia.extensions.table

local help = command('help')
   :description('Get help on a specific command')
   :usage('<name> [subcommand]')
   :example('help')
   :example('help all')

---@param msg Message
---@param args string[]
---@param client SuperToastClient
help:execute(function(msg, args, client, ctx)
   if not args[1] then
      local cmd = help.subcommands:find(function(x)
         return x.name == 'all'
      end).rawExecute

      return cmd(msg, args, client, ctx)
   end

   ---@type Command
   local cmd = client.commands:search(function(comm)
      local q = args[1]

      local inAliases = comm.aliases:find(function(x)
         return x == q
      end)

      if comm.name == q or inAliases then
         if #args >= 2 then
            return comm.subcommands:find(function(x)
               return x.name == args[2]
            end)
         else
            return comm
         end
      end
   end)

   if not cmd then
      return msg:reply 'We are unable to find that command.'
   end

   -- Stray away from embeds
   local builder = stringx.fancyformat [[```adoc
=== Help ===
Name        :: %s
Aliases     :: %s
Cooldown    :: %s
Usage       :: %s
Example     :: %s
Subcommands :: %s
=== Flags ===
Guild only  :: %s
NSFW only   :: %s
=== Requirements ===
Perms       :: %s
Bot Perms   :: %s
```]]

   builder = builder(cmd.name)
   builder = builder(cmd.aliases:concat(', ') == '' and 'none' or cmd.aliases:concat(', '))
   builder = builder(cmd.getCooldown and ms.formatLong(cmd.getCooldown) or 'none')
   builder = builder(cmd.name .. ' ' .. (cmd.getUsage and cmd.getUsage or ''))

   if #cmd.getExamples < 2 then
      builder = builder(#cmd.getExamples == 1 and cmd.getExamples:get(1) or 'none')
   else
      local str = '\n'

      for i, v in pairs(cmd.getExamples) do
         str = str .. '- ' .. v .. (i == #cmd.getExamples and '' or '\n')
      end

      builder = builder(str)
   end

   local subs = ''

   for i, v in pairs(cmd.subcommands) do
      subs = subs .. v.name .. (i == #cmd.subcommands and '' or ', ')
   end

   builder = builder(subs == '' and 'none' or subs)

   local flags = cmd.flags

   builder = builder(flags.guildOnly and '✅' or '❌')
   builder = builder(flags.nsfwOnly and '✅' or '❌')

   builder = builder(
      table.concat(cmd.userPermissions, ', ') == '' and 'none' or
      table.concat(cmd.userPermissions, ', ')
   )

   builder = builder(
      table.concat(cmd.botPermissions, ', ') == '' and 'none' or
      table.concat(cmd.botPermissions, ', ')
   )

   msg:reply(tostring(builder))
end)

local all = sub(help, 'all'):description('Get all the commands')

---@param msg Message
---@param client SuperToastClient
---@param ctx Command_additionalContext
all:execute(function(msg, _, client, ctx)
   local toReply = string.format([[```adoc
==== Bot help ====
Use `%shelp [command] [subcommand]` for more in depth information
]], ctx.prefix)

   local sections = {}

   ---@param val Command
   client.commands:forEach(function(_, val)
      if val.flags.ownerOnly and not tablex.search(client.owners, msg.author.id) then
         return
      end

      local cat = val.getCategory or 'Misc'

      if not sections[cat] then
         sections[cat] = {}
      end

      local desc = val.getDescription or ''

      desc = desc:match('\n') and desc:match('(.-)\n') or desc

      table.insert(sections[cat], '- ' .. val.name .. (desc ~= '' and ' - ' .. desc or ''))
   end)

   for name, descriptions in pairs(sections) do
      toReply = toReply .. '\n' .. '=== ' .. name .. ' ===\n' .. table.concat(descriptions, '\n')
   end

   msg:reply(toReply .. '```')
end)

return help
