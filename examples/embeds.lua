---@type SuperToast
local toast = require './init'
local cmd = toast.Command
local Embed = toast.Embed

toast.dotenv.config()

local client = toast.Client(process.env.TOKEN)

local embed = cmd('embed')
   :execute(function(msg)
      local myEmbed = Embed()
         :setTitle("Test embed")
         :setDescription("This is fun")

      myEmbed:send(msg.channel)
   end)

client:addCommand(embed)

client:login()
