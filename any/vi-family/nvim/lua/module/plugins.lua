local M = {}

local list = {
  -- Neovim Lua Library
  { 'nvim-lua/plenary.nvim' },
  { 'MunifTanjim/nui.nvim' },
  -- Bars And Lines
  { 'petertriho/nvim-scrollbar' },
  { 'nvim-lualine/lualine.nvim' },
  { 'luukvbaal/statuscol.nvim' },
  { 'utilyre/barbecue.nvim' },
  { 'SmiteshP/nvim-navic' },
  { 'b0o/incline.nvim' },
  { 'archibate/lualine-time' },
  -- Colorschemes
  { 'folke/tokyonight.nvim' },
  -- Builtin UI Improved
  { 'stevearc/dressing.nvim' },
  { 'rcarriga/nvim-notify' },
  { 'folke/noice.nvim' },
  { 'vigoux/notifier.nvim' },
  -- Sudo
  { 'lambdalisue/suda.vim' },
  -- File Explorer
  { 'nvim-tree/nvim-tree.lua' },
  { 'obaland/vfiler.vim' },
  { 'nvim-neo-tree/neo-tree.nvim' },
  { 'luukvbaal/nnn.nvim' },
  -- Terminal Integration
  { 'akinsho/toggleterm.nvim' },
  -- Project
  { 'ahmedkhalf/project.nvim' },
  -- Session
  { 'tpope/vim-obsession' },
  { 'Shatur/neovim-session-manager' },
  -- Git
  { 'lewis6991/gitsigns.nvim' },
  { 'sindrets/diffview.nvim' },
  -- Fuzzy Finder
  { 'nvim-telescope/telescope.nvim' },
  { 'nvim-telescope/telescope-fzf-native.nvim' },
  { 'debugloop/telescope-undo.nvim' },
  { 'nvim-telescope/telescope-live-grep-args.nvim' },
  -- Key Management
  { 'folke/which-key.nvim' },
  -- Buffer
  { 'kazhala/close-buffers.nvim' },
  { 'glepnir/flybuf.nvim' },
  -- Syntax
  { 'nvim-treesitter/nvim-treesitter' },
  -- Editing Support
  { 'fedepujol/move.nvim' },
  { 'andymass/vim-matchup' },
  { 'windwp/nvim-autopairs' },
  { 'numToStr/Comment.nvim' },
  { 'm4xshen/autoclose.nvim' },
  { 'nacro90/numb.nvim' },
  -- Search
  { 'kevinhwang91/nvim-hlslens' },
  -- Formatting
  { 'mhartington/formatter.nvim' },
  { 'lukas-reineke/indent-blankline.nvim' },
  { 'HiPhish/nvim-ts-rainbow2' },
  { 'luochen1990/rainbow' },
  -- Completion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-nvim-lsp' },
  -- Snippet
  { 'L3MON4D3/LuaSnip' },
  -- C++
  { 'p00f/godbolt.nvim' },
  { 'Xertes0/cppdoc.nvim' },
  -- Diagnostics
  { 'folke/trouble.nvim' },
  -- LSP Functional
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'm-pilia/vim-ccls' },
  { 'p00f/clangd_extensions.nvim' },
  { 'folke/neodev.nvim' },
  { 'theHamsta/nvim-semantic-tokens' },
  -- LSP Visualization/Interactive
  { 'ray-x/lsp_signature.nvim' },
  { 'jackguo380/vim-lsp-cxx-highlight' },
  { 'lvimuser/lsp-inlayhints.nvim' },
  { 'glepnir/lspsaga.nvim' },
  { 'DNLHC/glance.nvim' },
  { 'j-hui/fidget.nvim' },
  { 'stevearc/aerial.nvim' },
  { 'VidocqH/lsp-lens.nvim' },
}

local dap = {
  -- DAP VIF
  { 'mfussenegger/nvim-dap' },
  { 'theHamsta/nvim-dap-virtual-text' },
  { 'rcarriga/nvim-dap-ui' },
  { 'Weissle/persistent-breakpoints.nvim' },
}

local cached = {}
M.computed = function()
  if vim.tbl_isempty(cached) then
    if require('base').is_kernel() then vim.list_extend(list, dap) end
    for i, v in pairs(list) do
      cached[i] = require('module.settings').spec(v[1])
    end
  end
  return cached
end

return M
