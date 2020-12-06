--- The SuperToast module
---@class SuperToast
local SuperToast = {
   Array = require('classes/Array'),
   Client = require('classes/Client'),
   Command = require('classes/Command'),
   Embed = require('classes/Embed'),
   TypedArray = require('classes/TypedArray'),
   Option = require('classes/Option'),
   Subcommand = require('classes/Subcommand'),

   commandHandler = require('utils/commandHandler'),
   dotenv = require('utils/dotenv'),
   errorResolver = require('utils/errorResolver'),
   help = require('utils/help'),
   ms = require('utils/ms'),
   stringx = require('utils/stringx'),
   typed = require('typed')
}

return SuperToast
