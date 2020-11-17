local discordia = require('discordia')
local enums = discordia.enums
local class = discordia.class

--- An embed class to allow structuring embeds easier
---@class Embed
local Embed = class('Embed')

--- Create a new embed
---@param starting table
function Embed:__init(starting)
   self._embed = starting or {}

   assert(type(self._starting) == 'table', 'The starting type must be a table')
end

--- Set the title of the embed
---@param title string
---@return Embed
function Embed:setTitle(title)
   assert(type(title) == 'string', 'The title must be a string')
   self._embed.title = title:sub(0, 256)

   return self
end

--- Set the description of the embed
---@param desc string
---@return Embed
function Embed:setDescription(desc)
   assert(type(desc) == 'string', 'The description must be a string')

   self._embed.description = desc:sub(2048)

   return self
end

--- Set the color of the embed
---@param color number
---@return Embed
function Embed:setColor(color)
   assert(type(color) == 'number', 'The color must be a number')

   self._embed.color = color

   return self
end

--- Add a field to the embed
---@param name string
---@param value string
---@param inline boolean
---@return Embed
function Embed:addField(name, value, inline)
   assert(type(name) == 'string', 'The name must be a string')
   assert(type(value) == 'string', 'The value must be a string')

   self._embed.fields = self._embed.fields or {}

   if #self._embed.field >= 25 then
      print 'Embed is at max fields!'
   else
      table.insert(self._embed.fields, {name = name:sub(0, 256), value = value:sub(0, 1024), inline = inline or false})
   end

   return self
end

--- Set the author of the embed
---@param name string
---@param icon string
---@param url string
---@return Embed
function Embed:setAuthor(name, icon, url)
   assert(type(name) == 'string', 'The name must be a string')

   self._embed.author = {name = name:sub(0, 256), icon_url = icon or '', url = url or ''}

   return self
end

--- Set the footer of the embed
---@param text string
---@param icon string
---@return Embed
function Embed:setFooter(text, icon)
   assert(type(text) == 'string', 'The text must be a string')

   self._embed.footer = {text = text:sub(0, 2048), icon_url = icon or ''}

   return self
end

--- Set the image of the embed
---@param img string
---@return Embed
function Embed:setImage(img)
   assert(type(img) == 'string', 'The image must be a string')

   self._embed.image = {url = img}

   return self
end

--- Set the thumbnail of the embed
---@param url string
---@return Embed
function Embed:setThumbnail(url)
   assert(type(url) == 'string', 'The url must be a string')

   self._embed.thumbnail = {url = url}

   return self
end

--- Set the timestamp of the embed
---@param date string
---@return Embed
function Embed:setTimestamp(date)
   self._embed.timestamp = date or os.date('!%Y-%m-%dT%TZ')

   return self
end

--- Set the url of the embed
function Embed:setURL(url)
   assert(type(url) == 'string', 'The url must be a string')

   self._embed.url = url

   return self
end

--- Return the contents within the embed
function Embed:toJSON()
   return self._embed
end

--- Send an embed to a channel
---@param channel TextChannel
---@return Message
function Embed:send(channel)
   if channel.guild then
      ---@type Permissions
      local perms = channel.guild.me:getPermissions(channel)

      if perms:has(enums.permissions.embedLinks) then
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
