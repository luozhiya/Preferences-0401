local bindings = require('module.bindings')

local M = {}
M.cached = {}

M.spec = function(url)
  if vim.tbl_isempty(M.cached) then
    M.cached = {
      ['nvim-treesitter/nvim-treesitter'] = function()
        return {
          cmd = { 'TSInstall', 'TSBufEnable', 'TSBufDisable', 'TSModuleInfo' },
          build = ':TSUpdate',
          config = function()
            require('nvim-treesitter.configs').setup({
              matchup = { enable = true },
              ensure_installed = { 'cpp', 'c', 'lua', 'cmake' },
            })
          end,
        }
      end,
      ['nvim-telescope/telescope.nvim'] = function()
        return {
          cmd = { 'Telescope' },
          config = function()
            local telescope = require('telescope')
            telescope.setup(bindings.telescope())
            telescope.load_extension('undo')
            telescope.load_extension('fzf')
            telescope.load_extension('live_grep_args')
            telescope.load_extension('projects')
          end,
        }
      end,
      ['nvim-telescope/telescope-fzf-native.nvim'] = function()
        return {
          build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
        }
      end,
      ['stevearc/aerial.nvim'] = function()
        return {
          config = function()
            local opts = { backends = { 'treesitter', 'lsp' }, layout = { max_width = { 60, 0.4 } } }
            opts = vim.tbl_deep_extend('error', opts, bindings.aerial())
            require('aerial').setup(opts)
          end,
        }
      end,
      ['ahmedkhalf/project.nvim'] = function()
        return {
          event = { 'VeryLazy' },
          config = function() require('project_nvim').setup() end,
        }
      end,
      ['hrsh7th/nvim-cmp'] = function()
        return {
          event = { 'BufReadPost' },
          dependencies = { 'hrsh7th/cmp-cmdline', 'hrsh7th/cmp-path', 'hrsh7th/cmp-nvim-lsp' },
          config = function()
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
        }
      end,
      ['lewis6991/gitsigns.nvim'] = function()
        return {
          event = 'BufReadPost',
          config = function() require('gitsigns').setup() end,
        }
      end,
      ['folke/which-key.nvim'] = function()
        return {
          keys = { { ',' }, { 'g' } },
          config = function()
            local wk = require('which-key')
            wk.setup()
            bindings.wk(wk)
          end,
        }
      end,
      ['stevearc/dressing.nvim'] = function()
        return {
          event = { 'VeryLazy' },
          config = function()
            require('dressing').setup({
              input = { enabled = true, prompt_align = 'center', relative = 'editor', prefer_width = 0.6, win_options = { winblend = 0 } },
              select = { enabled = true, backend = { 'telescope' } },
            })
          end,
        }
      end,
      ['j-hui/fidget.nvim'] = function()
        return {
          config = function() require('fidget').setup({ window = { blend = 0 } }) end,
        }
      end,
      ['nvim-tree/nvim-tree.lua'] = function()
        return {
          cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
          config = function()
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
        }
      end,
      ['akinsho/toggleterm.nvim'] = function()
        return {
          cmd = { 'ToggleTerm' },
          config = function() require('toggleterm').setup(bindings.toggleterm()) end,
        }
      end,
      ['folke/tokyonight.nvim'] = function() return { lazy = false, priority = 1000 } end,
      ['luukvbaal/statuscol.nvim'] = function()
        return {
          event = 'BufReadPost',
          config = function()
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
        }
      end,
      ['petertriho/nvim-scrollbar'] = function()
        return {
          event = 'BufReadPost',
          config = function()
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
        }
      end,
      ['kevinhwang91/nvim-hlslens'] = function()
        return {
          event = 'BufReadPost',
          config = function()
            require('hlslens').setup({
              build_position_cb = function(plist, _, _, _) require('scrollbar.handlers.search').handler.show(plist.start_pos) end,
            })
          end,
        }
      end,
      ['ray-x/lsp_signature.nvim'] = function()
        return {
          config = function() require('lsp_signature').setup({ hint_prefix = '< ' }) end,
        }
      end,
      ['HiPhish/nvim-ts-rainbow2'] = function()
        return {
          event = 'BufReadPost',
          config = function()
            require('nvim-treesitter.configs').setup({
              rainbow = {
                enable = { 'c', 'cpp' },
                query = 'rainbow-parens',
                strategy = require('ts-rainbow').strategy['local'],
              },
            })
          end,
        }
      end,
      ['p00f/godbolt.nvim'] = function()
        return {
          cmd = { 'Godbolt' },
          config = function()
            require('godbolt').setup({
              languages = { cpp = { compiler = 'clangdefault', options = {} }, c = { compiler = 'cclangdefault', options = {} } }, -- vc2017_64
              url = 'http://localhost:10240', -- https://godbolt.org
            })
          end,
        }
      end,
      ['luukvbaal/nnn.nvim'] = function()
        return {
          cmd = { 'NnnExplorer', 'NnnPicker' },
          config = function() require('nnn').setup() end,
        }
      end,
      ['mhartington/formatter.nvim'] = function()
        return {
          cmd = { 'FormatWriteLock' },
          config = function()
            require('formatter').setup({
              logging = false,
              filetype = {
                lua = { require('formatter.filetypes.lua').stylua },
                ['*'] = { require('formatter.filetypes.any').remove_trailing_whitespace },
              },
            })
          end,
        }
      end,
    }
  end
  return vim.tbl_deep_extend('error', { url }, M.cached[url]())
end

return M
