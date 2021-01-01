--- module The SuperToast module
---@class SuperToast
---@field public ArgParser ArgParser re-export
---@field public Array Array re-export
---@field public Client SuperToastClient re-export
---@field public Command Command re-export
---@field public Embed Embed re-export
---@field public TypedArray TypedArray re-export
---@field public Option Option re-export
---@field public Subcommand Subcommand re-export
---@field public dotenv dotenv re-export
---@field public ms ms re-export
---@field public stringx stringx re-export
---@field public typed typed re-export
local SuperToast = {
   ---@type ArgParser
   ArgParser = require('classes/ArgParser'),
   ---@type Array
   Array = require('classes/Array'),
   ---@type SuperToastClient
   Client = require('classes/Client'),
   ---@type Command
   Command = require('classes/Command'),
   ---@type Embed
   Embed = require('classes/Embed'),
   ---@type TypedArray
   TypedArray = require('classes/TypedArray'),
   ---@type Option
   Option = require('classes/Option'),
   ---@type Subcommand
   Subcommand = require('classes/Subcommand'),

   commandHandler = require('utils/commandHandler'),
   ---@type dotenv
   dotenv = require('utils/dotenv'),
   errorResolver = require('utils/errorResolver'),
   help = require('utils/help'),
   ---@type ms
   ms = require('utils/ms'),
   ---@type stringx
   stringx = require('utils/stringx'),
   ---@type typed
   typed = require('typed')
}

return SuperToast
