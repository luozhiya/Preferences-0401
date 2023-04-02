local bindings = require('module.bindings')

local M = {}
M.cached = {}

M.config = function(name)
  if vim.tbl_isempty(M.cached) then
    M.cached = {
      ['nvim-treesitter/nvim-treesitter'] = function() require('nvim-treesitter.configs').setup({ matchup = { enable = true }, ensure_installed = { 'cpp', 'c', 'lua', 'cmake' } }) end,
      ['stevearc/aerial.nvim'] = function()
        local opts = { backends = { 'treesitter', 'lsp' }, layout = { max_width = { 60, 0.4 } } }
        opts = vim.tbl_deep_extend('error', opts, bindings.aerial())
        require('aerial').setup(opts)
      end,
      ['folke/which-key.nvim'] = function()
        local wk = require('which-key')
        wk.setup()
        bindings.wk(wk)
      end,
      ['nvim-telescope/telescope.nvim'] = function()
        local telescope = require('telescope')
        telescope.setup(bindings.telescope())
        telescope.load_extension('undo')
        telescope.load_extension('fzf')
        telescope.load_extension('live_grep_args')
        telescope.load_extension('projects')
      end,
      ['lewis6991/gitsigns.nvim'] = function() require('gitsigns').setup() end,
      ['akinsho/toggleterm.nvim'] = function() require('toggleterm').setup(bindings.toggleterm()) end,
      ['nvim-tree/nvim-tree.lua'] = function()
        local opts = {
          sort_by = 'case_sensitive',
          sync_root_with_cwd = true,
          respect_buf_cwd = true,
          hijack_directories = { enable = false },
          update_focused_file = { enable = false, update_root = true },
          actions = { open_file = { resize_window = false } },
          view = { adaptive_size = false, preserve_window_proportions = true },
          git = { enable = false },
        }
        opts = vim.tbl_deep_extend('error', opts, bindings.nvim_tree())
        require('nvim-tree').setup(opts)
      end,
      ['stevearc/dressing.nvim'] = function()
        require('dressing').setup({
          input = { enabled = true, prompt_align = 'center', relative = 'editor', prefer_width = 0.6, win_options = { winblend = 0 } },
          select = { enabled = true, backend = { 'telescope' } },
        })
      end,
      ['ahmedkhalf/project.nvim'] = function() require('project_nvim').setup() end,
      ['j-hui/fidget.nvim'] = function() require('fidget').setup({ window = { blend = 0 } }) end,
      ['ray-x/lsp_signature.nvim'] = function() require('lsp_signature').setup({ hint_prefix = '< ' }) end,
      ['hrsh7th/nvim-cmp'] = function()
        local cmp = require('cmp')
        local opts = {
          sources = { { name = 'nvim_lsp' }, { name = 'path' } },
          snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        }
        opts = vim.tbl_deep_extend('error', opts, bindings.cmp(cmp))
        cmp.setup(opts)
        require('nvim-autopairs').setup({ disable_filetype = { 'dapui_watches' } })
        cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done({ map_char = { tex = '' } }))
        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = 'path' },
            { name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } },
          }),
        })
      end,
      ['HiPhish/nvim-ts-rainbow2'] = function() require('nvim-treesitter.configs').setup({ rainbow = { enable = { 'c', 'cpp' }, query = 'rainbow-parens', strategy = require('ts-rainbow').strategy['local'] } }) end,
      ['p00f/godbolt.nvim'] = function()
        require('godbolt').setup({
          languages = { cpp = { compiler = 'clangdefault', options = {} }, c = { compiler = 'cclangdefault', options = {} } }, -- vc2017_64
          url = 'http://localhost:10240', -- https://godbolt.org
        })
      end,
      ['lvimuser/lsp-inlayhints.nvim'] = function() require('lsp-inlayhints').setup() end,
      ['luukvbaal/nnn.nvim'] = function() require('nnn').setup() end,
      ['mhartington/formatter.nvim'] = function()
        require('formatter').setup({
          logging = false,
          filetype = {
            lua = { require('formatter.filetypes.lua').stylua },
            ['*'] = { require('formatter.filetypes.any').remove_trailing_whitespace },
          },
        })
      end,
      ['luukvbaal/statuscol.nvim'] = function()
        local builtin = require('statuscol.builtin')
        require('statuscol').setup({
          ft_ignore = { 'NvimTree' },
          segments = {
            { text = { '%s' }, click = 'v:lua.ScSa' },
            { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
            {
              text = { ' ', builtin.foldfunc, ' ' },
              condition = { builtin.not_empty, true, builtin.not_empty },
              click = 'v:lua.ScFa',
            },
          },
        })
      end,
      ['petertriho/nvim-scrollbar'] = function()
        local scrollbar = require('scrollbar')
        local colors = require('tokyonight.colors').setup()
        scrollbar.setup({
          handle = { color = colors.bg_highlight },
          excluded_filetypes = { 'prompt', 'TelescopePrompt', 'noice', 'notify' },
          marks = {
            Search = { color = colors.orange },
            Error = { color = colors.error },
            Warn = { color = colors.warning },
            Info = { color = colors.info },
            Hint = { color = colors.hint },
            Misc = { color = colors.purple },
          },
        })
      end,
      ['kevinhwang91/nvim-hlslens'] = function()
        require('hlslens').setup({
          build_position_cb = function(plist, _, _, _) require('scrollbar.handlers.search').handler.show(plist.start_pos) end,
        })
      end,
    }
  end
  return M.cached[name]
end

return M
