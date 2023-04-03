local M = {}

local list = {
  -- Foundation
  { 'nvim-lua/plenary.nvim' },
  -- Treesitter
  { 'nvim-treesitter/nvim-treesitter' },
  -- Telescope
  { 'nvim-telescope/telescope.nvim' },
  { 'nvim-telescope/telescope-fzf-native.nvim' },
  { 'debugloop/telescope-undo.nvim' },
  { 'nvim-telescope/telescope-live-grep-args.nvim' },
  { 'stevearc/aerial.nvim' },
  { 'ahmedkhalf/project.nvim' },
  -- Completion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'L3MON4D3/LuaSnip' },
  -- Git
  { 'lewis6991/gitsigns.nvim' },
  { 'sindrets/diffview.nvim' },
  -- Buffer
  { 'kazhala/close-buffers.nvim' },
  -- Key Management
  { 'folke/which-key.nvim' },
  -- Appearance
  { 'MunifTanjim/nui.nvim' },
  { 'stevearc/dressing.nvim' },
  { 'j-hui/fidget.nvim' },
  { 'nvim-tree/nvim-tree.lua' },
  { 'akinsho/toggleterm.nvim' },
  { 'folke/tokyonight.nvim' },
  { 'luukvbaal/statuscol.nvim' },
  { 'petertriho/nvim-scrollbar' },
  { 'kevinhwang91/nvim-hlslens' },
  { 'obaland/vfiler.vim' },
  { 'nvim-neo-tree/neo-tree.nvim' },
  -- Edit
  { 'tpope/vim-obsession' },
  { 'windwp/nvim-autopairs' },
  { 'numToStr/Comment.nvim' },
  { 'fedepujol/move.nvim' },
  { 'ray-x/lsp_signature.nvim' },
  { 'folke/trouble.nvim' },
  { 'lukas-reineke/indent-blankline.nvim' },
  { 'HiPhish/nvim-ts-rainbow2' },
  { 'p00f/godbolt.nvim' },
  { 'luukvbaal/nnn.nvim' },
  { 'mhartington/formatter.nvim' },
  { 'andymass/vim-matchup' },
  { 'DNLHC/glance.nvim' },
  { 'm-pilia/vim-ccls' },
  { 'jackguo380/vim-lsp-cxx-highlight' },
  -- Session
  { 'Shatur/neovim-session-manager' },
  -- LSP Core
  { 'neovim/nvim-lspconfig' },
  { 'lvimuser/lsp-inlayhints.nvim' },
  { 'folke/neodev.nvim' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
}

local platform = function()
  if require('base').is_kernel() then
    return {
      -- Debug
      { 'mfussenegger/nvim-dap' },
      { 'theHamsta/nvim-dap-virtual-text' },
      { 'rcarriga/nvim-dap-ui' },
      { 'Weissle/persistent-breakpoints.nvim' },
    }
  end
  return {}
end

local cached = {}
M.computed = function()
  if vim.tbl_isempty(cached) then
    vim.list_extend(list, platform())
    for i, v in pairs(list) do
      cached[i] = require('module.settings').spec(v[1])
    end
  end
  return cached
end

return M
