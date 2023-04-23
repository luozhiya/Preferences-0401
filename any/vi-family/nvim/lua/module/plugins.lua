local M = {}

local list = {
  -- Neovim Lua Library
  { 'nvim-lua/plenary.nvim' },
  -- Storage
  { 'kkharji/sqlite.lua' },
  { 'tpope/vim-dadbod' },
  { 'kristijanhusak/vim-dadbod-ui' },
  -- UI Library
  { 'MunifTanjim/nui.nvim' },
  { 'ray-x/guihua.lua' },
  { 'anuvyklack/hydra.nvim' },
  -- Start Screen
  { 'nvimdev/dashboard-nvim' },
  { 'echasnovski/mini.starter' },
  { 'goolord/alpha-nvim' },
  -- Bars And Lines
  { 'petertriho/nvim-scrollbar' },
  { 'nvim-lualine/lualine.nvim' },
  { 'luukvbaal/statuscol.nvim' },
  { 'utilyre/barbecue.nvim' },
  { 'SmiteshP/nvim-navic' },
  { 'b0o/incline.nvim' },
  { 'archibate/lualine-time' },
  { 'nanozuki/tabby.nvim' },
  { 'akinsho/bufferline.nvim' },
  { 'ziontee113/neo-minimap' },
  { 'yaocccc/nvim-foldsign' },
  -- Colorschemes
  { 'folke/tokyonight.nvim' },
  { 'gosukiwi/vim-atom-dark' },
  { 'shaunsingh/oxocarbon.nvim' },
  { 'ellisonleao/gruvbox.nvim' },
  -- { "catppuccin/nvim" },
  { 'p00f/alabaster.nvim' },
  { 'charkuils/nvim-whisky' },
  -- Icon
  { 'nvim-tree/nvim-web-devicons' },
  -- Builtin UI Improved
  { 'stevearc/dressing.nvim' },
  { 'rcarriga/nvim-notify' },
  { 'folke/noice.nvim' },
  { 'vigoux/notifier.nvim' },
  { 'kevinhwang91/nvim-bqf' },
  -- Sudo
  { 'lambdalisue/suda.vim' },
  -- File Explorer
  { 'nvim-tree/nvim-tree.lua' },
  { 'obaland/vfiler.vim' },
  { 'nvim-neo-tree/neo-tree.nvim' },
  { 'luukvbaal/nnn.nvim' },
  { 'lmburns/lf.nvim' },
  -- Terminal Integration
  { 'akinsho/toggleterm.nvim' },
  -- Window Management
  { 'spolu/dwm.vim' },
  -- Project
  { 'ahmedkhalf/project.nvim' },
  { 'cljoly/telescope-repo.nvim' },
  -- Todo
  { 'folke/todo-comments.nvim' },
  -- Session
  { 'tpope/vim-obsession' },
  { 'Shatur/neovim-session-manager' },
  { 'folke/persistence.nvim' },
  -- View
  { 'folke/zen-mode.nvim' },
  { 'Pocco81/true-zen.nvim' },
  -- Git
  { 'lewis6991/gitsigns.nvim' },
  { 'sindrets/diffview.nvim' },
  { 'f-person/git-blame.nvim' },
  -- Fuzzy Finder
  { 'nvim-telescope/telescope.nvim' },
  { 'nvim-telescope/telescope-fzf-native.nvim' },
  { 'debugloop/telescope-undo.nvim' },
  { 'nvim-telescope/telescope-live-grep-args.nvim' },
  { 'junegunn/fzf' },
  { 'junegunn/fzf.vim' },
  -- Key Management
  { 'folke/which-key.nvim' },
  { 'linty-org/key-menu.nvim' },
  { 'mrjones2014/legendary.nvim' },
  -- Buffer
  { 'kazhala/close-buffers.nvim' },
  { 'glepnir/flybuf.nvim' },
  { 'moll/vim-bbye' },
  { 'echasnovski/mini.bufremove' },
  -- Syntax
  { 'nvim-treesitter/nvim-treesitter' },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  { 'chrisgrieser/nvim-various-textobjs' },
  { 'RRethy/nvim-treesitter-textsubjects' },
  { 'RRethy/nvim-treesitter-endwise' },
  { 'nvim-treesitter/playground' },
  -- Editing Motion Support
  { 'fedepujol/move.nvim' },
  { 'andymass/vim-matchup' },
  { 'windwp/nvim-autopairs' },
  { 'echasnovski/mini.pairs' },
  { 'm4xshen/autoclose.nvim' },
  { 'nacro90/numb.nvim' },
  { 'ggandor/leap.nvim' },
  { 'ggandor/flit.nvim' },
  { 'echasnovski/mini.surround' },
  { 'Wansmer/treesj' },
  { 'haya14busa/vim-asterisk' },
  { 'mg979/vim-visual-multi' },
  { 'charkuils/nvim-hemingway' },
  { 'numToStr/Comment.nvim' },
  { 'JoosepAlviste/nvim-ts-context-commentstring' },
  { 'echasnovski/mini.comment' },
  -- Yank
  { 'gbprod/yanky.nvim' },
  -- Search
  { 'kevinhwang91/nvim-hlslens' },
  { 'windwp/nvim-spectre' },
  { 'cshuaimin/ssr.nvim' },
  -- Editing Visual Formatting
  { 'mhartington/formatter.nvim' },
  { 'lukas-reineke/indent-blankline.nvim' },
  { 'HiPhish/nvim-ts-rainbow2' },
  { 'folke/twilight.nvim' },
  { 'echasnovski/mini.indentscope' },
  { 'NvChad/nvim-colorizer.lua' },
  { 'RRethy/vim-illuminate' },
  { 'kevinhwang91/promise-async' },
  { 'kevinhwang91/nvim-ufo' },
  -- Editing Action
  { 'AntonVanAssche/date-time-inserter.nvim' },
  { 'ziontee113/color-picker.nvim' },
  { 'uga-rosa/ccc.nvim' },
  { 'ThePrimeagen/refactoring.nvim' },
  { 'charkuils/nvim-soil' },
  { 'chrishrb/gx.nvim' },
  { 'axieax/urlview.nvim' },
  -- Completion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'onsails/lspkind.nvim' },
  { 'gelguy/wilder.nvim' },
  -- Snippet
  { 'L3MON4D3/LuaSnip' },
  { 'rafamadriz/friendly-snippets' },
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
  { 'smjonas/inc-rename.nvim' },
  { 'jose-elias-alvarez/null-ls.nvim' },
  -- LSP Visualization/Interactive
  { 'ray-x/lsp_signature.nvim' },
  { 'jackguo380/vim-lsp-cxx-highlight' },
  { 'lvimuser/lsp-inlayhints.nvim' },
  { 'glepnir/lspsaga.nvim' },
  { 'DNLHC/glance.nvim' },
  { 'j-hui/fidget.nvim' },
  { 'stevearc/aerial.nvim' },
  { 'VidocqH/lsp-lens.nvim' },
  { 'simrat39/symbols-outline.nvim' },
  { 'rmagatti/goto-preview' },
  { 'ray-x/navigator.lua' },
  -- Performance
  { 'dstein64/vim-startuptime' },
  -- Job
  { 'charkuils/nvim-spinetta' },
  -- Network
  { 'charkuils/nvim-ship' },
}

local kernel = {
  -- DAP VIF
  { 'mfussenegger/nvim-dap' },
  { 'theHamsta/nvim-dap-virtual-text' },
  { 'rcarriga/nvim-dap-ui' },
  { 'Weissle/persistent-breakpoints.nvim' },
  -- C++
  { 'Civitasv/cmake-tools.nvim' },
  -- Fuzzy Finder
  { 'romgrk/fzy-lua-native' },
}

local cached = {}
M.computed = function()
  if vim.tbl_isempty(cached) then
    if require('base').is_kernel() then vim.list_extend(list, kernel) end
    for i, v in pairs(list) do
      cached[i] = require('module.settings').spec(v[1])
    end
  end
  return cached
end

return M
