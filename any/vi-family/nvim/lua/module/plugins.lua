local spec = require('module.settings').spec
local M = {}
M.list = {
  -- Foundation
  { 'nvim-lua/plenary.nvim' },
  -- Treesitter
  spec('nvim-treesitter/nvim-treesitter'),
  -- Telescope
  spec('nvim-telescope/telescope.nvim'),
  spec('nvim-telescope/telescope-fzf-native.nvim'),
  { 'debugloop/telescope-undo.nvim' },
  { 'nvim-telescope/telescope-live-grep-args.nvim' },
  spec('stevearc/aerial.nvim'),
  spec('ahmedkhalf/project.nvim'),
  -- Completion
  spec('hrsh7th/nvim-cmp'),
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'L3MON4D3/LuaSnip' },
  -- Git
  spec('lewis6991/gitsigns.nvim'),
  { 'sindrets/diffview.nvim', cmd = { 'DiffviewOpen' } },
  -- Buffer
  { 'kazhala/close-buffers.nvim', cmd = { 'CloseView', 'BWipeout' } },
  -- Key Management
  spec('folke/which-key.nvim'),
  -- Appearance
  spec('stevearc/dressing.nvim'),
  spec('j-hui/fidget.nvim'),
  spec('nvim-tree/nvim-tree.lua'),
  spec('akinsho/toggleterm.nvim'),
  { 'folke/tokyonight.nvim', lazy = false, priority = 1000 },
  spec('luukvbaal/statuscol.nvim'),
  spec('petertriho/nvim-scrollbar'),
  spec('kevinhwang91/nvim-hlslens'),
  -- Edit
  { 'tpope/vim-obsession', cmd = { 'Obsession' } },
  { 'windwp/nvim-autopairs' },
  { 'numToStr/Comment.nvim' },
  { 'fedepujol/move.nvim', cmd = { 'MoveLine', 'MoveBlock', 'MoveHChar', 'MoveHBlock' } },
  spec('ray-x/lsp_signature.nvim'),
  { 'folke/trouble.nvim', cmd = { 'TroubleToggle' } },
  { 'lukas-reineke/indent-blankline.nvim', event = { 'BufReadPost', 'BufNewFile' } },
  spec('HiPhish/nvim-ts-rainbow2'),
  spec('p00f/godbolt.nvim'),
  spec('luukvbaal/nnn.nvim'),
  spec('mhartington/formatter.nvim'),
  { 'andymass/vim-matchup', event = 'BufReadPost' },
  -- LSP Core
  spec('neovim/nvim-lspconfig'),
  { 'lvimuser/lsp-inlayhints.nvim' },
  { 'folke/neodev.nvim' },
}

-- Debug
local _dap = function()
  if require('base').is_kernel() then
    return {
      spec('mfussenegger/nvim-dap'),
      { 'theHamsta/nvim-dap-virtual-text' },
      { 'rcarriga/nvim-dap-ui' },
      { 'Weissle/persistent-breakpoints.nvim' },
    }
  end
  return {}
end

vim.list_extend(M.list, _dap())
return M
