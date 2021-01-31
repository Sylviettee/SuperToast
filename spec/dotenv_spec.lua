local file = [[
BASIC=basic

# previous line intentionally left blank
AFTER_LINE=after_line
EMPTY=
SINGLE_QUOTES='single_quotes'
SINGLE_QUOTES_SPACED='    single quotes    '
DOUBLE_QUOTES="double_quotes"
DOUBLE_QUOTES_SPACED="    double quotes    "
EXPAND_NEWLINES="expand\nnew\nlines"
DONT_EXPAND_UNQUOTED=dontexpand\nnewlines
DONT_EXPAND_SQUOTED='dontexpand\nnewlines'
# COMMENTS=work
EQUAL_SIGNS=equals==
RETAIN_INNER_QUOTES={"foo": "bar"}
RETAIN_LEADING_DQUOTE="retained
RETAIN_LEADING_SQUOTE='retained
RETAIN_TRAILING_DQUOTE=retained"
RETAIN_TRAILING_SQUOTE=retained'
RETAIN_INNER_QUOTES_AS_STRING='{"foo": "bar"}'
TRIM_SPACE_FROM_UNQUOTED=    some spaced out string
USERNAME=therealnerdybeast@example.tld
SPACED_KEY = parsed
]]

describe('dotenv', function()
   describe('parse file', function()
      local parsed = toast.dotenv.parse(file)

      it('should return a table', function()
         assert.are.same('table', type(parsed))
      end)

      it('should set a basic variable', function()
         assert.are.same('basic', parsed.BASIC)
      end)

      it('should read after a skipped line', function()
         assert.are.same('after_line', parsed.AFTER_LINE)
      end)

      it('should default to empty values to empty string', function()
         assert.are.same('', parsed.EMPTY)
      end)

      it('should escape single quoted values', function()
         assert.are.same('single_quotes', parsed.SINGLE_QUOTES)
      end)

      it('should respect surrounding spaces in single quotes', function()
         assert.are.same('    single quotes    ', parsed.SINGLE_QUOTES_SPACED)
      end)

      it('should escape double quoted values', function()
         assert.are.same('double_quotes', parsed.DOUBLE_QUOTES)
      end)

      it('should respect surrounding spaces in double quotes', function()
         assert.are.same('    double quotes    ', parsed.DOUBLE_QUOTES_SPACED)
      end)

      it('should expand new lines but only if double quoted', function()
         assert.are.same('expand\nnew\nlines', parsed.EXPAND_NEWLINES)
      end)

      it('should not expand new lines if unquoted', function()
         assert.are.same('dontexpand\\nnewlines', parsed.DONT_EXPAND_UNQUOTED)
      end)

      it('should not expand new lines if single quoted', function()
         assert.are.same('dontexpand\\nnewlines', parsed.DONT_EXPAND_SQUOTED)
      end)

      it('should ignore commented lines', function()
         assert.is_nil(parsed.COMMENTS)
      end)

      it('should respect equal signs in values', function()
         assert.are.same('equals==', parsed.EQUAL_SIGNS)
      end)

      it('should retain inner quotes', function()
         assert.are.same('{"foo": "bar"}', parsed.RETAIN_INNER_QUOTES)
      end)

      it('should retain leading double quote', function()
         assert.are.same('"retained', parsed.RETAIN_LEADING_DQUOTE)
      end)

      it('should retain leading single quote', function()
         assert.are.same('\'retained', parsed.RETAIN_LEADING_SQUOTE)
      end)

      it('should retain tailing double quote', function()
         assert.are.same('retained"', parsed.RETAIN_TRAILING_DQUOTE)
      end)

      it('should retain tailing single quote', function()
         assert.are.same('retained\'', parsed.RETAIN_TRAILING_SQUOTE)
      end)

      it('should retain inner quotes when quoted', function()
         assert.are.same('{"foo": "bar"}', parsed.RETAIN_INNER_QUOTES_AS_STRING)
      end)

      it('should retain spaces in string', function()
         assert.are.same('some spaced out string', parsed.TRIM_SPACE_FROM_UNQUOTED)
      end)

      it('should parse emails completely', function()
         assert.are.same('therealnerdybeast@example.tld', parsed.USERNAME)
      end)

      it('should parse keys and values surrounded by spaces', function()
         assert.are.same('parsed', parsed.SPACED_KEY)
      end)

      it('should parse \\r endings', function()
         local newParsed = toast.dotenv.parse('SERVER=localhost\rPASSWORD=password\rDB=tests\r')

         assert.are.same({SERVER = 'localhost', PASSWORD = 'password', DB = 'tests'}, newParsed)
      end)

      it('should parse \\n endings', function()
         local newParsed = toast.dotenv.parse('SERVER=localhost\nPASSWORD=password\nDB=tests\n')

         assert.are.same({SERVER = 'localhost', PASSWORD = 'password', DB = 'tests'}, newParsed)
      end)

      it('should parse \\r\\n endings', function()
         local newParsed = toast.dotenv.parse('SERVER=localhost\r\nPASSWORD=password\r\nDB=tests\r\n')

         assert.are.same({SERVER = 'localhost', PASSWORD = 'password', DB = 'tests'}, newParsed)
      end)
   end)
end)
