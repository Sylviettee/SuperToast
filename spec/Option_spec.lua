describe('Option', function()
   describe(':__init', function()
      it('should panic on invalid config (numbered keys)', function()
         assert.has_error(function()
            toast.Option {5, 3, 1}
         end, 'Expected key 1 to be a string')
      end)

      it('should panic on invalid config (invalid values)', function()
         assert.has_error(function()
            toast.Option {
               x = 5
            }
         end, 'Expected value to be a string | function | table, instead got number')
      end)
   end)

   describe(':validate', function()
      local opts = toast.Option {
         x = { 'string', nil, '5' },
         y = { 'number', nil, 5 },
         z = 'boolean'
      }

      it('should panic on invalid options', function()
         assert.has_error(function()
            opts:validate{
               x = 6,
               y = '1',
               z = true
            }
         end, 'The option value, y, must be number')
      end)

      it('should fill in defaults', function()
         local newOpts = opts:validate{z = true}

         assert.are.same(newOpts, {x = '5', y = 5, z = true})
      end)

      it('should panic on missing value', function()
         assert.has_error(function()
            opts:validate {}
         end, 'The option value, z, is nil and no default was found')
      end)
   end)
end)