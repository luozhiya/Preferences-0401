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
  { 'glepnir/flybuf.nvim' },
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
  { 'nvim-lualine/lualine.nvim' },
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
  -- Session
  { 'Shatur/neovim-session-manager' },
  -- LSP Core
  { 'm-pilia/vim-ccls' },
  { 'jackguo380/vim-lsp-cxx-highlight' },
  { 'p00f/clangd_extensions.nvim' },
  { 'lvimuser/lsp-inlayhints.nvim' },
  { 'neovim/nvim-lspconfig' },
  { 'folke/neodev.nvim' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
}

local dap = {
  -- Debug
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
