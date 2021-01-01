
# Class `Embed`

An embed class to allow structuring embeds easier





## Methods


### Embed:__init(starting: [table](https://www.lua.org/pil/2.5.html))

Create a new embed


### Embed:setTitle(title: [string](https://www.lua.org/pil/2.4.html)): [Embed](../classes/Embed.md)

Set the title of the embed


### Embed:setDescription(desc: [string](https://www.lua.org/pil/2.4.html)): [Embed](../classes/Embed.md)

Set the description of the embed


### Embed:setColor(color: [number](https://www.lua.org/pil/2.3.html)): [Embed](../classes/Embed.md)

Set the color of the embed


### Embed:addField(name: [string](https://www.lua.org/pil/2.4.html), value: [string](https://www.lua.org/pil/2.4.html), inline: [boolean](https://www.lua.org/pil/2.2.html), ignore: [boolean](https://www.lua.org/pil/2.2.html)): [Embed](../classes/Embed.md)

Add a field to the embed


### Embed:setAuthor(name: [string](https://www.lua.org/pil/2.4.html), icon: [string](https://www.lua.org/pil/2.4.html), url: [string](https://www.lua.org/pil/2.4.html)): [Embed](../classes/Embed.md)

Set the author of the embed


### Embed:setFooter(text: [string](https://www.lua.org/pil/2.4.html), icon: [string](https://www.lua.org/pil/2.4.html)): [Embed](../classes/Embed.md)

Set the footer of the embed


### Embed:setImage(img: [string](https://www.lua.org/pil/2.4.html)): [Embed](../classes/Embed.md)

Set the image of the embed


### Embed:setThumbnail(url: [string](https://www.lua.org/pil/2.4.html)): [Embed](../classes/Embed.md)

Set the thumbnail of the embed


### Embed:setTimestamp(date: [string](https://www.lua.org/pil/2.4.html)): [Embed](../classes/Embed.md)

Set the timestamp of the embed


### Embed:setURL(): [Embed](../classes/Embed.md)

Set the url of the embed


### Embed:toJSON(): [Embed.raw](../structures/Embed.raw.md)

Return the contents within the embed


### Embed:send(channel: TextChannel): Message?, [string](https://www.lua.org/pil/2.4.html)?

Send an embed to a channel

