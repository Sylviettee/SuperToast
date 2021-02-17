# Arguments

## Adding numbers

In SuperToast, advanced arguments are not forced allowing for basic commands to not need to use them.

In this example, we will show 2 ways of making a command that adds its 2 arguments, one with ArgParse (Built in advanced argument parser) and the other with the default split arguments.

### Simple

In the simple method, we take 2 arguments, typecast, add, and then return the output.

```lua
local add = toast.Command('add')

add:execute(function(msg, args)
   local num1 = tonumber(args[1] or '')
   local num2 = tonumber(args[2] or '')

   if not num1 or not num2 then
      return msg:reply('Argument 1 and 2 must be numbers')
   end

   msg:reply(num1 + num2)
end)
```

This is a pretty simple way of doing this, however, the user feedback is a bit lacking when it comes to errors.

This is where advanced argument parsing comes in.

### Advanced

In the advanced method, we take advantage of the `ArgParse` class part of SuperToast.

```lua
local add = toast.Command('add')

local addParser = toast.ArgParser()
   :arg('number')
   :arg('number')

add:execute(function(msg, args)
   msg:reply(args.arguments[1] + args.arguments[2])
end)

addParser:attach(add)
```

This is a bit longer but it gives much better errors.

If we run something like `!add 1 "pineapple"` we get:

```
error[incorrect_argument_type]: Unable to convert argument 2 to number
   ┌─ input
   │
   │ 1 "pineapple"
   │   ^^^^^^^^^^^ Cannot convert `pineapple` to a number
```

Which is a very friendly and understandable error message.

## Flags

Flags are another feature of the advanced argument parser.

They have more features then arguments (for now) like greedy parsers, ranges and more.

To make a flag, you first want to call the method `:flag` on an argument parser.

```lua
local parser = toast.ArgParser()
   :flag('name', 'type')
```

Next we want to add some modifiers like setting the flag to required or changing the arguments it takes.

```lua
local parser = toast.ArgParser()
   :flag('name', 'type')
      .args('1')
```

Finally we add a `.finish()` after `.args` in order to finalize the flag.

```lua
local parser = toast.ArgParser()
   :flag('name', 'type')
      .args('1')
      .finish()
```

The strings you can pass to `.args` would be

* `num` - Expect exactly this amount of arguments
* `min-max` - Expect arguments between the min and max (greedy)
* `+` - Expect 1 or more arguments (greedy)
* `*` - Expect 0 or more arguments (greedy)
* `?` - Expect 0 or 1 arguments

What this *greedy* means is that when the parser reaches the minimum, it'll keep reading until it can't anymore due to another flag or it reaches the max.

Soon™️ ungreedy arguments will be supported.

## Types

Currently SuperToast supports these types:

* `string` - Do nothing
* `number` - Attempt to typecast to number
* `boolean` - Attempt to typecast to boolean
* `int` - Attempt to typecast to a whole number (math.floor(input) == input)
* `command` - Check if the input is the name of a valid command then typecast
* `user` - Check if the input is either a user id, user mention, or username then typecast to a User
