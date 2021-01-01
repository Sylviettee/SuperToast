
# Class `Schema`

The schema object used to validate tables





## Methods


### Schema:__init(name: [string](https://www.lua.org/pil/2.4.html)): [Schema](../classes/Schema.md)

Create a new schema


### Schema:field(name: [string](https://www.lua.org/pil/2.4.html), value: [string](https://www.lua.org/pil/2.4.html) | [Schema](../classes/Schema.md), default: [any](https://www.lua.org/pil/contents.html#2)): [Schema](../classes/Schema.md)

Create a new field within the schema


### Schema:validate(tbl: table&lt;[any](https://www.lua.org/pil/contents.html#2), [any](https://www.lua.org/pil/contents.html#2)&gt;): table&lt;[any](https://www.lua.org/pil/contents.html#2), [any](https://www.lua.org/pil/contents.html#2)&gt; | [boolean](https://www.lua.org/pil/2.2.html), [string](https://www.lua.org/pil/2.4.html)?

Validate a table to see if it matches the schema

