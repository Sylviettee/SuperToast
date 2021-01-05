---@type discordia
local discordia = require('discordia')

local typed = require('typed')

---@type Command
local Command = require('classes/Command')
---@type Array
local Array = require('classes/Array')

local tFunc = typed.func(nil, 'function')

local tablex = discordia.extensions.table

--- A subcommand to act as a mini command
---@class Subcommand: Command
local Subcommand, get = discordia.class('Subcommand', Command)

---@type Subcommand | fun(parent: Command, name: string): Subcommand
Subcommand = Subcommand

--- Create a new command
---@param parent Command
---@param name string
function Subcommand:__init(parent, name)
   Command.__init(self, name)

   parent:addSubcommand(self)

   self._parent = parent
end

--- Count the amount of parents up this subcommand has
---@return number
function Subcommand:count()
   return 1 + (self._parent and self._parent:count() or 0)
end

--- Sets the function to execute
---@param func fun(msg:Message, args: string[], client: SuperToastClient)
---@return Command
function Subcommand:execute(func)
   tFunc(func)

   self._execute = function(msg, args, client, ctx)
      func(msg, tablex.slice(args, 2), client, ctx)
   end

   return self
end

function get.isSub()
   return true
end

return Subcommand
