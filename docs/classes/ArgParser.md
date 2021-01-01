
# Class `ArgParser`

An argument parser which can be used in part with commands





## Methods


### ArgParser:__init()




### ArgParser:attach(command: [Command](../classes/Command.md)): [ArgParser](../classes/ArgParser.md)

Attach the parser to a command, should be after all flags and arguments


### ArgParser:arg(func: [function](https://www.lua.org/pil/2.6.html), name: [string](https://www.lua.org/pil/2.4.html)): [ArgParser](../classes/ArgParser.md)

Register a function to check a passed argument


### ArgParser:arg(func: [function](https://www.lua.org/pil/2.6.html)): [ArgParser](../classes/ArgParser.md)

Register a function to check a passed argument


### ArgParser:flag(name: [string](https://www.lua.org/pil/2.4.html), func: [function](https://www.lua.org/pil/2.6.html), typeName: [string](https://www.lua.org/pil/2.4.html)): [ArgParser.modifiers](../classes/ArgParser.modifiers.md)

Register a function to check a passed flag

If the flag type is set as a boolean, the presence of the flag is counted as true

### ArgParser:flag(name: [string](https://www.lua.org/pil/2.4.html), func: [function](https://www.lua.org/pil/2.6.html)): [ArgParser.modifiers](../classes/ArgParser.modifiers.md)

Register a function to check a passed flag

If the flag type is set as a boolean, the presence of the flag is counted as true

### ArgParser:parse(str: [string](https://www.lua.org/pil/2.4.html), client: Client): [table](https://www.lua.org/pil/2.5.html)?, [string](https://www.lua.org/pil/2.4.html)?

Parse the input, typechecking it along the way


### ArgParser:_createModifier(ctx: [table](https://www.lua.org/pil/2.5.html)): [ArgParser.modifiers](../classes/ArgParser.modifiers.md)

Internal function for creating modifier packages


### ArgParser:_parse(str: [string](https://www.lua.org/pil/2.4.html)): [ArgParser.rawArgs](../structures/ArgParser.rawArgs.md)

Internal function for parsing arguments, doesn't enforce types or anything else

It also leaves a lot of fragments like symbol positions
