--- The SuperToast module
---@class SuperToast
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
   stringx = require('utils/stringx')
}

return SuperToast
