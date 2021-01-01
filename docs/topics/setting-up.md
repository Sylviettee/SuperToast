# Setting Up

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

Some things which you might want to add next would be changing the prefix, adding owners and other things.

```lua
---@type SuperToast
local toast = require 'SuperToast'

toast.dotenv.config()

local client = toast.Client(process.env.TOKEN, {
   prefix = ';',
   owners = {'your id'}
}, {
   logFile = './private/discordia.log',
   gatewayFile = './private/gateway.json'
})

client:login()
```

Now you are ready to make commands.