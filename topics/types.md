# Types

Types are one of the biggest benefits to using SuperToast. Before we get there you should install either [Lua by sumneko](https://github.com/sumneko/lua-language-server) or [Emmylua](https://emmylua.github.io/)


You can test if things went correctly by writing something like this:

```lua
---@type Message
local msg = {}
```

Now if we index the message we see its properties, if you  don't then EmmyLua isn't running and/or the types are not setup correctly.

Sometimes you may need to do this as a variable might not be known to EmmyLua. This will not work in events so in order to get it to work in events we use a different comment.

```lua
---@param msg Message
client:on('messageCreate', function(msg)

end)
```

EmmyLua will see the function we defined and make msg have the properties as Message (Note this will not change anything
during runtime)

There are more but that's usually what you are going to use. You can check the rest at the [EmmyLua Docs](https://emmylua.github.io/).

## SuperToast Types

All of the types of SuperToast are listed in the api reference, the names are the same.

## Discordia Types

All of the types of Discordia are listed within the Discordia wiki and names have not been touched.
