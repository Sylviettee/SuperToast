---@type SuperToast
local toast = require './init'
local cmd = toast.Command

toast.dotenv.config()

local client = toast.Client(process.env.TOKEN)

local ping = cmd('ping')
   :execute(function(msg)
      msg:reply 'pong!'
   end)

client:addCommand(ping)

client:login()
