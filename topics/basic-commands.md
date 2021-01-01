# Basic Commands

## The Command Handler

In SuperToast, commands are handled a bit different then what most solutions do.

First, lets go with what SuperToast does that most other command handlers do:

```
msg -> parsing -> finding command fitting the command name or alias -> if a subcommand exists, splice and go to subcommand
```

Most command handlers tend to bake the handling logic within the command handler, SuperToast does not.

SuperToast instead bakes the handling logic like permission checks into the command.

Now lets go onto creating commands.

## Ping command

To create a command, simply create an instance of a command and add it to the client.

```lua
-- ...

local ping = toast.Command('ping')

client:addCommand(ping)
```

This isn't very useful on its own and will in fact cause an error trying to run the command.

Lets add an execute handler.

```lua
-- ...

local ping = toast.Command('ping')

---@param msg Message
ping:execute(function(msg)
   msg:reply('Pong!')
end)

client:addCommand(ping)
```

Whenever the command is called, it will call the function specified in execute.

There is a lot more you can add onto commands then just execute.