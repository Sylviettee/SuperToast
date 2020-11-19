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
         end, 'bad argument #1 to \'setTitle\' (string expected, got number)')
      end)

      it('should typecheck descriptions', function()
         assert.has_error(function()
            toast.Embed():setDescription(735)
         end, 'bad argument #1 to \'setDescription\' (string expected, got number)')
      end)

      it('should typecheck colors', function()
         assert.has_error(function()
            toast.Embed():setColor('5734')
         end, 'bad argument #1 to \'setColor\' (number expected, got string)')
      end)

      it('should typecheck fields', function()
         assert.has_error(function()
            toast.Embed():addField(136356)
         end, 'bad argument #1 to \'addField\' (string expected, got number)')

         assert.has_error(function()
            toast.Embed():addField('136356', 6742)
         end, 'bad argument #2 to \'addField\' (string expected, got number)')

         assert.has_error(function()
            toast.Embed():addField('136356', '6742', 5636)
         end, 'bad argument #3 to \'addField\' (boolean expected, got number)')
      end)

      it('should typecheck authors', function()
         assert.has_error(function()
            toast.Embed():setAuthor(5436)
         end, 'bad argument #1 to \'setAuthor\' (string expected, got number)')

         assert.has_error(function()
            toast.Embed():setAuthor('5436', 56436)
         end, 'bad argument #2 to \'setAuthor\' (string expected, got number)')

         assert.has_error(function()
            toast.Embed():setAuthor('5436', '56436', 1536)
         end, 'bad argument #3 to \'setAuthor\' (string expected, got number)')
      end)

      it('should typecheck footers', function()
         assert.has_error(function()
            toast.Embed():setFooter(5626)
         end, 'bad argument #1 to \'setFooter\' (string expected, got number)')

         assert.has_error(function()
            toast.Embed():setFooter('5626', 5989)
         end, 'bad argument #2 to \'setFooter\' (string expected, got number)')
      end)

      it('should typecheck images', function()
         assert.has_error(function()
            toast.Embed():setImage(5621)
         end, 'bad argument #1 to \'setImage\' (string expected, got number)')
      end)

      it('should typecheck thumbnails', function()
         assert.has_error(function()
            toast.Embed():setURL(5621)
         end, 'bad argument #1 to \'setURL\' (string expected, got number)')
      end)

      it('should typecheck timestamps', function()
         assert.has_error(function()
            toast.Embed():setTimestamp(62672)
         end, 'bad argument #1 to \'setTimestamp\' (string expected, got number)')
      end)

      it('should typecheck urls', function()
         assert.has_error(function()
            toast.Embed():setURL(625)
         end, 'bad argument #1 to \'setURL\' (string expected, got number)')
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
