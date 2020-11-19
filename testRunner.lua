---@type SuperToast
_G.toast = require './init'

-- Hide typed outputs
_G._TEST = true

-- Prevent early exiting from typed
os.exit = function()
   error(os.error)
end

require 'busted.runner'({standalone = false})
