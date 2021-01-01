
# Class `Subcommand`

A subcommand to act as a mini command





## Methods


### Subcommand:__init(parent: [Command](../classes/Command.md), name: [string](https://www.lua.org/pil/2.4.html))

Create a new command


### Subcommand:count(): [number](https://www.lua.org/pil/2.3.html)

Count the amount of parents up this subcommand has


### Subcommand:execute(func: fun(msg: Message, args: [string](https://www.lua.org/pil/2.4.html)[], client: [SuperToastClient](../classes/SuperToastClient.md))): [Command](../classes/Command.md)

Sets the function to execute

