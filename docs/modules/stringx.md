
# Module `stringx`

String utility library









## Functions


### stringx.split(str: [string](https://www.lua.org/pil/2.4.html), separator: [string](https://www.lua.org/pil/2.4.html)): [string](https://www.lua.org/pil/2.4.html)[]

Split a string by a separator


### stringx.trim(str: [string](https://www.lua.org/pil/2.4.html)): [string](https://www.lua.org/pil/2.4.html)

Trim whitespace around a string


### stringx.startswith(str: [string](https://www.lua.org/pil/2.4.html), start: [string](https://www.lua.org/pil/2.4.html)): [boolean](https://www.lua.org/pil/2.2.html)

Check if a string starts with another string


### stringx.endswith(str: [string](https://www.lua.org/pil/2.4.html), ends: [string](https://www.lua.org/pil/2.4.html)): [boolean](https://www.lua.org/pil/2.2.html)

Check if a string ends with another string


### stringx.random(len: [number](https://www.lua.org/pil/2.3.html), mn: [number](https://www.lua.org/pil/2.3.html), mx: [number](https://www.lua.org/pil/2.3.html)): [string](https://www.lua.org/pil/2.4.html)

Return a string of random characters with the length of `len` and between `min` and `max`


### stringx.pad(str: [string](https://www.lua.org/pil/2.4.html), len: [number](https://www.lua.org/pil/2.3.html), align: [string](https://www.lua.org/pil/2.4.html), pattern: [string](https://www.lua.org/pil/2.4.html)): [string](https://www.lua.org/pil/2.4.html)

Put spaces around a string


### stringx.levenshtein(str1: [string](https://www.lua.org/pil/2.4.html), str2: [string](https://www.lua.org/pil/2.4.html)): [number](https://www.lua.org/pil/2.3.html)

Get the difference between 2 strings


### stringx.shorten(str: [string](https://www.lua.org/pil/2.4.html), width: [number](https://www.lua.org/pil/2.3.html), tail: [boolean](https://www.lua.org/pil/2.2.html)): [string](https://www.lua.org/pil/2.4.html)

Shorten a string to be prefixed or suffixed by ellipsis


### stringx.fancyformat(str: [string](https://www.lua.org/pil/2.4.html)): [function](https://www.lua.org/pil/2.6.html)

Makes a factory to "fancy" format a string

