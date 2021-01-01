
# Structure `Embed.raw`

The raw data within an embed



## Declaration

```lua
Embed.raw = {
   title = string?,
   type = string?,
   description = string?,
   url = string?,
   timestamp = string?,
   color = number?,
   footer = Embed.footer?,
   image = Embed.image?,
   thumbnail = Embed.thumbnail?,
   video = Embed.video?,
   provider = Embed.provider?,
   author = Embed.author?,
   fields = Embed.field[]?
}
```

## Fields

| Field | Type | Description |
| ----- | ---- |------------ |
| title | [string](https://www.lua.org/pil/2.4.html)? | title of embed |
| type | [string](https://www.lua.org/pil/2.4.html)? | type of embed (always &quot;rich&quot; for webhook embeds) |
| description | [string](https://www.lua.org/pil/2.4.html)? | description of embed |
| url | [string](https://www.lua.org/pil/2.4.html)? | url of embed |
| timestamp | [string](https://www.lua.org/pil/2.4.html)? | ISO8601 timestamp of embed content |
| color | [number](https://www.lua.org/pil/2.3.html)? | color code of the embed |
| footer | [Embed.footer](../structures/Embed.footer.md)? | footer information |
| image | [Embed.image](../structures/Embed.image.md)? | image information |
| thumbnail | [Embed.thumbnail](../structures/Embed.thumbnail.md)? | thumbnail information |
| video | [Embed.video](../structures/Embed.video.md)? | video information |
| provider | [Embed.provider](../structures/Embed.provider.md)? | provider information |
| author | [Embed.author](../structures/Embed.author.md)? | author information |
| fields | [Embed.field](../structures/Embed.field.md)`[]`? | fields information |



