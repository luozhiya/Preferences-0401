-- Neovim default
-- vim.cmd([[filetype plugin indent on]]) -- use language‐specific plugins for indenting (better):
-- autoindent = true, -- neovim default true -- reproduce the indentation of the previous line

local bindings = require('module.bindings')

local M = {}

M.lazy = vim.fn.stdpath('config') .. '/lazy/lazy.nvim'
M.root = vim.fn.stdpath('config') .. '/lazy'

function M.before()
  bindings.setup_leader()

  vim.g.neovide_remember_window_size = true
  vim.g.neovide_refresh_rate_idle = 240
  vim.g.neovide_no_idle = true

  vim.g.loaded_python3_provider = 0
  vim.g.loaded_pythonx_provider = 0
  vim.g.loaded_ruby_provider = 0
  vim.g.loaded_perl_provider = 0
  vim.g.loaded_node_provider = 0
  vim.g.editorconfig = false

  local disabled_built_ins = {
    'gzip',
    'man',
    'matchit',
    'matchparen',
    'shada_plugin',
    'tarPlugin',
    'zipPlugin',
    'netrwPlugin',
    'spellfile_plugin',
    '2html_plugin',
    'tutor_mode_plugin',
    'remote_plugins',
    'zip',
    'xmlformat',
    'tar',
    'syntax_completion',
    'sql_completion',
    'shada_autoload',
    'netrwSettings',
    'netrw',
    'netrwFileHandlers',
  }
  for _, v in ipairs(disabled_built_ins) do
    vim.g['loaded_' .. v] = 1
  end

  vim.cmd([[
    autocmd Filetype log if getfsize(@%) > 1000000 | setlocal syntax=OFF | endif
    au FocusGained * :checktime
    aunmenu PopUp.How-to\ disable\ mouse
    aunmenu PopUp.-1-
  ]])

  local opts = {
    runtimepath = vim.opt.runtimepath:append(M.lazy),
    shellslash = true, -- A forward slash is used when expanding file names.
    laststatus = 3, -- Status line style
    cmdheight = 0, -- command-line
    showmode = false, -- Dont show mode since we have a statusline
    -- lazyredraw = true, -- no redraws in macros. Disabled for: https://github.com/neovim/neovim/issues/22674
    scrolloff = 4, -- Minimal number of screen lines to keep above and below the cursor.
    sidescrolloff = 8, -- The minimal number of screen columns to keep to the left and to the right of the cursor if 'nowrap' is set.
    number = false, -- Print line number
    signcolumn = 'yes:1',
    termguicolors = true, -- True color support
    wrap = false, -- Disable line wrap
    tabstop = 2, -- length of an actual \t character
    expandtab = true, -- if set, only insert spaces; otherwise insert \t and complete with spaces
    shiftwidth = 0, -- Number of spaces to use for each step of (auto)indent. (0 for ‘tabstop’)
    softtabstop = 0, -- length to use when editing text (eg. TAB and BS keys). (0 for ‘tabstop’, -1 for ‘shiftwidth’)
    shiftround = true, -- round indentation to multiples of 'shiftwidth' when shifting text
    smartindent = true, -- Insert indents automatically
    cinoptions = vim.opt.cinoptions:append({ 'g0', 'N-s', ':0', 'E-s' }), -- gN. See https://neovim.io/doc/user/indent.html#cinoptions-values
    synmaxcol = 200, -- don't syntax-highlight long lines
    ignorecase = true, -- Ignore case
    smartcase = true, -- Don't ignore case with capitals
    clipboard = 'unnamedplus', -- allows neovim to access the system clipboard
    completeopt = { 'menuone', 'noselect', 'noinsert' },
    autoread = true, -- When a file has been detected to have been changed outside of Vim and it has not been changed inside of Vim, automatically read it again.
    guifont = 'InconsolataGo Nerd Font:h16',
    shortmess = 'oOcCIFW', -- See https://neovim.io/doc/user/options.html#'shortmess'
    timeout = true, -- Limit the time searching for suggestions to {millisec} milli seconds.
    timeoutlen = 500, -- the timeout when WhichKey opens is controlled by the vim setting timeoutlen.
    wildmode = 'full',
    updatetime = 300,
    incsearch = false,
    fillchars = vim.opt.fillchars:append('vert: '),
  }
  for k, v in pairs(opts) do
    vim.opt[k] = v
  end
end

M.after = function()
  vim.cmd([[colorscheme tokyonight]])
  bindings.setup_autocmd()
  bindings.setup_comands()
  bindings.setup_code()
end

return M
