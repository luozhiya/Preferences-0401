local M = {}

local list = {
  -- Neovim Lua Library
  { 'nvim-lua/plenary.nvim' },
  { 'anuvyklack/middleclass' },
  -- Storage
  { 'kkharji/sqlite.lua' },
  { 'tpope/vim-dadbod' },
  { 'kristijanhusak/vim-dadbod-ui' },
  -- UI Library
  { 'MunifTanjim/nui.nvim' },
  { 'ray-x/guihua.lua' },
  { 'anuvyklack/hydra.nvim' },
  { 'anuvyklack/animation.nvim' },
  -- Start Screen
  { 'nvimdev/dashboard-nvim' },
  { 'echasnovski/mini.starter' },
  { 'goolord/alpha-nvim' },
  -- Columns And Lines
  { 'luukvbaal/statuscol.nvim' },
  { 'yaocccc/nvim-foldsign' },  
  { 'petertriho/nvim-scrollbar' },
  { 'dstein64/nvim-scrollview' },
  { 'lewis6991/satellite.nvim' },
  { 'utilyre/barbecue.nvim' },
  { 'b0o/incline.nvim' },
  { 'nvim-lualine/lualine.nvim' },
  { 'archibate/lualine-time' },
  { 'nanozuki/tabby.nvim' },
  { 'akinsho/bufferline.nvim' },
  { 'romgrk/barbar.nvim' },
  -- Colorschemes
  { 'folke/tokyonight.nvim' },
  { 'gosukiwi/vim-atom-dark' },
  { 'shaunsingh/oxocarbon.nvim' },
  { 'ellisonleao/gruvbox.nvim' },
  { 'catppuccin/nvim', name = 'catppuccin' },
  { 'p00f/alabaster.nvim' },
  { 'charkuils/nvim-whisky' },
  { 'Yazeed1s/minimal.nvim' },
  -- Icon
  { 'nvim-tree/nvim-web-devicons' },
  -- Builtin UI Improved (notify/input/select/quick)
  { 'stevearc/dressing.nvim' },
  { 'CosmicNvim/cosmic-ui' },
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
  { 'nikvdp/neomux' },
  -- Window Management
  { 'spolu/dwm.vim' },
  { 'sindrets/winshift.nvim' },
  { 'mrjones2014/smart-splits.nvim' },
  { 'anuvyklack/windows.nvim' },
  -- Project
  { 'ahmedkhalf/project.nvim' },
  { 'pluffie/neoproj' },
  { 'gnikdroy/projections.nvim' },
  -- Todo
  { 'folke/todo-comments.nvim' },
  -- Session
  { 'tpope/vim-obsession' },
  { 'Shatur/neovim-session-manager' },
  { 'rmagatti/auto-session' },
  { 'folke/persistence.nvim' },
  { 'vladdoster/remember.nvim' },
  { 'ethanholz/nvim-lastplace' },
  -- View
  { 'folke/zen-mode.nvim' },
  { 'Pocco81/true-zen.nvim' },
  -- Git
  { 'lewis6991/gitsigns.nvim' },
  { 'sindrets/diffview.nvim' },
  { 'f-person/git-blame.nvim' },
  { 'TimUntersberger/neogit' },
  -- Fuzzy Finder
  { 'nvim-telescope/telescope.nvim' },
  { 'nvim-telescope/telescope-fzf-native.nvim' },
  { 'nvim-telescope/telescope-live-grep-args.nvim' },
  { 'nvim-telescope/telescope-ui-select.nvim' },
  { 'nvim-telescope/telescope-file-browser.nvim' },
  { 'nvim-telescope/telescope-dap.nvim' },
  { 'cljoly/telescope-repo.nvim' },
  { 'junegunn/fzf' },
  { 'junegunn/fzf.vim' },
  { 'romgrk/fzy-lua-native' },
  -- Bindings Management
  { 'folke/which-key.nvim' },
  { 'linty-org/key-menu.nvim' },
  { 'mrjones2014/legendary.nvim' },
  { 'b0o/mapx.nvim' },
  { 'anuvyklack/keymap-layer.nvim' },
  { 'anuvyklack/keymap-amend.nvim' },
  -- Buffer
  { 'kazhala/close-buffers.nvim' },
  { 'glepnir/flybuf.nvim' },
  { 'moll/vim-bbye' },
  { 'echasnovski/mini.bufremove' },
  { 'jlanzarotta/bufexplorer' },
  { 'kwkarlwang/bufresize.nvim' },
  -- Syntax
  { 'nvim-treesitter/nvim-treesitter' },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  { 'chrisgrieser/nvim-various-textobjs' },
  { 'RRethy/nvim-treesitter-textsubjects' },
  { 'RRethy/nvim-treesitter-endwise' },
  { 'nvim-treesitter/playground' },
  { 'ziontee113/neo-minimap' },
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
  { 'anuvyklack/vim-smartword' },
  -- Comment
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
  -- Undo
  { 'mbbill/undotree' },
  { 'debugloop/telescope-undo.nvim' },
  -- Marks
  { 'chentoast/marks.nvim' },
  -- Folding
  { 'anuvyklack/pretty-fold.nvim' },
  { 'anuvyklack/fold-preview.nvim' },
  { 'kevinhwang91/nvim-ufo' },
  -- Editing Visual Formatting
  { 'mhartington/formatter.nvim' },
  { 'lukas-reineke/indent-blankline.nvim' },
  { 'HiPhish/nvim-ts-rainbow2' },
  { 'folke/twilight.nvim' },
  { 'echasnovski/mini.indentscope' },
  { 'NvChad/nvim-colorizer.lua' },
  { 'RRethy/vim-illuminate' },
  { 'kevinhwang91/promise-async' },
  -- Editing Action
  { 'AntonVanAssche/date-time-inserter.nvim' },
  { 'ziontee113/color-picker.nvim' },
  { 'nvim-colortils/colortils.nvim' },
  { 'uga-rosa/ccc.nvim' },
  { 'ThePrimeagen/refactoring.nvim' },
  { 'charkuils/nvim-soil' },
  { 'chrishrb/gx.nvim' },
  { 'axieax/urlview.nvim' },
  { 'ellisonleao/carbon-now.nvim' },
  { 'jbyuki/venn.nvim' },
  -- Completion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-emoji' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'onsails/lspkind.nvim' },
  { 'gelguy/wilder.nvim' },
  -- Snippet
  { 'L3MON4D3/LuaSnip' },
  { 'rafamadriz/friendly-snippets' },
  -- C++
  { 'p00f/godbolt.nvim' },
  { 'Xertes0/cppdoc.nvim' },
  { 'Civitasv/cmake-tools.nvim' },
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
  { 'b0o/SchemaStore.nvim' },
  -- LSP Visualization/Interactive
  { 'ray-x/lsp_signature.nvim' },
  { 'jackguo380/vim-lsp-cxx-highlight' },
  { 'lvimuser/lsp-inlayhints.nvim' },
  { 'nvimdev/lspsaga.nvim' },
  { 'DNLHC/glance.nvim' },
  { 'j-hui/fidget.nvim' },
  { 'stevearc/aerial.nvim' },
  { 'VidocqH/lsp-lens.nvim' },
  { 'simrat39/symbols-outline.nvim' },
  { 'rmagatti/goto-preview' },
  { 'ray-x/navigator.lua' },
  { 'lewis6991/hover.nvim' },
  { 'Fildo7525/pretty_hover' },
  { name = 'lsp_lines.nvim', url = 'https://git.sr.ht/~whynothugo/lsp_lines.nvim' },
  { 'nvim-lua/lsp-status.nvim' },
  { 'kosayoda/nvim-lightbulb' },
  { 'SmiteshP/nvim-navic' },
  -- Performance
  { 'dstein64/vim-startuptime' },
  -- Job
  { 'charkuils/nvim-spinetta' },
  -- Network
  { 'charkuils/nvim-ship' },
  -- Dev
  { name = 'lualine-osv', dir = '~/Code/me/lualine-osv' },
  -- DAP VIF
  { 'mfussenegger/nvim-dap' },
  { 'theHamsta/nvim-dap-virtual-text' },
  { 'rcarriga/nvim-dap-ui' },
  { 'Weissle/persistent-breakpoints.nvim' },
  { 'jbyuki/one-small-step-for-vimkind' },
}

local kernel = {}

-- Debug Mode Docker
local docker = function()
  return {
    { 'nvim-lua/plenary.nvim', lazy = false },
    -- { 'lewis6991/satellite.nvim', lazy = false, config = true },
    -- { 'nvim-telescope/telescope.nvim', lazy = false },
    -- { 'nvim-lualine/lualine.nvim', lazy = false, config = true },
    { 'nvim-tree/nvim-tree.lua', lazy = false, config = true },
  }
end

local cached = {}
M.computed = function()
  if vim.g.debug_mode == true then return docker() end
  if vim.tbl_isempty(cached) then
    local spec = require('module.settings').spec
    if require('base').is_kernel() then vim.list_extend(list, kernel) end
    for i, v in ipairs(list) do
      if v[1] then
        cached[i] = spec(v[1], false)
      else
        cached[i] = spec(v, true)
      end
    end
  end
  return cached
end

return M
