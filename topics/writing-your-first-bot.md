# Writing your first bot

Making a bot with SuperToast is a breeze thanks to all its utilities.

## Installation

Before starting to do anything else, you should install the dependencies needed, discordia and SuperToast.

* `lit install discordia`
* `lit install SuperToast`

(This expects you have added [lit to your path](https://gist.github.com/Bilal2453/7370a143244d5ef2480c3db358fa2790))

Now you should make 2 files, `main.lua` and `.env`, we will be using these later

Once everything is setup you should have a directory structure looking something like this:

```
bot
├── deps
├── .env
└── main.lua
```

## .env File

The `.env` file is where you store all your secrets like tokens.

Here is an example `.env`, make sure to replace `<TOKEN>` with your bot token, make sure you don't prefix `bot ` before it.

```
TOKEN=<TOKEN>
```

## Main File

From within the `main.lua` file, you want to create your client and setup the `.env` file.

```lua
---@type SuperToast
local toast = require 'SuperToast'

toast.dotenv.config()

local client = toast.Client(process.env.TOKEN, {
   -- SuperToast options
}, {
   -- Discordia options
})

client:login()
```

Now within the SuperToast options we might want to configure some things like the prefix.

```lua
{
   prefix = '%' -- Could also be an array of strings or a function that returns either one
}
```

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

Whenever the command is called, it will call the function specified in execute with the arguments of [message](https://github.com/SinisterRectus/discordia/wiki/Message), args (string[]), [client](../classes/SuperToastClient.md) and [additional context](../structures/Command.additionalContext.md)

## Running the bot

Now that we have a basic bot, we can now start it.

If everything went ok, you should be able to run `luvit main.lua`

Now when you run `%ping` you should get.

![response](https://imgur.com/SspwnZc.png)

Congratulations on your first bot! Now time to add some more functionality.

## Aliases

You might want to add an alias to the ping command. For example, you might want a shorthand to `ping` to be `p`. The [Command constructor](../classes/Command.md) accepts a `vararg` of strings, those are the aliases.

We can add the `p` alias by simply.

```diff
- local ping = toast.Command('ping')
+ local ping = toast.Command('ping', 'p')
```

## Next steps

Now with the basics of SuperToast down, you might want to checkout the following:

* [Arguments](./arguments.md) - Adding arguments to commands
* [Checks](./command-checks.md) - Learn about the different kind of checks a command can have
* [Types](./types.md) - Learn about getting intellisense with SuperToast