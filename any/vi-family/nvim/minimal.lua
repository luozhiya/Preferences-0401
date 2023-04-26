-- local fn = vim.fn
-- local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'

-- if fn.empty(fn.glob(install_path)) > 0 then
--   fn.system({ 'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path })
-- end

-- require('paq')({
--   'savq/paq-nvim',
--   'luukvbaal/statuscol.nvim',
--   'b0o/incline.nvim',
-- })

local function augroup(name) return vim.api.nvim_create_augroup('bindings_' .. name, { clear = true }) end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI', 'TermClose', 'TermLeave' }, {
  group = augroup('checktime'),
  pattern = '*',
  command = 'checktime',
})
