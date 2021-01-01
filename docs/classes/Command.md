
# Class `Command`

The command class to handle most functionality





## Properties

| Property | Type | Description |
| -------- | ---- |----------- |
| isSub | [boolean](https://www.lua.org/pil/2.2.html) |  |
| name | [string](https://www.lua.org/pil/2.4.html) |  |
| description | [string](https://www.lua.org/pil/2.4.html) |  |
| usage | [string](https://www.lua.org/pil/2.4.html) |  |
| cooldown | [number](https://www.lua.org/pil/2.3.html) |  |
| flags | table&lt;[string](https://www.lua.org/pil/2.4.html), [boolean](https://www.lua.org/pil/2.2.html)&gt; |  |
| aliases | [string](https://www.lua.org/pil/2.4.html)[] |  |
| examples | [string](https://www.lua.org/pil/2.4.html)[] |  |
| user_permissions | [string](https://www.lua.org/pil/2.4.html)[] |  |
| bot_permissions | [string](https://www.lua.org/pil/2.4.html)[] |  |
| subcommands | [Subcommand](../classes/Subcommand.md)[] |  |
| rawExecute | [function](https://www.lua.org/pil/2.6.html) |  |
| parent | [Subcommand](../classes/Subcommand.md)? |  |


## Methods


### Command:__init(name: [string](https://www.lua.org/pil/2.4.html), ...: [string](https://www.lua.org/pil/2.4.html)): [Command](../classes/Command.md)

Create a new command

Possible fail codes
* GUILD_ONLY - The command must be ran in a guild
* NSFW_ONLY - The command must be ran in a nsfw channel
* OWNER_ONLY - The command must be ran by the owner of the bot
* MISSING_PERMISSIONS - The user is missing permissions
* SELF_MISSING_PERMISSIONS - The bot is missing permissions
* MISSING_ROLES - The user is missing roles
* SELF_MISSING_ROLES - The bot is missing roles
* CUSTOM_* - Custom check error codes

### Command:toRun(message: Message, args: [string](https://www.lua.org/pil/2.4.html)[], client: [SuperToastClient](../classes/SuperToastClient.md)): [boolean](https://www.lua.org/pil/2.2.html)

Check a message to see if it matches all the criteria listed


### Command:description(desc: [string](https://www.lua.org/pil/2.4.html)): [Command](../classes/Command.md)

Attach a description to a command


### Command:example(example: [string](https://www.lua.org/pil/2.4.html)): [Command](../classes/Command.md)

Attach an example to a command


### Command:usage(usage: [string](https://www.lua.org/pil/2.4.html)): [Command](../classes/Command.md)

Attach a usage to a command


### Command:guild_only(): [Command](../classes/Command.md)

Set the command as guild only


### Command:nsfw_only(): [Command](../classes/Command.md)

Set the command as nsfw only


### Command:owner_only(): [Command](../classes/Command.md)

Set the command as owner only


### Command:cooldown(cooldown: [number](https://www.lua.org/pil/2.3.html)): [Command](../classes/Command.md)

Set the cooldown of the command


### Command:check(check: fun(msg: Message, args: [string](https://www.lua.org/pil/2.4.html)[], client: [SuperToastClient](../classes/SuperToastClient.md)): [string](https://www.lua.org/pil/2.4.html) | [boolean](https://www.lua.org/pil/2.2.html) | [string](https://www.lua.org/pil/2.4.html)): [Command](../classes/Command.md)

Add a custom check to the command


### Command:check_any(...: [function](https://www.lua.org/pil/2.6.html)): [Command](../classes/Command.md)

Add multiple custom checks


### Command:has_permission(perm: [string](https://www.lua.org/pil/2.4.html) | [number](https://www.lua.org/pil/2.3.html)): [Command](../classes/Command.md)

Add permission check for users


### Command:has_permissions(...: [string](https://www.lua.org/pil/2.4.html) | [number](https://www.lua.org/pil/2.3.html)): [Command](../classes/Command.md)

Add multiple permission checks for users


### Command:bot_has_permission(perm: [string](https://www.lua.org/pil/2.4.html) | [number](https://www.lua.org/pil/2.3.html)): [Command](../classes/Command.md)

Add permission check for the bot


### Command:bot_has_permissions(...: [string](https://www.lua.org/pil/2.4.html) | [number](https://www.lua.org/pil/2.3.html)): [Command](../classes/Command.md)

Add multiple permission checks for the bot


### Command:has_role(role: [string](https://www.lua.org/pil/2.4.html)): [Command](../classes/Command.md)

Check if the user has a specific role


### Command:add_subcommand(subcommand: [Subcommand](../classes/Subcommand.md)): [Command](../classes/Command.md)

Add a subcommand to the function


### Command:execute(func: fun(msg: Message, args: [string](https://www.lua.org/pil/2.4.html)[], client: [SuperToastClient](../classes/SuperToastClient.md)): void): [Command](../classes/Command.md)

Sets the function to execute

