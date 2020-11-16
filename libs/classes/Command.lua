local discordia = require('discordia')

---@type stringx
local stringx = require('utils/stringx')
---@type TypedArray
local TypedArray = require('classes/TypedArray')

local class = discordia.class
local enums = discordia.enums

--- The command class to handle most functionality
---@class Command
---@field private _examples TypedArray[]
---@field private _aliases TypedArray[]
---@field private _user_roles TypedArray[]
---@field private _bot_roles TypedArray[]
---@field private _user_permissions TypedArray[]
---@field private _bot_permissions TypedArray[]
---@field private _checks TypedArray[]
---@field private _subcommands TypedArray[]
---@field private _cooldowns table<string, number>
---@field private _execute function
---@field private _description string
---@field private _usage string
---@field private _name string
---@field private _guild_only boolean
---@field private _nsfw_only boolean
---@field private _cooldown number
local Command, get = class('Command')

--- Create a new command
---
--- Possible fail codes
--- * GUILD_ONLY - The command must be ran in a guild
--- * NSFW_ONLY - The command must be ran in a nsfw channel
--- * MISSING_PERMISSIONS - The user is missing permissions
--- * SELF_MISSING_PERMISSIONS - The bot is missing permissions
--- * MISSING_ROLES - The user is missing roles
--- * SELF_MISSING_ROLES - The bot is missing roles
--- * CUSTOM_* - Custom check error codes
---@param name string
---@vararg string
---@return Command
function Command:__init(name, ...)
   assert(type(name) == 'string', 'The command name must be a string')
   self._name = name

   for _, v in pairs({...}) do
      assert(type(v) == 'string', 'The command aliases must be strings')
   end

   self._examples = TypedArray 'string'
   self._aliases = TypedArray 'string'
   self._user_roles = TypedArray 'string'
   self._bot_roles = TypedArray 'string'
   self._user_permissions = TypedArray 'number'
   self._bot_permissions = TypedArray 'number'
   self._checks = TypedArray 'function'
   self._subcommands = TypedArray 'Subcommand'
end

--- Check a message to see if it matches all the criteria listed
---@param message Message
---@param args string[]
---@return boolean
function Command:toRun(message, args)
   local isSub = self._subcommands:find(function(v)
      return v.name == args[1]
   end)

   if isSub then
      return isSub:toRun(message)
   end

   -- TODO the other checks

   ---@type GuildTextChannel
   local channel = message.channel

   -- Guild and nsfw checks

   if self._guild_only and not message.guild then
      return 'GUILD_ONLY'
   end

   if self._nsfw_only and not channel.nsfw then
      return 'NSFW_ONLY'
   end

   -- At this point we have a guild/member

   local member = message.member
   local me = message.guild.me

   -- Permissions

   local user_perms = member:getPermissions(channel)
   local bot_perms = me:getPermissions(channel)

   if not user_perms:has(self._user_permissions:unpack()) then
      return 'MISSING_PERMISSIONS'
   end

   if not bot_perms:has(self._bot_permissions:unpack()) then
      return 'SELF_MISSING_PERMISSIONS'
   end

   -- Roles

   local find = function(s)
      return function(role)
         return role.id == s or role.name == s
      end
   end

   local user_roles = member.roles
   local bot_roles = me.roles

   for role in self._user_roles:iter() do
      if not user_roles:find(find(role)) then
         return 'MISSING_ROLES'
      end
   end

   for role in self._bot_roles:iter() do
      if not bot_roles:find(find(role)) then
         return 'SELF_MISSING_ROLES'
      end
   end

   -- Custom checks

   for check in self._checks:iter() do
      local res = check(message, args)
      if res ~= true then
         return 'CUSTOM' .. tostring(res)
      end
   end

   return self._execute
end

--- Attach a description to a command
---@param desc string
---@return Command
function Command:description(desc)
   assert(type(desc) == 'string', 'The description must be a string')

   self._description = desc

   return self
end

--- Attach a usage to a command
---@param usage string
---@return Command
function Command:usage(usage)
   assert(type(usage) == 'string', 'The usage must be a string')

   self._usage = usage

   return self
end

--- Set the command as guild only
---@return Command
function Command:guild_only()
   self._guild_only = true

   return self
end

--- Set the command as nsfw only
---@return Command
function Command:nsfw_only()
   self:guild_only() -- nsfw channels only exist in guilds

   self._nsfw_only = true

   return self
end

--- Set the cooldown of the command
---@param cooldown number
---@return Command
function Command:cooldown(cooldown)
   assert(type(cooldown) == 'number', 'The cooldown must be a number')

   self._cooldown = cooldown

   return self
end

--- Add a custom check to the command
---@param check fun(msg: Message, args: string[]):string|boolean
---@return Command
function Command:check(check)
   self._checks:push(check) -- Will automatically be checked

   return self
end

--- Add multiple custom checks
---@vararg function
---@return Command
function Command:check_any(...)
   local funcs = {...}
   for _, v in pairs(funcs) do
      assert(type(v) == 'function', 'The check must be a function')
   end

   self:check(function(msg, args)
      for _, v in pairs(funcs) do
         if v(msg, args) == true then
            return true
         end
      end

      return 'FAILED_ALL_CHECKS'
   end)
end

--- Add permission check for users
---@param perm string|number
---@return Command
function Command:has_permission(perm)
   self:guild_only()

   if type(perm) == 'string' then
      assert(enums.permission[perm], 'The permission must exist')

      self._user_permissions:push(enums.permission[perm])
   else
      self._user_permissions:push(perm)
   end

   return self
end

--- Add multiple permission checks for users
---@vararg string|number
---@return Command
function Command:has_permissions(...)
   for _, v in pairs({...}) do
      self:has_permission(v)
   end

   return self
end

--- Add permission check for the bot
---@param perm string|number
---@return Command
function Command:bot_has_permission(perm)
   self:guild_only() -- Permissions only exist in guilds

   if type(perm) == 'string' then
      assert(enums.permission[perm], 'The permission must exist')

      self._bot_permissions:push(enums.permission[perm])
   else
      self._bot_permissions:push(perm)
   end

   return self
end

--- Add multiple permission checks for the bot
---@vararg string|number
---@return Command
function Command:bot_has_permissions(...)
   for _, v in pairs({...}) do
      self:bot_has_permission(v)
   end

   return self
end

--- Check if the user has a specific role
---@param role string
---@return Command
function Command:has_role(role)
   self:guild_only() -- Roles only exist in guilds

   self._user_roles:push(role)

   return self
end

--- Add a subcommand to the function
---@param subcommand Subcommand
---@return Command
function Command:add_subcommand(subcommand)
   self._subcommands:push(subcommand)

   return self
end

--- Sets the function to execute
---@param func fun(msg:Message, args: string[], client: SuperToastClient):void
---@return Command
function Command:execute(func)
   p(func)
   assert(type(func) == 'function', 'The execute callback must be a function')

   self._execute = func

   return self
end

function get:name()
   return self._name
end

function get:aliases()
   return self._aliases
end

return Command
