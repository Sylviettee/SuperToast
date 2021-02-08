---@type discordia
local discordia = require('discordia')

---@type typed
local typed = require('typed')
---@type TypedArray
local TypedArray = require('classes/TypedArray')
---@type ms
local ms = require('utils/ms')

local timer = require('timer')

local class = discordia.class
local enums = discordia.enums
local tablex = discordia.extensions.table

local tString = typed.func(nil, 'string')
local tFunc = typed.func(nil, 'function')
local tFuncs = typed.func(nil, 'function[]')
local tNumber = typed.func(nil, 'number')

--- struct Flags which the command could have
---@class Command_flags
---@field public guildOnly boolean
---@field public nsfwOnly boolean
---@field public ownerOnly boolean
local _flags = {}

--- struct Additional information about the context
---@class Command_additionalContext
---@field public prefix string The prefix that was used
local _additionalContext = {}

--- The command class to handle most functionality
---@class Command
---@field public isSub boolean
---@field public name string
---@field public getDescription string
---@field public getCategory string | nil
---@field public getUsage string
---@field public getCooldown number
---@field public flags Command_flags
---@field public aliases string[]
---@field public getExamples string[]
---@field public userPermissions string[]
---@field public botPermissions string[]
---@field public subcommands Subcommand[]
---@field public rawExecute function
---@field public parent Subcommand | nil
local Command, get = class('Command')

---@type Command | fun(name: string, ...): Command
Command = Command

--- Create a new command
---@param name string | function
---@vararg string | function
function Command:__init(name, ...)
   typed.func(nil, 'string | function')(name)
   self._name = name

   self._examples = TypedArray 'string'
   self._aliases = TypedArray 'string | function'
   self._userRoles = TypedArray 'string'
   self._botRoles = TypedArray 'string'
   self._userPermissions = TypedArray 'number'
   self._botPermissions = TypedArray 'number'
   self._checks = TypedArray 'function'
   self._subcommands = TypedArray 'Subcommand'
   self._cooldowns = {}

   for i = 1 , select('#', ...) do
      self._aliases:push(select(i, ...))
   end
end

--- Check if the passed name matches what is expected
---@param name string
function Command:checkName(name)
   local validNames = {self._name}

   self._aliases:forEach(function(v)
      table.insert(validNames, v)
   end)

   for i = 1, #validNames do
      if validNames[i] == name then
         return true
      elseif type(validNames[i]) == 'function' then
         local res = validNames[i](name)

         if res then
            return res
         end
      end
   end

   return false
end

--- Check a message to see if it matches all the criteria listed
---@param message Message
---@param args string[]
---@param client SuperToastClient
---@return boolean | string
function Command:toRun(message, args, client)
   local isSub = self._subcommands:find(function(v)
      return v:checkName(args[1])
   end)

   if isSub then
      return isSub:toRun(message, tablex.slice(args, 2), client)
   end

   -- Handle subcommands first
   if self._cooldowns[message.author.id] then
      return message:reply('You are on cooldown, wait ' ..
         ms.formatLong(self._cooldowns[message.author.id] - os.time())
         .. ' longer!'
      )
   elseif self._cooldown then
      self._cooldowns[message.author.id] = os.time() + self._cooldown

      timer.setTimeout(self._cooldown * 1000, function()
         self._cooldowns[message.author.id] = nil
      end)
   end

   ---@type GuildTextChannel
   local channel = message.channel

   -- Guild and nsfw checks

   if self._guildOnly and not message.guild then
      return 'GUILD_ONLY'
   end

   if self._nsfwOnly and not channel.nsfw then
      return 'NSFW_ONLY'
   end

   local isOwner = tablex.search(client.owners, message.author.id)

   if self._ownerOnly and not isOwner then
      return 'OWNER_ONLY'
   end

   -- At this point we have a guild/member

   local member = message.member
   local me = message.guild.me

   -- Permissions

   local userPerms = member:getPermissions(channel)
   local botPerms = me:getPermissions(channel)

   if not userPerms:has(self._userPermissions:unpack()) then
      return 'MISSING_PERMISSIONS'
   end

   if not botPerms:has(self._botPermissions:unpack()) then
      return 'SELF_MISSING_PERMISSIONS'
   end

   -- Roles

   local find = function(s)
      return function(role)
         return role.id == s or role.name == s
      end
   end

   local userRoles = member.roles
   local botRoles = me.roles

   for role in self._userRoles:iter() do
      if not userRoles:find(find(role)) then
         return 'MISSING_ROLES'
      end
   end

   for role in self._botRoles:iter() do
      if not botRoles:find(find(role)) then
         return 'SELF_MISSING_ROLES'
      end
   end

   -- Custom checks

   for check in self._checks:iter() do
      local res, err = check(message, args, client)
      if res ~= true then
         return 'CUSTOM_' .. tostring(res or 'UNKNOWN'), err
      end
   end

   return self._execute
end

--- Attach a description to a command
---@param desc string
---@return Command
function Command:description(desc)
   tString(desc)

   self._description = desc

   return self
end

--- Attach a category to a command
---@param name string
---@return Command
function Command:category(name)
   tString(name)

   self._category = name

   return self
end

--- Attach an example to a command
---@param example string
---@return Command
function Command:example(example)
   self._examples:push(example)

   return self
end

--- Attach a usage to a command
---@param usage string
---@return Command
function Command:usage(usage)
   tString(usage)

   self._usage = usage

   return self
end

--- Use Command:guildOnly instead
---@deprecated
---@return Command
function Command:guild_only()
   return self:guildOnly()
end

--- Set the command as guild only
---@return Command
function Command:guildOnly()
   self._guildOnly = false

   return self
end

--- Use Command:nsfwOnly instead
---@deprecated
---@return Command
function Command:nsfw_only()
   return self:nsfwOnly()
end

--- Set the command as nsfw only
---@return Command
function Command:nsfwOnly()
   self:guildOnly() -- nsfw channels only exist in guilds

   self._nsfwOnly = true

   return self
end

--- Use Command:ownerOnly instead
---@deprecated
---@return Command
function Command:owner_only()
   return self:ownerOnly()
end

--- Set the command as owner only
---@return Command
function Command:ownerOnly()
   self._ownerOnly = true

   return self
end

--- Set the cooldown of the command
---@param cooldown number
---@return Command
function Command:cooldown(cooldown)
   tNumber(cooldown)

   self._cooldown = cooldown

   return self
end

--- Add a custom check to the command
---@param check fun(msg: Message, args: string[], client: SuperToastClient):string | boolean, string
---@return Command
function Command:check(check)
   self._checks:push(check) -- Will automatically be checked

   return self
end

--- Use Command:checkAny instead
---@deprecated
---@vararg function
---@return Command
function Command:check_any(...)
   return self:checkAny(...)
end

--- Add multiple custom checks
---@vararg function
---@return Command
function Command:checkAny(...)
   local funcs = {...}

   tFuncs(funcs)

   self:check(function(msg, args)
      for i = 1, #funcs do
         local v = funcs[i]
         if v(msg, args) == true then
            return true
         end
      end

      return 'FAILED_ALL_CHECKS'
   end)
end

--- Use Command:hasPermission instead
---@deprecated
---@param perm string | number
---@return Command
function Command:has_permission(perm)
   return self:hasPermission(perm)
end

--- Add permission check for users
---@param perm string | number
---@return Command
function Command:hasPermission(perm)
   self:guildOnly()

   if type(perm) == 'string' then
      assert(enums.permission[perm], 'The permission must exist')

      self._userPermissions:push(enums.permission[perm])
   else
      self._userPermissions:push(perm)
   end

   return self
end

--- Use Command:hasPermission instead
---@deprecated
---@vararg string | number
---@return Command
function Command:has_permissions(...)
   return self:hasPermissions(...)
end

--- Add multiple permission checks for users
---@vararg string | number
---@return Command
function Command:hasPermissions(...)
   for i = 1, select('#', ...) do
      self:hasPermission(select(i, ...))
   end

   return self
end

--- Use Command:botHasPermission instead
---@deprecated
---@param perm string | number
---@return Command
function Command:bot_has_permission(perm)
   return self:botHasPermission(perm)
end

--- Add permission check for the bot
---@param perm string | number
---@return Command
function Command:botHasPermission(perm)
   self:guildOnly() -- Permissions only exist in guilds

   if type(perm) == 'string' then
      assert(enums.permission[perm], 'The permission must exist')

      self._botPermissions:push(enums.permission[perm])
   else
      self._botPermissions:push(perm)
   end

   return self
end

--- Use Command:botHasPermissions instead
---@deprecated
---@vararg string | number
---@return Command
function Command:bot_has_permissions(...)
   return self:botHasPermission(...)
end

--- Add multiple permission checks for the bot
---@vararg string | number
---@return Command
function Command:botHasPermissions(...)
   for i = 1, select('#', ...) do
      self:botHasPermission(select(i, ...))
   end

   return self
end

--- Use Command:hasRole instead
---@deprecated
---@param role string
---@return Command
function Command:has_role(role)
   return self:hasRole(role)
end

--- Check if the user has a specific role
---@param role string
---@return Command
function Command:hasRole(role)
   self:guildOnly() -- Roles only exist in guilds

   self._userRoles:push(role)

   return self
end

--- Use Command:addSubcommand instead
---@deprecated
---@param subcommand Subcommand
---@return Command
function Command:add_subcommand(subcommand)
   self._subcommands:push(subcommand)

   return self
end

--- Add a subcommand to the function
---@param subcommand Subcommand
---@return Command
function Command:addSubcommand(subcommand)
   self._subcommands:push(subcommand)

   return self
end

--- Sets the function to execute
---@param func fun(msg:Message, args: string[], client: SuperToastClient, ctx: Command_additionalContext):void
---@return Command
function Command:execute(func)
   tFunc(func)

   self._execute = func

   return self
end

-- Static

--- Count the amount of parents up this (sub)command has
---@return number
function Command.count()
   return 0
end

--- A factory for creating commands that rely on patterns
---@param pattern string
---@return function
function Command.pattern(pattern)
   return function(content)
      return content:match(pattern)
   end
end

function get:name()
   return self._name
end

function get:aliases()
   return self._aliases
end

function get:getDescription()
   return self._description
end

function get:getExamples()
   return self._examples
end

function get:getUsage()
   return self._usage
end

function get:getCategory()
   return self._category
end

function get:flags()
   return {
      guildOnly = self._guildOnly,
      nsfwOnly = self._nsfwOnly,
      ownerOnly = self._ownerOnly
   }
end

function get:getCooldown()
   return self._cooldown
end

function get:userPermissions()
   local perms = {}

   for i = 1, #self._userPermissions do
      table.insert(perms, enums.permission(self._userPermissions[i]))
   end

   return perms
end

function get:botPermissions()
   local perms = {}

   for i = 1, #self._botPermissions do
      table.insert(perms, enums.permission(self._botPermissions[i]))
   end

   return perms
end

function get:subcommands()
   return self._subcommands
end

function get:rawExecute()
   return self._execute
end

function get.isSub()
   return false
end

return Command
