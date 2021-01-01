local toast = require 'SuperToast'

toast.dotenv.config()

local client = toast.Client(process.env.TOKEN)

local greetCmd = toast.Command('greet')

local greetParser = toast.ArgParser()
   :flag('users', 'user')
      .args('+')
      .finish()

greetCmd:execute(function(msg, args)
   local greet = ''

   for i = 1, #args.users do
      greet = greet .. 'Hello ' .. args.users[i].username .. '!\n'
   end

   msg:reply(greet)
end)

greetParser:attach(greetCmd)
client:addCommand(greetCmd)

client:login()