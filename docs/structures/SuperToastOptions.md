
# Structure `SuperToastOptions`

The options to pass to the SuperToast client



## Declaration

```lua
local SuperToastOptions = {
   commandHandler = function(client: SuperToastClient, msg: Message),
   errorResolver = function(cmd: Command, err: string): string,
   owners = string[],
   prefix = string | string[] | function(msg: Message): string | string[]
}
```

## Fields

| Field | Type | Description |
| ----- | ---- |------------ |
| commandHandler | fun(client: [SuperToastClient](../classes/SuperToastClient.md), msg: Message) | The function to call to handle a command |
| errorResolver | fun(cmd: [Command](../classes/Command.md), err: [string](https://www.lua.org/pil/2.4.html)): [string](https://www.lua.org/pil/2.4.html) | The function to call to parse an error message |
| owners | [string](https://www.lua.org/pil/2.4.html)`[]` | The ids of the people who own the bot |
| prefix | [string](https://www.lua.org/pil/2.4.html) \| [string](https://www.lua.org/pil/2.4.html)`[]` \| fun(msg: Message): [string](https://www.lua.org/pil/2.4.html) \| [string](https://www.lua.org/pil/2.4.html)`[]` | The prefix/prefixes/function to call to get a prefix/prefixes |



