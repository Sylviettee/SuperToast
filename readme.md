<div align="center">
<p>
    <img width="25%" src="https://imgur.com/zyUqIi2.png">
</p>
<h1>SuperToast</h1>
</div>

<div align="center">
    <a href="https://github.com/SovietKitsune/SuperToast/actions">
        <img alt="Github Documentation Status" src="https://img.shields.io/github/workflow/status/sovietkitsune/supertoast/Documentation?style=flat-square">
    </a>
    <a href="https://github.com/SovietKitsune/SuperToast/actions">
        <img alt="GitHub Testing Status" src="https://img.shields.io/github/workflow/status/sovietkitsune/supertoast/Testing%20and%20linting?style=flat-square">
    </a>
    <a href="https://github.com/XAMPPRocky/tokei">
        <img alt="Lines of Code" src="https://img.shields.io/tokei/lines/github/sovietkitsune/supertoast?style=flat-square">
    </a>
</div>

<br/>

- [About](#about)
- [Quick example](#quick-example)
- [Argument parsing](#argument-parsing)
- [Features](#features)
- [Types](#types)
- [Installation](#installation)
- [TODO](#todo)

## About

SuperToast is a Discordia command framework designed for ease of use.

It is recommended to use [LuaAnalysis](https://github.com/Benjamin-Dobell/IntelliJ-Luanalysis/), [EmmyLua](https://github.com/EmmyLua/VSCode-EmmyLua) or [Lua by Sumneko](https://github.com/sumneko/lua-language-server) when using this as you will get types as seen below.

## Quick example

```lua
local toast = require 'SuperToast'
local cmd = toast.Command

toast.dotenv.config()

local client = toast.Client(process.env.TOKEN)

local ping = cmd('ping')

ping:execute(function(msg)
   msg:reply 'pong!'
end)

client:addCommand(ping)

client:login()
```

In this example we can see a lot of what SuperToast provides. 

This is just the basics, we can see more with SuperToasts closeness to types.

For a more in-depth into read [writing your first bot.](./topics/writing-your-first-bot.md)

## Argument parsing

Argument parsing is something else used quite a lot within bots and SuperToast makes it easy.

```lua
local toast = require 'SuperToast'

toast.dotenv.config()

local client = toast.Client(process.env.TOKEN)

local greetCmd = toast.Command('greet')

local greetParser = ArgParser()
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
```

Now run something like `!greet --users a`.

You might get something like

```
error[incorrect_argument_type]: Unable to convert flag users to user
   ┌─ input
   │
   │ --users a
   │         ^ Did you mean `username`? (Or Unable to find anybody with the username of `a`.)
```

This is something very powerful, clean, nice errors with pointers.

This argument parsing is something you just don't get within a lot of other utility libraries.

## Features

* **Dotenv parsing:** SuperToast can be able to parse your `.env` files where you can store secrets. The file format is easy to understand and allows you to keep all your secrets within a secret file.
* **Typed interfaces:** SuperToast tends to tell you what you did wrong. If you try to pass a number to `Client:addCommand`, it'll tell you it expected a command instead. This can help make debugging easier.
* **Useful utility classes and modules:** SuperToast has utility modules like a `.env` parser, millisecond humanizer, string manipulation, command hot reloading and more!
* **EmmyLua types:** SuperToast uses EmmyLua in order for you to get intellisense while making your bot which, again, helps decrease the time debugging. Read more about it on the [documentation](./topics/types.md)
* **Argument parsing:** Out of the box, SuperToast has a fast argument parser which is persistent through errors and gives readable, understandable error messages. Read more about it in the [documentation](./topics/arguments.md)
* **Hot reloading:** SuperToast has a new `CommandUtil` class which provides hot reloading functionality in as little as 4 lines of code.
* **Checks and walls:** Sometimes you might need to validate permissions or check that the user meets certain requirements. This can be done with simple function calls within the `Command` class. Whenever one of these checks fails, it falls onto the errorHandler. More can be learned in the [documentation](./topics/command-checks.md)

## Types

SuperToast is typed using EmmyLua and even includes types for all Discordia objects!

In our example, we can view the types of the `msg` object as seen below.

![EmmyLua types](https://imgur.com/gEHl84g.png)

This allows for easier use as you don't need to look at the docs constantly.

(Note: Types on callbacks don't work on Lua by Sumneko)

## Installation

You can install SuperToast using `lit`, the package manager of luvit

```sh
lit install SovietKitsune/SuperToast
```

## TODO

* [x] Command cooldowns
* [ ] Bug fixes
* [ ] More documentation
* [ ] Add event class
* [ ] Add plugin class
* [ ] Add tests for Command, ArgParse and Subcommand
