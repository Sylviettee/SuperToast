---@type Command
local command = require('classes/Command')
local sub = require('classes/Subcommand')

local stringx = require('utils/stringx')
local ms = require('utils/ms')

local help = command('help'):description('Get help on a specific command'):usage('<name>'):example('help')

help:execute(function(msg, args, client)
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

   builder = builder(flags.guild_only and '✅' or '❌')
   builder = builder(flags.nsfw_only and '✅' or '❌')

   builder = builder(table.concat(cmd.user_permissions, ', ') == '' and 'none' or
                         table.concat(cmd.user_permissions, ', '))
   builder =
       builder(table.concat(cmd.bot_permissions, ', ') == '' and 'none' or table.concat(cmd.bot_permissions, ', '))

   msg:reply(tostring(builder))
end)

local all = sub(help, 'all'):description('Get all the commands')

all:execute(function(msg, _, client)
   local cmds = ''

   client.commands:forEach(function(_, cmd)
      cmds = cmds .. cmd.name .. ', '
   end)

   cmds = cmds:sub(0, #cmds - 2)

   msg:reply(cmds)
end)

return help
