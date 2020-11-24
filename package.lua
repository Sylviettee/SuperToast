return {
   name = 'SovietKitsune/SuperToast',
   version = '0.3.3',
   description = 'The better Toast',
   tags = {'toast', 'discordia'},
   license = 'MIT',
   author = {name = 'Soviet Kitsune', email = 'sovietkitsune@soviet.solutions'},
   homepage = 'https://github.com/SovietKitsune/SuperToast',
   dependencies = {
      'SinisterRectus/discordia@2.8.4',
      'SovietKitsune/typed@1.0.2'
   },
   files = {
      '**.lua', '!spec*', '!util', '!main.lua' -- Utils are for running and ops
   }
}
