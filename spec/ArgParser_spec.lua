local ArgParser = toast.ArgParser

---@type ArgParser_config
local config = {
   simple = true
}

describe('ArgParser', function()
   describe(':arg', function()
      it('should return arguments passed', function()
         local parser = ArgParser()
            :arg('string')

         local args = assert(parser:parse('hello'))

         assert.are.equal('hello', args.arguments[1])
      end)

      it('should parse quotes correctly', function()
         local parser = ArgParser()
            :arg('string')

         local args = assert(parser:parse('"hello world"'))

         assert.are.equal('hello world', args.arguments[1])
      end)

      it('should parse single quotes correctly', function()
         local parser = ArgParser()
            :arg('string')

         local args = assert(parser:parse("'hello world'"))

         assert.are.equal('hello world', args.arguments[1])
      end)

      it('should parse escapes correctly', function()
         local parser = ArgParser()
            :arg('string')

         local args = assert(parser:parse("'it\\'s'"))

         assert.are.equal("it's", args.arguments[1])
      end)

      it('should allow quotes within quotes', function()
         local parser = ArgParser()
            :arg('string')

         local args = assert(parser:parse("'\"\"'"))

         assert.are.equal('""', args.arguments[1])
      end)

      it('should type check the passed arguments', function()
         local parser = ArgParser()
            :arg('number')

         local _, err = parser:parse('hi', nil, config)

         assert.are.equal('error[incorrect_argument_type]:1:2: Unable to convert argument 1 to number', err)
      end)

      it('should typecast the passed arguments', function()
         local parser = ArgParser()
            :arg('number')

         local args = assert(parser:parse('33'))

         assert.are.equal(33, args.arguments[1])
      end)

      it('should allow for multiple arguments', function()
         local parser = ArgParser()
            :arg('string')
            :arg('string')
            :arg('string')

         local args = assert(parser:parse('I am Soviet'))

         assert.are.same({'I', 'am', 'Soviet'}, args.arguments)
      end)

      it('should support quotes in multiple arguments', function()
         local parser = ArgParser()
            :arg('string')
            :arg('string')
            :arg('string')

         local args = assert(parser:parse('I "am not" Soviet'))

         assert.are.same({'I', 'am not', 'Soviet'}, args.arguments)
      end)

      it('should typecast when using multiple arguments', function()
         local parser = ArgParser()
            :arg('number')
            :arg('string')
            :arg('number')

         local args = assert(parser:parse('1 hi 3'))

         assert.are.same({1, 'hi', 3}, args.arguments)
      end)
   end)

   describe(':flag', function()
      describe('no modifiers', function()
         it('should parse flags correctly', function()
            local parser = ArgParser()
               :flag('test', 'string')
                  .args(1)
                  .finish()

            local args = assert(parser:parse('--test hi'))

            assert.are.same({
               test = {'hi'},
               arguments = {}
            }, args)
         end)

         it('should parse booleans correctly', function()
            local parser = ArgParser()
               :flag('test', 'boolean')
                  .finish()

            local args = assert(parser:parse('--test'))

            assert.are.same({
               test = true,
               arguments = {}
            }, args)
         end)

         it('should type check singular arguments', function()
            local parser = ArgParser()
               :flag('test', 'number')
                  .args(1)
                  .finish()

            local _, err = parser:parse('--test a', nil, config)

            assert.are.equal('error[incorrect_flag_type]:8:8: Unable to convert flag test to number', err)
         end)

         it('should support multiple flags', function()
            local parser = ArgParser()
               :flag('test', 'number')
                  .args(1)
                  .finish()
               :flag('test2', 'number')
                  .args(1)
                  .finish()

            local args = assert(parser:parse('--test 1 --test2 1'))

            assert.are.same({
               test = {1},
               test2 = {1},
               arguments = {}
            }, args)
         end)

         it('should type check multiple flags (single)', function()
            local parser = ArgParser()
               :flag('test', 'number')
                  .args(1)
                  .finish()
               :flag('test2', 'number')
                  .args(1)
                  .finish()

            local _, err = parser:parse('--test a --test2 1', nil, config)

            assert.are.equal('error[incorrect_flag_type]:8:8: Unable to convert flag test to number', err)
         end)

         it('should type check multiple flags (all)', function()
            local parser = ArgParser()
               :flag('test', 'number')
                  .args(1)
                  .finish()
               :flag('test2', 'number')
                  .args(1)
                  .finish()

            local _, err = parser:parse('--test a --test2 b', nil, config)

            assert.are.equal(
               'error[incorrect_flag_type]:8:8: Unable to convert flag test to number\n' ..
               'error[incorrect_flag_type]:18:18: Unable to convert flag test2 to number',
               err
            )
         end)
      end)

      describe('modifiers', function()
         it('should parse argument quantifiers correctly', function()
            local parser = ArgParser()
               :arg('string')
               :flag('test', 'string')
                  .args(2)
                  .finish()

            local args = assert(parser:parse('--test a b c'))

            assert.are.same({
               test = {'a', 'b'},
               arguments = {'c'}
            }, args)
         end)

         it('should type check arrays of arguments', function()
            local parser = ArgParser()
               :flag('test', 'number')
                  .args(2)
                  .finish()

            local _, err = parser:parse('--test a b', nil, config)

            assert.are.equal('error[incorrect_flag_type]:8:10: Unable to convert flag test to number', err)
         end)

         it('should allow required flags', function()
            local parser = ArgParser()
               :flag('test', 'string')
                  .args(1)
                  .required(true)
                  .finish()

            local _, err = parser:parse('', nil, config)

            assert.are.equal('error[missing_required_flag]:1:3: Flag test is a required flag', err)
         end)
      end)
   end)
end)