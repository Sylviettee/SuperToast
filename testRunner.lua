---@type SuperToast
_G.toast = require './init'

-- Hide typed outputs
_G._TEST = true

-- Prevent early exiting from typed
rawset(os, 'exit', function()
   error(rawget(os, 'error'))
end)

require 'busted.runner'({standalone = false})
