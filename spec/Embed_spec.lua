local function validate(embed)
   local json = embed:toJSON()

   assert(json.title and #json.title <= 256 or true, 'Title must be less than or equal to 256 characters')

   assert(json.description and #json.description <= 2048 or true,
          'Description must be less than or equal to 2048 characters')

   assert(json.fields and #json.fields <= 25 or true, 'Fields must be less than or equal to 25 characters')

   if json.fields then
      for _, v in pairs(json.fields) do
         assert(#v.name <= 256, 'Field names must be less than or equal to 256 characters')

         assert(#v.value <= 1024, 'Field values must be less than or equal to 1024 characters')
      end
   end

   assert(json.footer and #json.footer.text <= 2048 or true, 'The footer must be less than or equal to 2048 characters')

   assert(json.author and #json.author.name <= 256 or true, 'The author must be less than or equal to 256 characters')

   -- Total character limit is not enforced... yet
end

describe('Embed', function()
   describe('type checks', function()
      it('should typecheck titles', function()
         assert.has_error(function()
            toast.Embed():setTitle(5662)
         end, 'The title must be a string')
      end)

      it('should typecheck descriptions', function()
         assert.has_error(function()
            toast.Embed():setDescription(735)
         end, 'The description must be a string')
      end)

      it('should typecheck colors', function()
         assert.has_error(function()
            toast.Embed():setColor('5734')
         end, 'The color must be a number')
      end)

      it('should typecheck fields', function()
         assert.has_error(function()
            toast.Embed():addField(136356)
         end, 'The name must be a string')

         assert.has_error(function()
            toast.Embed():addField('136356', 6742)
         end, 'The value must be a string')

         assert.has_error(function()
            toast.Embed():addField('136356', '6742', 5636)
         end, 'Inline must be a boolean')
      end)

      it('should typecheck authors', function()
         assert.has_error(function()
            toast.Embed():setAuthor(5436)
         end, 'The name must be a string')

         assert.has_error(function()
            toast.Embed():setAuthor('5436', 56436)
         end, 'The icon must be a string')

         assert.has_error(function()
            toast.Embed():setAuthor('5436', '56436', 1536)
         end, 'The url must be a string')
      end)

      it('should typecheck footers', function()
         assert.has_error(function()
            toast.Embed():setFooter(5626)
         end, 'The text must be a string')

         assert.has_error(function()
            toast.Embed():setFooter('5626', 5989)
         end, 'The icon must be a string')
      end)

      it('should typecheck images', function()
         assert.has_error(function()
            toast.Embed():setImage(5621)
         end, 'The image must be a string')
      end)

      it('should typecheck thumbnails', function()
         assert.has_error(function()
            toast.Embed():setURL(5621)
         end, 'The url must be a string')
      end)

      it('should typecheck timestamps', function()
         assert.has_error(function()
            toast.Embed():setTimestamp(62672)
         end, 'The date must be a string')
      end)

      it('should typecheck urls', function()
         assert.has_error(function()
            toast.Embed():setURL(625)
         end, 'The url must be a string')
      end)
   end)

   describe('limit check', function()
      it('should enforce limits', function()
         local r = string.rep
         local embed = toast.Embed()

         embed:setTitle(r('a', 300))
         embed:setDescription(r('a', 3000))
         embed:setAuthor(r('a', 300))
         embed:setFooter(r('a', 3000))

         for _ = 1, 30 do
            embed:addField(r('a', 300), r('a', 3000), false, true)
         end

         validate(embed)
      end)
   end)
end)
