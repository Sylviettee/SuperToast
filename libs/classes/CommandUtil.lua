local pathJoin = require('pathjoin').pathJoin
---@type discordia
local discordia = require('discordia')
---@type typed
local typed = require('typed')
local uv = require('uv')
local fs = require('fs')

local new_fs_event = uv.new_fs_event

local configValidation = typed.Schema('CommandUtil.config')
   -- TODO :field('allowMention', 'boolean', true)
   -- TODO :field('blockBots', 'boolean', true)
   -- TODO :field('handleEdits', 'boolean', false)
   -- TODO :field('prefix', 'string | string[] | function')
   :field('watch', 'boolean', false)
   :field('unloadOnError', 'boolean', true)
   :field('directory', 'string')

---@alias _events string
---| "'unload'"
---| "'changed'"
---| "'firstLoad'"

---@class CommandUtil_config
---@field public directory string The directory to search for commands
---@field public watch boolean | nil If set to true, it will watch `directory` for changes
---@field public unloadOnError boolean | nil If set to true, it will unload the command if it had an error loading
-- TODO ---@field public allowMention boolean | nil Whether to allow the bots mention to work as a prefix
-- TODO ---@field public blockBots boolean | nil Whether or not to block bots from running commands
-- TODO ---@field public handleEdits boolean | nil Whether to rerun a command when an edit happens
-- TODO ---@field public prefix string | string[] | fun(msg: Message):string | string[] The prefix/prefixes/function to call to get a prefix/prefixes
local _config = {}

--- Command util is a class which loads commands from directories.
---@class CommandUtil
local CommandUtil = discordia.class('CommandUtil')

---@type CommandUtil | fun(client: SuperToastClient, config: CommandUtil_config)
CommandUtil = CommandUtil

--- Create a new command utility
---@param client SuperToastClient
---@param config CommandUtil_config
function CommandUtil:__init(client, config)
   self._client = client
   ---@type CommandUtil_config
   self._config = assert(configValidation:validate(config or {}))

   self._handles = {}
   self._indexed = {}
   self._maps = {}

   if self._config.watch then
      self:_watch(self._config.directory, function(...)
         self:_load(...)
      end)
   else
      self:_index(self._config.directory, self._indexed, function(...)
         self:_load(...)
      end)
   end
end

--- Cleanup the parts which are not critical.
---
--- The parts which are considered not critical would be indexed files and fs handles.
function CommandUtil:cleanup()
   self._indexed = {}

   for i = 1, #self._handles do
      self._handles[i]:stop()
   end

   self._handles = {}
   self._maps = {}
end

--- Default command loader
---@param path string
---@param event _events
---@param contents string | nil
function CommandUtil:_load(path, event, contents)
   if path:sub(#path - 2, #path) ~= 'lua' then
      return
   end

   if event == 'unload' then
      self._client:removeCommand(self._maps[path])
      self._client:warning('Unloaded %s', path)
      return
   end

   local sandbox = setmetatable({}, {__index = _G})

   sandbox.require = require

   local fn, syntax = load(contents, 'Load ' .. path, 't', sandbox)

   if not fn then
      return self._client:error(syntax)
   end

   local succ, res = pcall(fn)

   if not succ then
      if self._config.unloadOnError then
         self._client:removeCommand(self._maps[path])
      end

      return self._client:error(res)
   elseif not res then
      if self._config.unloadOnError then
         self._client:removeCommand(self._maps[path])
      end

      return self._client:error('Unable to locate command')
   end

   if event == 'changed' then
      self._client:removeCommand(self._maps[path])
   end

   self._maps[path] = res

   self._client:addCommand(res)

   self._client:debug('Loaded %s', path)
end

--- Load a command into the handler

--- Watch a directory
---@param path string
---@param cb fun(path: string, event: _events, contents: string | nil)
function CommandUtil:_watch(path, cb)
   self:_index(path, self._indexed, cb)

   local function watch(dir)
      local fsEvent = new_fs_event()

      fsEvent:start(dir, {}, function(err, file)
         if err then
            return
         end

         local filePath = pathJoin(dir, file)

         if not fs.existsSync(filePath) then
            self._indexed[filePath] = nil

            cb(filePath, 'unload')

            return
         end

         if self._indexed[filePath] then
            local contents = fs.readFileSync(filePath)

            if contents == self._indexed[filePath] then
               return
            else
               self._indexed[filePath] = contents

               -- New data

               cb(filePath, 'changed', self._indexed[filePath])
            end
         else
            self._indexed[filePath] = fs.readFileSync(filePath)

            -- New data, first change

            cb(filePath, 'firstLoad', self._indexed[filePath])
         end
      end)

      table.insert(self._handles, fsEvent) -- prob better way *cough* UV_FS_EVENT_RECURSIVE *cough*

      for fileName, fileType in fs.scandirSync(dir) do
         local newDir = pathJoin(dir, fileName)

         if fileType == 'directory' then
            watch('./' .. newDir)
         end
      end
   end

   watch(path)
end

--- Index a directory for all the files within it
---@param dir string
function CommandUtil:_index(dir, tbl, cb)
   for fileName, fileType in fs.scandirSync(dir) do
      local path = pathJoin(dir, fileName)

		if fileType == 'file' then
         tbl[path] = fs.readFileSync(path)

         cb(path, 'firstLoad', tbl[path])
		else
			self:_index(path, tbl, cb)
		end
	end
end

return CommandUtil
