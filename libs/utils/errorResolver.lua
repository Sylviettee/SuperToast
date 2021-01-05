local default = {
   GUILD_ONLY = 'This command must be ran in a guild!',
   NSFW_ONLY = 'This command must be ran in a NSFW channel!',
   OWNER_ONLY = 'This command must be ran by an owner of the bot!',
}

---@param cmd Command
---@param err string
return function(cmd, err, customMsg)
   if default[err] then
      return default[err]
   end

   if err == 'MISSING_PERMISSIONS' then
      return 'This command requires ' .. table.concat(cmd.userPermissions, ', ')
   elseif err == 'SELF_MISSING_PERMISSIONS' then
      return 'I need ' .. table.concat(cmd.botPermissions, ', ')
   elseif err == 'MISSING_ROLES' or err == 'SELF_MISSING_ROLES' then
      return 'You/I are missing roles required' -- TODO; resolve names
   else
      if customMsg then
         return customMsg
      else
         return 'Checks failed while running this command, `' .. err .. '`'
      end
   end
end
