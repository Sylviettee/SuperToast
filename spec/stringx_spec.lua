describe('stringx', function()
   local stringx = toast.stringx

   describe('.split', function()
      it('should split a string', function()
         assert.are.same({'this', 'can', 'split'}, stringx.split('this can split', ' '))
      end)
   end)

   describe('.trim', function()
      it('should trim whitespace around a string', function()
         assert.are.same('no whitespace', stringx.trim('       no whitespace       '))
      end)
   end)

   describe('.startswith', function()
      it('should check if a string startswith another', function()
         assert.is_true(stringx.startswith('awoo', 'aw'))
      end)
   end)

   describe('.endswith', function()
      it('should check if a string endswith another', function()
         assert.is_true(stringx.endswith('awoo', 'oo'))
      end)
   end)

   describe('.random', function()
      it('should return a random string', function()
         local str = stringx.random(50)

         assert.are.same(50, #str)
      end)
   end)

   describe('.pad', function()
      it('should left pad a string', function()
         assert.are.same('wow  ', stringx.pad('wow', 5, 'left'))
      end)

      it('should right pad a string', function()
         assert.are.same('  wow', stringx.pad('wow', 5, 'right'))
      end)

      it('should center pad a string', function()
         assert.are.same(' wow ', stringx.pad('wow', 5, 'center'))
      end)
   end)

   describe('.levenshtein', function()
      it('should describe the difference between strings', function()
         local com1 = stringx.levenshtein('Hello', 'hallo')
         local com2 = stringx.levenshtein('Hello', 'qwerty')

         assert(com2 > com1, 'hallo should be closer to Hello than qwerty')
      end)
   end)

   describe('.shorten', function()
      it('should shorten right', function()
         assert.are.same('...', stringx.shorten('abcde', 3))
         assert.are.same('a...', stringx.shorten('abcde', 4))
      end)

      it('should shorten left', function()
         assert.are.same('...', stringx.shorten('abcde', 3, true))
         assert.are.same('...e', stringx.shorten('abcde', 4, true))
      end)
   end)

   describe('.fancyformat', function()
      it('should fancy format a string', function()
         assert.are.same(
            'this is fancy',
            tostring(stringx.fancyformat '%s %s %s' 'this' 'is' 'fancy')
         )
      end)
   end)
end)