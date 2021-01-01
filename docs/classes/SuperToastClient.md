
# Class `SuperToastClient`

The SuperToast client with all the fun features





## Properties

| Property | Type | Description |
| -------- | ---- |----------- |
| commands | [TypedArray](../classes/TypedArray.md) |  |
| config | [SuperToastOptions](../structures/SuperToastOptions.md) |  |


## Methods


### SuperToastClient:__init(token: [string](https://www.lua.org/pil/2.4.html), options: [SuperToastClient](../classes/SuperToastClient.md), discOptions: [DiscordiaOptions](../structures/DiscordiaOptions.md)): [SuperToastClient](../classes/SuperToastClient.md)

Create a new SuperToast client


### SuperToastClient:login(presence: table&lt;[string](https://www.lua.org/pil/2.4.html), [any](https://www.lua.org/pil/contents.html#2)&gt;?)

Connect and login


### SuperToastClient:addCommand(command: [Command](../classes/Command.md))

Register a command to the client


### SuperToastClient:removeCommand(command: [Command](../classes/Command.md))

Remove a subcommand from the client


### SuperToastClient:reply(msg: Message, content: [string](https://www.lua.org/pil/2.4.html) | [table](https://www.lua.org/pil/2.5.html), mention: [boolean](https://www.lua.org/pil/2.2.html)): Message

Send a reply to a message

