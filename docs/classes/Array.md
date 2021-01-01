
# Class `Array`

An array to store data within





## Methods


### Array:__init(starting: [any](https://www.lua.org/pil/contents.html#2))




### Array:__len(): [number](https://www.lua.org/pil/2.3.html)

Get the length of the array


### Array:__pairs()

Loop over the array


### Array:get(k: [number](https://www.lua.org/pil/2.3.html)): [any](https://www.lua.org/pil/contents.html#2)

Get an item at a specific index


### Array:set(k: [number](https://www.lua.org/pil/2.3.html), v: [any](https://www.lua.org/pil/contents.html#2))

Set an item at a specific index


### Array:iter()

Iterate over an array


### Array:unpack()

Unpack the array


### Array:push(item: [any](https://www.lua.org/pil/contents.html#2))

Add an item to the end of an array


### Array:concat(sep: [string](https://www.lua.org/pil/2.4.html))

Concat an array


### Array:pop(pos: [number](https://www.lua.org/pil/2.3.html))

Pop the item from the end of the array and return it


### Array:forEach(fn: fun(val: [any](https://www.lua.org/pil/contents.html#2), key: [number](https://www.lua.org/pil/2.3.html)): void)

Loop over the array and call the function each time


### Array:filter(fn: fun(val: [any](https://www.lua.org/pil/contents.html#2)): void): [Array](../classes/Array.md)

Loop through each item and each item that satisfies the function gets added to an array and gets returned


### Array:find(fn: fun(val: [any](https://www.lua.org/pil/contents.html#2)): [boolean](https://www.lua.org/pil/2.2.html)): [any](https://www.lua.org/pil/contents.html#2)? | [number](https://www.lua.org/pil/2.3.html)?

Return the first value which satisfies the function


### Array:search(fn: fun(val: [any](https://www.lua.org/pil/contents.html#2)): [any](https://www.lua.org/pil/contents.html#2)): [any](https://www.lua.org/pil/contents.html#2)? | [number](https://www.lua.org/pil/2.3.html)?

Similar to array:find except returns what the function returns as long as its truthy


### Array:map(fn: fun(val: [any](https://www.lua.org/pil/contents.html#2)): [any](https://www.lua.org/pil/contents.html#2)): [Array](../classes/Array.md)

Create a new array based on the results of the passed function


### Array:slice(start: [number](https://www.lua.org/pil/2.3.html), stop: [number](https://www.lua.org/pil/2.3.html), step: [number](https://www.lua.org/pil/2.3.html)): [Array](../classes/Array.md)

Slice an array using start, stop, and step


### Array:copy(): [Array](../classes/Array.md)

Copy an array into a new array


### Array:reverse(): [Array](../classes/Array.md)

Reverse an array, does not affect original array


### Array:toTable(): [any](https://www.lua.org/pil/contents.html#2)[]

Return the data within the array

