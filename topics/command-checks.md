# Command Checks

## Channel Restrictions

If a command needs to be ran within a guild, a simple check can be used.

```lua
local nickname = toast.Command('nickname')
   :guildOnly() -- The `guildOnly` check makes sure that the command is ran within a guild

---@param msg Message
nickname:execute(function(msg)
   msg:reply('Your nickname is ' .. msg.member.nickname)
end)
```

If you are making your own error handler, the `GUILD_ONLY` code is thrown whenever this check fails.

If a command is considered NSFW (Not safe for work) then you can use the `:nsfwOnly` check.

```lua
local cool = toast.Command('cool')
   :nsfwOnly()

---@param msg Message
cool:execute(function(msg)
   msg:reply('This channel is cool')
end)
```

This throws a `NSFW_ONLY` code when the check fails.

## Owner Only

Sometimes you want a command to only be owner only like an eval/exec command.

This can be done with the `:ownerOnly` check.

```lua
local exec = toast.Command('exec')
   :ownerOnly()

---@param msg Message
exec:execute(function(msg, args)
   -- Don't actually do this, the process will not be cleaned up and if the stdout is >2000 characters, an error is thrown
   msg:reply(io.popen(table.concat(args, ' ')):read('*a'))
end)
```

This throws a `OWNER_ONLY` code when the check fails.

## Permissions

Some commands should only be able to be used by users with the correct permissions like moderation commands.

This can be done with the checks `:hasPermission` and `:botHasPermission`, both of which automatically enable `:guildOnly`.

```lua
local ban = toast.Command('ban')
   :hasPermission('banMembers')
   :botHasPermissions('banMembers')

ban:execute(function(msg)
   -- Argument parsing
end)
```

These throw `MISSING_PERMISSIONS` and `SELF_MISSING_PERMISSIONS` codes when they have failed.

## Roles

Some commands you might want only a specific role to be able to run like with permission-less moderation.

```lua
local ban = toast.Command('ban')
   :hasRole('banMembers')
   :botHasPermissions('banMembers')

ban:execute(function(msg)
   -- Argument parsing
end)
```

`:hasRole` and `:botHasRole` throw `MISSING_ROLES` and `SELF_MISSING_ROLES` codes when they have failed.

## Cooldowns

Cooldowns are a way to timeout users from using commands too fast.

```lua
local slow = toast.Command('slow')
   :cooldown(5)

slow:execute(function(msg)
   msg:reply('Now wait 5 second')
end)
```

Note: The cooldown is in **seconds**.

Cooldowns do not throw errors currently.

## Custom

Custom checks are a way for addons to SuperToast to add custom logic. An example of this would be the built in `ArgParse`.

```lua
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
```

Behind the scenes, `greetParser:attach` adds a custom check.

Custom checks return `CUSTOM_*` where `*` can be anything, they also can return an additional message which should replace the check failing message.