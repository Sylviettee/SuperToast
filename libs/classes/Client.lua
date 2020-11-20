local discordia = require('discordia')

local class = discordia.class

---@type stringx
local stringx = require('utils/stringx')

---@type TypedArray
local TypedArray = require('classes/TypedArray')

---@type Option
local Option = require('classes/Option')

local ch = require('utils/commandHandler')
local er = require('utils/errorResolver')

local clientOptions = Option({
   prefix = {'string', nil, '!'},
   defaultHelp = {'boolean', nil, true},
   commandHandler = {'function', nil, ch, 'toast.commandHandler'},
   errorResolver = {'function', nil, er, 'toast.errorResolver'},
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
---@field public commandHandler fun(client: SuperToastClient, msg: Message) | "toast.commandHandler"
---@field public errorResolver fun(cmd: Command, err: string):string | "toast.errorResolver"
---@field public defaultHelp boolean | "true"
---@field public owners string[] | "{}"
---@field public prefix string | "'!'"

--- The SuperToast client with all the fun features
---@class SuperToastClient: Client
---@field commands TypedArray
---@field config SuperToastOptions
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

   ---@type SuperToastOptions
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
      self._config.commandHandler(self, msg)
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

function get:commands()
   return self._commands
end

function get:config()
   return self._config
end

return Helper
