local class = require('discordia').class
local typed = require('typed')

---@type Command
local Command = require('classes/Command')
---@type Array
local Array = require('classes/Array')

local tFunc = typed.func(_, 'function')

--- A subcommand to act as a mini command
---@class Subcommand: Command
local Subcommand, get = class('Subcommand', Command)

--- Create a new command
function Subcommand:__init(parent, name)
   Command.__init(self, name)

   parent:add_subcommand(self)

   self._parent = parent
end

--- Count the amount of parents up this subcommand has
function Subcommand:count()
   return 1 + (self._parent and self._parent:count() or 0)
end

--- Sets the function to execute
---@param func fun(msg:Message, args: string[], client: SuperToastClient):void
---@return Command
function Command:execute(func)
   tFunc(func)

   self._execute = function(msg, args, client)
      local _ = Array(args)

      func(msg, _:slice(2), client)
   end

   return self
end

function get:isSub()
   return true
end

return Subcommand
