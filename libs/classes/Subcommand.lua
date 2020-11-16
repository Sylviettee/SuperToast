local class = require('discordia').class

---@type Command
local Command = require('classes/Command')

--- A subcommand to act as a mini command
---@class Subcommand: Command
---@field private _parent Command
local Subcommand = class('Subcommand', Command)

--- Create a new command
function Subcommand:__init(parent, name, ...)
   Command.__init(self, name, ...)

   parent:add_subcommand(self)
end

return Subcommand
