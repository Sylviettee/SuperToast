<div align="center">
<p>
    <img width="25%" src="https://imgur.com/zyUqIi2.png">
</p>
<h1>SuperToast</h1>
</div>

SuperToast is a Discordia command framework designed for ease of use.

## Quick example

```lua
local toast = require 'SuperToast'
local cmd = toast.Command

toast.dotenv.config()

local client = toast.Client(process.env.TOKEN)

local ping = cmd('ping'):execute(function(msg)
   msg:reply 'pong!'
end)

client:addCommand(ping)

client:login()
```

In this example we can see a lot of what SuperToast provides. 
Let's go down to the [features](#features) section to learn more.

## Features

* Dotenv parsing
* Typed interfaces
* Useful utility classes
* EmmyLua types

## Types

SuperToast is typed using EmmyLua and even includes types for all Discordia objects!

In our example, we can view the types of the `msg` object as seen below.

![EmmyLua types](https://imgur.com/gEHl84g.png)

This allows for easier use as you don't need to look at the docs constantly.

## Installation

You can install SuperToast using `lit`, the package manager of luvit

```sh
lit install SovietKitsune/SuperToast
```