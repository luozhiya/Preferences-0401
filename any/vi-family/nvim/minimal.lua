local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path })
end

require('paq')({
  'savq/paq-nvim',
  'nvim-lualine/lualine.nvim',
})

require('lualine').setup({
  sections = {
    lualine_b = { 'branch', 'diff', 'diagnostics' },
  },
})
