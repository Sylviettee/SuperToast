return {
   name = 'SovietKitsune/SuperToast',
   version = '0.1.1',
   description = 'The better Toast',
   tags = {'toast', 'discordia'},
   license = 'MIT',
   author = {name = 'Soviet Kitsune', email = 'sovietkitsune@soviet.solutions'},
   homepage = 'https://github.com/SovietKitsune/SuperToast',
   dependencies = {},
   files = {
      '**.lua', '!test*', '!util', -- Utils are for running and ops
      'template.lua' -- Generates more types
   }
}
