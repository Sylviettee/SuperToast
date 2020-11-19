describe('Array', function()
   describe(':__len', function()
      it('should return the arrays length', function()
         local array = toast.Array {5, 7, 1, 5, 0}

         assert.are.equal(5, #array)
      end)
   end)

   describe(':__pairs', function()
      it('should loop over each item', function()
         local s = spy.new(function()
         end)

         local array = toast.Array {2, 9, 3, 2}

         for i, v in pairs(array) do s(i, v) end

         assert.spy(s).was.called(4)
         assert.spy(s).was.called_with(2, 9)
      end)
   end)

   describe(':get', function()
      it('should return contents correctly', function()
         local array = toast.Array {5, 8, '20'}

         array:push(5)

         array:push(8)

         array:push('20')

         assert.are.equal('20', array:get(3))
      end)
   end)

   describe(':iter', function()
      it('should iterate in the same order', function()
         local input = {0, 5, 10, 20, '50', true, false}

         local array = toast.Array(input)

         local output = {}

         for val in array:iter() do
            table.insert(output, val)
         end

         assert.are.same(input, output)
      end)
   end)

   describe(':unpack', function()
      it('should unpack the table in the same order', function()
         local input = {0, 5, 19, 8}

         local array = toast.Array(input)

         assert.are.same(input, {array:unpack()})
      end)
   end)

   describe(':push', function()
      it('should add items in the same order', function()
         local array = toast.Array()

         array:push(5)

         array:push(8)

         assert.are.equal(8, array:get(2))
      end)
   end)

   describe(':pop', function()
      it('should remove the selected item', function()
         local array = toast.Array {1}

         array:pop()

         assert.is_nil(array:get(1))
      end)

      it('should return popped item', function()
         local array = toast.Array {2}

         assert.is.equal(2, array:pop())
      end)

      it('should rebase the array', function()
         local array = toast.Array {2, 3, 5}

         array:pop(2)

         assert.is.equal(5, array:get(2))
      end)
   end)

   describe(':forEach', function()
      it('should loop over each item', function()
         local s = spy.new(function()
         end)

         local array = toast.Array {2, 9, 3, 2}

         array:forEach(s)

         assert.spy(s).was.called(4)
         assert.spy(s).was.called_with(2, 9)
      end)
   end)

   describe(':filter', function()
      it('should loop over each item', function()
         local s = spy.new(function()
         end)

         local array = toast.Array {2, 9, 3, 2}

         array:filter(s)

         assert.spy(s).was.called(4)
         assert.spy(s).was.called_with(9)
      end)

      it('should reduce the items in the new array', function()
         local array = toast.Array {5, 2, 8, 9}

         local newArr = array:filter(function() return false end)

         assert.is.equal(0, #newArr)
      end)
   end)

   describe(':find', function()
      it('should loop over each item', function()
         local s = spy.new(function()
         end)

         local array = toast.Array {2, 9, 3, 2}

         array:find(s)

         assert.spy(s).was.called(4)
         assert.spy(s).was.called_with(9)
      end)

      it('should return the found item', function()
         local array = toast.Array {2, 8, 1, '6'}

         local item = array:find(function(v) return v == '6' end)

         assert.is.equal('6', item)
      end)
   end)

   describe(':map', function()
      it('should loop over each item', function()
         local s = spy.new(function()
         end)

         local array = toast.Array {2, 9, 3, 2}

         array:map(s)

         assert.spy(s).was.called(4)
         assert.spy(s).was.called_with(9)
      end)

      it('should change the items in the new array', function()
         local array = toast.Array {2, 7, 3, 1}

         local newArr = array:map(function(x)
            return x * 2
         end)

         assert.are.same({4, 14, 6, 2}, {newArr:unpack()})
      end)
   end)

   describe(':slice', function()
      it('should create a new array', function()
         local array = toast.Array {7, 1, 3, 1}

         local slice = array:slice()

         array:push(5)

         assert.is_nil(slice:get(5))
      end)

      it('should return a slice of the contents', function()
         local array = toast.Array {1, 6, 2, 1}

         local slice = array:slice(2, 3)

         assert.are.same({6, 2}, {slice:unpack()})
      end)
   end)

   describe(':copy', function()
      it('should create a new array', function()
         local array = toast.Array {7, 1, 3, 1}

         local copy = array:copy()

         array:push(5)

         assert.is_nil(copy:get(5))
      end)
   end)

   describe(':reverse', function()
      it('should reverse the array contents', function()
         local array = toast.Array {1, 2, 3, 4}

         local rev = array:reverse()

         assert.is.same({4, 3, 2, 1}, {rev:unpack()})
      end)
   end)
end)
