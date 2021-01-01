local discordia = require('discordia')
local enums = discordia.enums
local class = discordia.class

local typed = require('typed')

local tString = typed.func(nil, 'string')
local tNumber = typed.func(nil, 'number')

do
--- struct The raw data within an embed
---@class Embed.raw
---@field public title string | nil title of embed
---@field public type string | nil type of embed (always "rich" for webhook embeds)
---@field public description string | nil description of embed
---@field public url string | nil url of embed
---@field public timestamp string | nil ISO8601 timestamp of embed content
---@field public color number | nil color code of the embed
---@field public footer Embed.footer | nil footer information
---@field public image Embed.image | nil image information
---@field public thumbnail Embed.thumbnail | nil thumbnail information
---@field public video Embed.video | nil video information
---@field public provider Embed.provider | nil provider information
---@field public author Embed.author | nil author information
---@field public fields Embed.field[] | nil fields information
local _raw = {}

--- struct
---@class Embed.footer
---@field public text string footer text
---@field public icon_url string | nil url of footer icon (only supports http(s) and attachments)
---@field public proxy_icon_url string | nil a proxied url of footer icon
_raw.footer = {}

--- struct
---@class Embed.field
---@field public name string name of the field
---@field public value string value of the field
---@field public inline boolean | nil whether or not this field should display inline
_raw.field = {}

--- struct
---@class Embed.thumbnail
---@field public url string | nil source url of the thumbnail(only supports http(s) and attachments)
---@field public proxy_url string | nil a proxied url of the thumbnail
---@field public height number | nil height of the thumbnail
---@field public width number | nil width of the thumbnail
_raw.thumbnail = {}

--- struct
---@class Embed.image
---@field public url string | nil source url of the thumbnail(only supports http(s) and attachments)
---@field public proxy_url string | nil a proxied url of the thumbnail
---@field public height number | nil height of the thumbnail
---@field public width number | nil width of the thumbnail
_raw.image = {}

--- struct
---@class Embed.video
---@field public url string | nil source url of video
---@field public height number | nil height of the video
---@field public width number | nil width of the video
_raw.video = {}

--- struct
---@class Embed.provider
---@field public name string | nil name of provider
---@field public url string | nil url of provider
_raw.provider = {}

--- struct
---@class Embed.author
---@field public name string | nil name of author
---@field public url string | nil url of author
---@field public icon_url string | nil url of author icon (only supports http(s) and attachments)
---@field public proxy_icon_url string | nil a proxied url of author icon
_raw.author = {}
end

--- An embed class to allow structuring embeds easier
---@class Embed
local Embed = class('Embed')

---@type Embed | fun(starting: Embed): string
Embed = Embed

--- Create a new embed
---@param starting table
function Embed:__init(starting)
   self._embed = starting or {}

   assert(type(self._embed) == 'table', 'The starting type must be a table')
end

--- Set the title of the embed
---@param title string
---@return Embed
function Embed:setTitle(title)
   tString(title)

   self._embed.title = title:sub(0, 256)

   return self
end

--- Set the description of the embed
---@param desc string
---@return Embed
function Embed:setDescription(desc)
   tString(desc)

   self._embed.description = desc:sub(2048)

   return self
end

--- Set the color of the embed
---@param color number
---@return Embed
function Embed:setColor(color)
   tNumber(color)

   self._embed.color = color

   return self
end

--- Add a field to the embed
---@param name string
---@param value string
---@param inline boolean
---@param ignore boolean
---@return Embed
function Embed:addField(name, value, inline, ignore)
   inline = inline or false

   typed.func(nil, 'string', 'string', 'boolean')(name, value, inline)

   self._embed.fields = self._embed.fields or {}

   if #self._embed.fields >= 25 then
      if not ignore then
         print 'Embed is at max fields!'
      end
   else
      table.insert(self._embed.fields, {name = name:sub(0, 256), value = value:sub(0, 1024), inline = inline})
   end

   return self
end

--- Set the author of the embed
---@param name string
---@param icon string
---@param url string
---@return Embed
function Embed:setAuthor(name, icon, url)
   icon = icon or ''
   url = url or ''

   typed.func(nil, 'string', 'string', 'string')(name, icon, url)

   self._embed.author = {name = name:sub(0, 256), icon_url = icon, url = url}

   return self
end

--- Set the footer of the embed
---@param text string
---@param icon string
---@return Embed
function Embed:setFooter(text, icon)
   icon = icon or ''

   typed.func(nil, 'string', 'string')(text, icon)

   self._embed.footer = {text = text:sub(0, 2048), icon_url = icon}

   return self
end

--- Set the image of the embed
---@param img string
---@return Embed
function Embed:setImage(img)
   tString(img)

   self._embed.image = {url = img}

   return self
end

--- Set the thumbnail of the embed
---@param url string
---@return Embed
function Embed:setThumbnail(url)
   tString(url)

   self._embed.thumbnail = {url = url}

   return self
end

--- Set the timestamp of the embed
---@param date string
---@return Embed
function Embed:setTimestamp(date)
   date = date or os.date('!%Y-%m-%dT%TZ')

   tString(date)

   self._embed.timestamp = date

   return self
end

--- Set the url of the embed
---@return Embed
function Embed:setURL(url)
   tString(url)

   self._embed.url = url

   return self
end

--- Return the contents within the embed
function Embed:toJSON()
   return self._embed
end

--- Send an embed to a channel
---@param channel TextChannel
---@return Message | nil
---@return string | nil
function Embed:send(channel)
   if channel.guild then
      ---@type Permissions
      local perms = channel.guild.me:getPermissions(channel)

      if perms:has(enums.permission.embedLinks) then
         return channel:send({embed = self:toJSON()})
      else
         return channel:send('I do not have permissions to send embeds!')
      end
   else
      -- Private channel
      return channel:send({embed = self:toJSON()})
   end
end

return Embed
