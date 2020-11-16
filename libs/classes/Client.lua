local discordia = require 'discordia'

local class = discordia.class

---@type stringx
local stringx = require 'utils/stringx'

---@type TypedArray
local TypedArray = require 'classes/TypedArray'

---@type Option
local Option = require 'classes/Option'

local clientOptions = Option({
   prefix = {'string', nil, '!'},
   defaultHelp = {'boolean', nil, true},
   owners = {'table', 'string[]', {}, '{}'}
})

local f = string.format

---@class DiscordiaOptions
---@field public maxRetries number | "5"
---@field public cacheAllMembers boolean | "false"
---@field public firstShard number | "0"
---@field public autoReconnect boolean | "true"
---@field public gatewayFile string | "'gateway.json'"
---@field public shardCount number | "0"
---@field public syncGuilds boolean | "false"
---@field public compress boolean | "true"
---@field public dateTime string | "'%F %T'"
---@field public logLevel number | "3"
---@field public bitrate number | "64000"
---@field public routeDelay number | "250"
---@field public logFile string | "'discordia.log'"
---@field public largeThreshold number | "100"
---@field public lastShard number | "-1"

---@class SuperToastOptions
---@field public defaultHelp boolean | "true"
---@field public owners string[] | "{}"
---@field public prefix string | "'!'"

--- The SuperToast client with all the fun features
---@class SuperToastClient: Client
---@field private _config SuperToastOptions
---@field private _token string
---@field private _commands TypedArray
---@field private _events TypedArray
---@field private _cogs TypedArray
local Helper, get = class('SuperToast Client', discordia.Client)

--- Create a new SuperToast client
---@see SuperToastOptions
---@see DiscordiaOptions
---@param token string
---@param options SuperToastClient
---@param discOptions DiscordiaOptions
---@return SuperToastClient
function Helper:__init(token, options, discOptions)
   discordia.Client.__init(self, discOptions)

   assert(token, 'A token must be passed!')

   self._config = clientOptions:validate(options or {})
   self._token = token

   self._commands = TypedArray 'Command'
   self._events = TypedArray 'Event'
   self._cogs = TypedArray 'Cog'

   self:on('ready', function()
      self:info('%s is ready!', self.user.tag)
   end)

   ---@param msg Message
   self:on('messageCreate', function(msg)
      local pre = self._config.prefix

      if not stringx.startswith(msg.content, pre) then
         return
      end

      if msg.author.bot then
         return
      end

      local command = string.match(msg.content, pre .. '(%S+)'):lower()

      if not command then
         return
      end

      local args = {}

      for arg in string.gmatch(string.match(msg.content, pre .. '%S+%s*(.*)'), '%S+') do
         table.insert(args, arg)
      end

      local found = self._commands:find(function(cmd)
         return cmd.name == command or cmd.aliases:find(function(alias)
            return alias == command
         end)
      end)

      if found then
         local toRun = found:toRun(msg, args)

         if type(toRun) == 'string' then
            return toRun -- TODO; use config table
         else
            local succ, err = pcall(toRun, msg, args)

            if not succ then
               msg:reply('Something went wrong, try again later')

               self:error(err)
            end
         end
      end
   end)
end

--- Connect and login
---@param presence nil | table<string, any>
function Helper:login(presence)
   self:run('Bot ' .. self._token)

   if presence then
      self:setGame(presence)
   end
end

--- Register a command to the client
---@param command Command
function Helper:addCommand(command)
   self._commands:push(command)
end

return Helper
