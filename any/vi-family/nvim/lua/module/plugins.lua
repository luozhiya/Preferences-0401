local config = require('module.settings').config
return {
  -- Foundation
  { 'nvim-lua/plenary.nvim' },
  -- Treesitter
  { 'nvim-treesitter/nvim-treesitter', cmd = { 'TSInstall', 'TSBufEnable', 'TSBufDisable', 'TSModuleInfo' }, build = ':TSUpdate', config = config('nvim-treesitter/nvim-treesitter') },
  -- Telescope
  { 'nvim-telescope/telescope.nvim', cmd = { 'Telescope' }, config = config('nvim-telescope/telescope.nvim') },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
  { 'debugloop/telescope-undo.nvim' },
  { 'nvim-telescope/telescope-live-grep-args.nvim' },
  { 'stevearc/aerial.nvim', config = config('stevearc/aerial.nvim') },
  { 'ahmedkhalf/project.nvim', event = { 'VeryLazy' }, config = config('ahmedkhalf/project.nvim') },
  -- Completion
  { 'hrsh7th/nvim-cmp', event = { 'BufReadPost' }, config = config('hrsh7th/nvim-cmp'), dependencies = { 'hrsh7th/cmp-cmdline', 'hrsh7th/cmp-path', 'hrsh7th/cmp-nvim-lsp' } },
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'L3MON4D3/LuaSnip' },
  -- Git
  { 'lewis6991/gitsigns.nvim', event = 'BufReadPost', config = config('lewis6991/gitsigns.nvim') },
  { 'sindrets/diffview.nvim', cmd = { 'DiffviewOpen' } },
  -- Buffer
  { 'kazhala/close-buffers.nvim', cmd = { 'CloseView', 'BWipeout' } },
  -- Key Management
  { 'folke/which-key.nvim', keys = { { ',' }, { 'g' } }, config = config('folke/which-key.nvim') },
  -- Appearance
  { 'stevearc/dressing.nvim', event = { 'VeryLazy' }, config = config('stevearc/dressing.nvim') },
  { 'j-hui/fidget.nvim', config = config('j-hui/fidget.nvim') },
  { 'nvim-tree/nvim-tree.lua', cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' }, config = config('nvim-tree/nvim-tree.lua') },
  { 'akinsho/toggleterm.nvim', cmd = { 'ToggleTerm' }, config = config('akinsho/toggleterm.nvim') },
  { 'folke/tokyonight.nvim', lazy = false, priority = 1000 },
  -- Edit
  { 'tpope/vim-obsession', cmd = { 'Obsession' } },
  { 'windwp/nvim-autopairs' },
  { 'numToStr/Comment.nvim' },
  { 'fedepujol/move.nvim', cmd = { 'MoveLine', 'MoveBlock', 'MoveHChar', 'MoveHBlock' } },
  { 'ray-x/lsp_signature.nvim', config = config('ray-x/lsp_signature.nvim') },
  { 'folke/trouble.nvim', cmd = { 'TroubleToggle' } },
  { 'lukas-reineke/indent-blankline.nvim', event = { 'BufReadPost', 'BufNewFile' } },
  { 'HiPhish/nvim-ts-rainbow2', event = 'BufReadPost', config = config('HiPhish/nvim-ts-rainbow2') },
  { 'p00f/godbolt.nvim', cmd = { 'Godbolt' }, config = config('p00f/godbolt.nvim') },
  { 'luukvbaal/nnn.nvim', cmd = { 'NnnExplorer', 'NnnPicker' }, config = config('luukvbaal/nnn.nvim') },
  -- LSP Core
  { 'neovim/nvim-lspconfig', ft = { 'c', 'cpp', 'lua' }, config = require('module.lsp').setup, dependencies = { 'j-hui/fidget.nvim', 'ray-x/lsp_signature.nvim' } },
  { 'lvimuser/lsp-inlayhints.nvim', event = 'LspAttach', config = config('lvimuser/lsp-inlayhints.nvim') },
  { 'folke/neodev.nvim' },
}
