local class = require('discordia').class

---@type Command
local Command = require('classes/Command')

--- A subcommand to act as a mini command
---@class Subcommand: Command
local Subcommand, get = class('Subcommand', Command)

--- Create a new command
function Subcommand:__init(parent, name)
   Command.__init(self, name)

   parent:add_subcommand(self)
end

-- Add some restrictions

function Subcommand:add_subcommand()
   error 'Subcommands can\'t have subcommands!'
end

function get:isSub()
   return true
end

return Subcommand
