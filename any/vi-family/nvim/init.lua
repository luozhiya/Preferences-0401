local opt = require('module.options')
opt.before()
if not vim.loop.fs_stat(opt.lazy) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=latest', -- latest stable release
    opt.lazy,
  })
end
require('lazy').setup('module.plugins', {
  root = opt.root,
  concurrency = 2,
  defaults = { lazy = true },
  readme = { enabled = false },
})
opt.after()
