
# Class `typed`

# Typed

A module to aid in allowing for typed code

Typed gives clean errors that look like errors from misused standard functions

```
bad argument #1 to 'tostring' (string | function expected, got nil)
```

## Quick example

```lua
local typed = require 'typed'

local function hi(msg)
typed.func(_, 'string')(msg)

print(msg)
end

hi('hello') -- No errors
hi(1) -- bad argument #1 to 'hi' (string expected, got number)
```

Typed can automatically figure out the name of the function, however,
if you want to replace it, you pass the first argument.

## Tables and arrays

Typed also supports arrays and tables in its definitions.

An array is `type` followed by `[]` while a table is `table<keyType, valueType>`.

By default, an empty table `{}` would be `unknown[]`. This is as it can't be inferred what it is.

## Logical statements

Currently typed only supports the `or` logical operator.

```lua
local typed = require 'typed'

local function hi(msg)
typed.func(_, 'string | number')(msg)

print(msg)
end

hi('hello') -- No errors
hi(1) -- No errors
```

Here is the first example using the `or` operator represented with `|`.

It does exactly what you would think it does, it will accept strings **or** numbers.





## Methods


### typed.isArray(tbl: table&lt;[any](https://www.lua.org/pil/contents.html#2), [any](https://www.lua.org/pil/contents.html#2)&gt;): [boolean](https://www.lua.org/pil/2.2.html)

Is this an array?


### typed.whatIs(this: [any](https://www.lua.org/pil/contents.html#2)): [string](https://www.lua.org/pil/2.4.html)

What is this specific item?

Note: This can be overridden with `__name` or `__type` field.

Arrays are represented with `type[]` and tables with `table<keyType, valueType>`.

### typed.resolve(validator: [string](https://www.lua.org/pil/2.4.html), pos: [number](https://www.lua.org/pil/2.3.html)?, name: [string](https://www.lua.org/pil/2.4.html)?): fun(x: [any](https://www.lua.org/pil/contents.html#2)): [boolean](https://www.lua.org/pil/2.2.html)? | [string](https://www.lua.org/pil/2.4.html)?

Create a new function to validate types

This is commonly piped into assert and should be used in environments without `debug`.


### typed.is(validator: [string](https://www.lua.org/pil/2.4.html), value: [any](https://www.lua.org/pil/contents.html#2)): [boolean](https://www.lua.org/pil/2.2.html)

Check if the `value` matches the `validator`.

Used internally by `typed.resolve

### typed.func(name: [string](https://www.lua.org/pil/2.4.html), ...: [string](https://www.lua.org/pil/2.4.html)): [function](https://www.lua.org/pil/2.6.html)

Create a new typed function.

**This function uses the debug library**

You can override the inferred name by passing a first argument.

The rest of the arguments are validation strings.

This returns a function which would take those arguments defined in the validation string.

### typed.typedDict(keyType: [string](https://www.lua.org/pil/2.4.html), valueType: [string](https://www.lua.org/pil/2.4.html)): table&lt;[any](https://www.lua.org/pil/contents.html#2), [any](https://www.lua.org/pil/contents.html#2)&gt;

Create a typed dictionary allowing only specific key and value types

