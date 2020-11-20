local default = {
   GUILD_ONLY = 'This command must be ran in a guild!',
   NSFW_ONLY = 'This command must be ran in a NSFW channel!'
}

---@param cmd Command
---@param err string
return function(cmd, err)
   if default[err] then
      return default[err]
   end

   if err == 'MISSING_PERMISSIONS' then
      return 'This command requires ' .. table.concat(cmd.user_permissions, ', ')
   elseif err == 'SELF_MISSING_PERMISSIONS' then
      return 'I need ' .. table.concat(cmd.bot_permissions, ', ')
   elseif err == 'MISSING_ROLES' or err == 'SELF_MISSING_ROLES' then
      return 'You/I are missing roles required' -- TODO; resolve names
   else
      -- Custom
      -- TODO; allow customs to have errors
      return 'Checks failed while running this command, `' .. err .. '`'
   end
end
