local discordia = require('discordia')
local pathjoin = require('pathjoin')
local fs = require('fs')

local class = discordia.class

local splitPath = pathjoin.splitPath

---@type TypedArray
local TypedArray = require('classes/TypedArray')

---@type typed
local typed = require('typed')

local ch = require('utils/commandHandler')
local er = require('utils/errorResolver')


local clientOptions = typed.Schema('clientConfig')
   :field('prefix', 'string | string[] | function', '!')
   :field('owners', 'string[] | unknown[]', {})
   :field('commandHandler', 'function', ch)
   :field('errorResolver', 'function', er)

local f = string.format

--- struct The options to pass to the discordia client
---@class DiscordiaOptions
---@field public maxRetries number
---@field public cacheAllMembers boolean
---@field public firstShard number
---@field public autoReconnect boolean
---@field public gatewayFile string
---@field public shardCount number
---@field public syncGuilds boolean
---@field public compress boolean
---@field public dateTime string
---@field public logLevel number
---@field public bitrate number
---@field public routeDelay number
---@field public logFile string
---@field public largeThreshold number
---@field public lastShard number
local _discordiaOptions = {}

--- struct The options to pass to the SuperToast client
---@class SuperToastOptions
---@field public commandHandler fun(client: SuperToastClient, msg: Message) The function to call to handle a command
---@field public errorResolver fun(cmd: Command, err: string):string The function to call to parse an error message
---@field public owners string[] The ids of the people who own the bot
---@field public prefix string | string[] | fun(msg: Message):string | string[] The prefix/prefixes/function to call to get a prefix/prefixes
local _supertoastOptions = {}

--- The SuperToast client with all the fun features
---@class SuperToastClient: Client
---@field public commands TypedArray
---@field public config SuperToastOptions
---@field public owners string[]
---@field public mentionPrefix string
local SuperToastClient, get = class('SuperToast Client', discordia.Client)

---@type SuperToastClient | fun(token: string, opts: SuperToastOptions, discOpts: DiscordiaOptions): SuperToastClient
SuperToastClient = SuperToastClient

--- Create a new SuperToast client
---@see SuperToastOptions
---@see DiscordiaOptions
---@param token string
---@param options SuperToastClient
---@param discOptions DiscordiaOptions
---@return SuperToastClient
function SuperToastClient:__init(token, options, discOptions)
   discordia.Client.__init(self, discOptions)

   assert(token, 'A token must be passed!')

   ---@type SuperToastOptions
   self._config = assert(clientOptions:validate(options or {}))
   self._token = token

   self._commands = TypedArray 'Command'

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
function SuperToastClient:login(presence)
   self:run('Bot ' .. self._token)

   if presence then
      self:setGame(presence)
   end
end

--- Register a command to the client
---@param command Command
function SuperToastClient:addCommand(command)
   self._commands:push(command)
end

--- Remove a subcommand from the client
---@param command Command
function SuperToastClient:removeCommand(command)
   local _, i = self._commands:find(function(val)
      return val.name == command.name
   end)

   if i then
      self._commands:pop(i)
   end
end


local function parseFile(obj, files)
   if type(obj) == 'string' then
      local data, err = fs.readFileSync(obj)
      if not data then
         return nil, err
      end
      files = files or {}
      table.insert(files, {table.remove(splitPath(obj)), data})
   elseif type(obj) == 'table' and type(obj[1]) == 'string' and type(obj[2]) == 'string' then
      files = files or {}
      table.insert(files, obj)
   else
      return nil, 'Invalid file object: ' .. tostring(obj)
   end
   return files
end

local function parseMention(obj, mentions)
   if type(obj) == 'table' and obj.mentionString then
      mentions = mentions or {}
      table.insert(mentions, obj.mentionString)
   else
      return nil, 'Unmentionable object: ' .. tostring(obj)
   end
   return mentions
end

--- Send a reply to a message
---@param msg Message
---@param content string | table
---@param mention boolean
---@return Message
function SuperToastClient:reply(msg, content, mention)
   local data, err

   if type(content) == 'table' then
      local tbl = content
      content = tbl.content

      if type(tbl.code) == 'string' then
         content = f('```%s\n%s\n```', tbl.code, content)
      elseif tbl.code == true then
         content = f('```\n%s\n```', content)
      end

      local mentions
      if tbl.mention then
         mentions, err = parseMention(tbl.mention)
         if err then
            return nil, err
         end
      end

      if type(tbl.mentions) == 'table' then
         for _, men in ipairs(tbl.mentions) do
            mentions, err = parseMention(men, mentions)

            if err then
               return nil, err
            end
         end
      end

      if mentions then
         table.insert(mentions, content)
         content = table.concat(mentions, ' ')
      end

      local files

      if tbl.file then
         files, err = parseFile(tbl.file)
         if err then
            return nil, err
         end
      end

      if type(tbl.files) == 'table' then
         for _, file in ipairs(tbl.files) do
            files, err = parseFile(file, files)
            if err then
               return nil, err
            end
         end
      end

      data, err = self._api:createMessage(msg.channel.id, {
         content = content,
         tts = tbl.tts,
         nonce = tbl.nonce,
         embed = tbl.embed,
         message_reference = {
            message_id = msg.id,
            channel_id = msg.channel.id
         },
         allowed_mentions = {
            replied_user = mention or false
         }
      }, files)
   else
      data, err = self._api:createMessage(msg.channel.id, {
         content = content,
         message_reference = {
            message_id = msg.id,
            channel_id = msg.channel.id
         },
         allowed_mentions = {
            replied_user = mention or false
         }
      })
   end

   if data then
      return msg.channel._messages:_insert(data)
   else
      return nil, err
   end
end

function get:commands()
   return self._commands
end

function get:owners()
   return self._config.owners or {}
end

function get:config()
   return self._config
end

function get:mentionPrefix()
   return '<@' .. self.user.id .. '>'
end

return SuperToastClient
