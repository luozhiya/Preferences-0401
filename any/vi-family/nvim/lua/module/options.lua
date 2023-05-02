local bindings = require('module.bindings')
local base = require('base')

local M = {}

M.lazy = base.to_native(vim.fn.stdpath('config') .. '/lazy/lazy.nvim')
M.root = base.to_native(vim.fn.stdpath('config') .. '/lazy')

M.icons = {
  diagnostics = {
    Error = ' ', -- 
    Warn = ' ', -- 
    Hint = ' ', -- 
    Info = ' ', -- 
  },
  collects = {
    Tomatoes = ' ',
    Pagelines = ' ',
    Search = ' ',
    File = ' ',
    Connectdevelop = ' ',
    Chrome = ' ',
    Firefox = ' ',
    IE = ' ',
    ListAlt = ' ',
    Modx = ' ',
    Cogs = ' ',
  },
  git = {
    added = ' ',
    modified = ' ',
    removed = ' ',
  },
  kinds = {
    Array = ' ',
    Boolean = ' ',
    Class = ' ',
    Color = ' ',
    Constant = ' ',
    Constructor = ' ',
    Copilot = ' ',
    Enum = ' ',
    EnumMember = ' ',
    Event = ' ',
    Field = ' ',
    File = ' ',
    Folder = ' ',
    Function = ' ',
    Interface = ' ',
    Key = ' ',
    Keyword = ' ',
    Method = ' ',
    Module = ' ',
    Namespace = ' ',
    Null = ' ',
    Number = ' ',
    Object = ' ',
    Operator = ' ',
    Package = ' ',
    Property = ' ',
    Reference = ' ',
    Snippet = ' ',
    String = ' ',
    Struct = ' ',
    Text = ' ',
    TypeParameter = ' ',
    Unit = ' ',
    Value = ' ',
    Variable = ' ',
  },
}

function M.before()
  bindings.setup_leader()

  vim.g.debug_mode = false -- true false
  vim.g.lsp_cpp_provider = 'clangd' -- ccls clangd
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

  -- Remove Neovim tips menu
  vim.cmd([[
    aunmenu PopUp.How-to\ disable\ mouse
    aunmenu PopUp.-1-
  ]])

  -- Neovim default
  -- vim.cmd([[filetype plugin indent on]]) -- use language‐specific plugins for indenting (better):
  -- autoindent = true, -- reproduce the indentation of the previous line
  local opts = {
    -- System
    runtimepath = vim.opt.runtimepath:append(M.lazy),
    -- shellslash = true, -- A forward slash is used when expanding file names. -- Bug: neo-tree
    -- lazyredraw = true, -- no redraws in macros. Disabled for: https://github.com/neovim/neovim/issues/22674
    clipboard = 'unnamedplus', -- Allows neovim to access the system clipboard
    -- Appearance
    termguicolors = true, -- True color support
    shortmess = 'oOcCIFW', -- See https://neovim.io/doc/user/options.html#'shortmess'
    showmode = false, -- Dont show mode since we have a statusline
    laststatus = 3, -- Status line style
    cmdheight = 0, -- Command-line.
    showtabline = 2, -- Always display tabline
    signcolumn = 'yes', -- Always show the signcolumn, otherwise it would shift the text each time
    scrolloff = 4, -- Minimal number of screen lines to keep above and below the cursor.
    sidescrolloff = 8, -- The minimal number of screen columns to keep to the left and to the right of the cursor if 'nowrap' is set.
    winminwidth = 5, -- Minimum window width
    cursorline = true, -- Enable highlighting of the current line
    number = true, -- Print line number
    relativenumber = true, -- Relative line numbers
    -- Formatting
    wrap = false, -- Disable line wrap
    tabstop = 2, -- Length of an actual \t character
    expandtab = true, -- Ff set, only insert spaces; otherwise insert \t and complete with spaces
    shiftwidth = 0, -- Number of spaces to use for each step of (auto)indent. (0 for ‘tabstop’)
    softtabstop = 0, -- length to use when editing text (eg. TAB and BS keys). (0 for ‘tabstop’, -1 for ‘shiftwidth’)
    shiftround = true, -- Round indentation to multiples of 'shiftwidth' when shifting text
    smartindent = true, -- Insert indents automatically
    cinoptions = vim.opt.cinoptions:append({ 'g0', 'N-s', ':0', 'E-s' }), -- gN. See https://neovim.io/doc/user/indent.html#cinoptions-values
    synmaxcol = 300, -- Don't syntax-highlight long lines
    ignorecase = true, -- Ignore case
    -- smartcase = true, -- Don't ignore case with capitals
    -- Completion
    completeopt = { 'menuone', 'noselect', 'noinsert' },
    wildmode = 'full', -- Command-line completion mode
    -- Fold
    fillchars = { foldopen = '', foldclose = '', fold = ' ', foldsep = ' ', diff = '╱', eob = ' ', vert = ' ' },
    foldlevel = 99,
    foldlevelstart = 99,
    foldenable = true,
    foldcolumn = '0',
    foldmethod = 'expr',
    foldexpr = 'nvim_treesitter#foldexpr()',
    -- Split Windows
    splitkeep = 'screen', -- Stable current window line
    splitbelow = true, -- Put new windows below current
    splitright = true, -- Put new windows right of current
    -- Edit
    incsearch = false,
    autoread = true, -- When a file has been detected to have been changed outside of Vim and it has not been changed inside of Vim, automatically read it again.
    undofile = true,
    undolevels = 10000,
    swapfile = false, -- Bug: Crashed Neovide
    -- Misc
    timeout = true, -- Limit the time searching for suggestions to {millisec} milli seconds.
    timeoutlen = 300, -- The timeout when WhichKey opens is controlled by the vim setting timeoutlen.
    updatetime = 100, -- Save swap file and trigger CursorHold
    fileformats = 'unix,dos,mac', -- Detect formats
    sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize' },
    confirm = true, -- Confirm to save changes before exiting modified buffer
    conceallevel = 3, -- Hide * markup for bold and italic, also make json hide '"'
    mouse = 'a', -- Enable mouse for all available modes
    -- virtualedit = 'block', -- Allow going past the end of line in visual block mode
    virtualedit = 'all', -- This will allow you to freely move the cursor in the buffer. (see help virtualedit).
  }
  for k, v in pairs(opts) do
    vim.opt[k] = v
  end
  -- Neovide GUI
  if vim.g.neovide then
    vim.opt.guifont = 'InconsolataGo Nerd Font:h16'
    -- vim.opt.guifont = 'FiraCode Nerd Font Mono:h15'
    -- vim.opt.guifont = { 'FiraCode Nerd Font Mono', 'h9' }
    -- vim.opt.guifont = { 'InconsolataGo Nerd Font', 'h16' }
    -- vim.g.neovide_scale_factor = 0.3
    -- vim.g.neovide_remember_window_size = true
    vim.g.neovide_refresh_rate_idle = 120
    -- vim.g.neovide_no_idle = true -- Bug: Cycle Windows will cause neovide hang
    vim.g.neovide = nil -- Slient "Noice may not work correctly with Neovide. Please see #17"
  end
end

M.after = function()
  bindings.setup_autocmd()
  bindings.setup_comands()
  bindings.setup_code()
end

return M
