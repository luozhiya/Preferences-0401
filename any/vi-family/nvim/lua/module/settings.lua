local bindings = require('module.bindings')
local M = {}

local run = {}
run['Bars And Lines'] = {
  ['luukvbaal/statuscol.nvim'] = {
    event = 'User NeXT',
    config = function()
      vim.opt.foldcolumn = '1'
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
  },
  ['petertriho/nvim-scrollbar'] = {
    event = 'User NeXT',
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
  },
  ['nvim-lualine/lualine.nvim'] = {
    event = 'User NeXT',
    config = function()
      local function lsp_active()
        local names = {}
        for _, client in pairs(vim.lsp.get_active_clients()) do
          table.insert(names, client.name)
        end
        return 'LSP<' .. table.concat(names, ', ') .. '>'
      end
      local function location() return string.format('%3d:%-2d ', vim.fn.line('.'), vim.fn.virtcol('.')) end
      local fileformat = { 'fileformat', icons_enabled = false }
      require('lualine').setup({
        sections = {
          lualine_x = { lsp_active, 'encoding', fileformat, 'filetype' },
          lualine_z = { location },
        },
      })
    end,
  },
}

run['Colorschemes'] = {
  ['folke/tokyonight.nvim'] = {
    lazy = false,
    priority = 1000,
    config = function() vim.cmd([[colorscheme tokyonight]]) end,
  },
}

run['Builtin UI Improved'] = {
  ['stevearc/dressing.nvim'] = {
    event = { 'User NeXT' },
    config = function()
      require('dressing').setup({
        input = {
          enabled = true,
          prompt_align = 'center',
          relative = 'editor',
          prefer_width = 0.6,
          win_options = { winblend = 0 },
        },
        select = { enabled = true, backend = { 'telescope' } },
      })
    end,
  },
  ['rcarriga/nvim-notify'] = {
    event = 'User NeXT',
    config = function()
      require('notify').setup()
      vim.notify = require('notify')
    end,
  },
  ['folke/noice.nvim'] = {
    event = 'User NeXT',
    config = function()
      require('noice').setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      })
    end,
  },
}

run['File Explorer'] = {
  ['nvim-tree/nvim-tree.lua'] = {
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
    config = function()
      local opts = {
        sort_by = 'case_sensitive',
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        hijack_directories = { enable = false },
        update_focused_file = { enable = true, update_root = true },
        actions = { open_file = { resize_window = false } },
        view = { adaptive_size = false, preserve_window_proportions = true },
        git = { enable = false },
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.nvim_tree())
      require('nvim-tree').setup(opts)
    end,
  },
  ['obaland/vfiler.vim'] = {
    cmd = { 'VFiler' },
    config = function()
      require('vfiler/config').setup({
        options = {
          auto_cd = true,
          auto_resize = true,
          keep = true,
          layout = 'left',
          name = 'explorer',
          width = 30,
          columns = 'indent,icon,name',
        },
      })
    end,
  },
  ['nvim-neo-tree/neo-tree.nvim'] = {
    cmd = { 'Neotree' },
    config = function()
      vim.g.neo_tree_remove_legacy_commands = 1
      local opts = {
        async_directory_scan = 'never',
        log_level = 'trace',
        log_to_file = true,
        close_if_last_window = true,
        source_selector = { winbar = false, statusline = false },
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.neotree())
      require('neo-tree').setup(opts)
    end,
  },
  ['luukvbaal/nnn.nvim'] = {
    cmd = { 'NnnExplorer', 'NnnPicker' },
    config = function() require('nnn').setup() end,
  },
}

run['Terminal Integration'] = {
  ['akinsho/toggleterm.nvim'] = {
    cmd = { 'ToggleTerm' },
    config = function() require('toggleterm').setup(bindings.toggleterm()) end,
  },
}

run['Project'] = {
  ['ahmedkhalf/project.nvim'] = {
    config = function()
      require('project_nvim').setup({
        silent_chdir = true,
      })
    end,
  },
}

run['Session'] = {
  ['tpope/vim-obsession'] = {
    cmd = { 'Obsession' },
  },
  ['Shatur/neovim-session-manager'] = {
    cmd = { 'SessionManager' },
    config = function()
      local Path = require('plenary.path')
      require('session_manager').setup({
        sessions_dir = Path:new(require('base').to_native(vim.fn.stdpath('data') .. '/sessions')),
      })
    end,
  },
}

run['Git'] = {
  ['lewis6991/gitsigns.nvim'] = {
    event = 'BufReadPost',
    config = true,
  },
  ['sindrets/diffview.nvim'] = {
    cmd = { 'DiffviewOpen' },
  },
}

run['Fuzzy Finder'] = {
  ['nvim-telescope/telescope.nvim'] = {
    cmd = { 'Telescope' },
    config = function()
      local telescope = require('telescope')
      local opts = {
        pickers = {
          buffers = {
            ignore_current_buffer = false,
            sort_lastused = true,
          },
        },
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.telescope())
      telescope.setup(opts)
      telescope.load_extension('undo')
      telescope.load_extension('fzf')
      telescope.load_extension('live_grep_args')
      telescope.load_extension('projects')
    end,
  },
  ['nvim-telescope/telescope-fzf-native.nvim'] = {
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
  },
}

run['Key Management'] = {
  ['folke/which-key.nvim'] = {
    keys = { { ',' }, { 'g' } },
    config = function()
      local wk = require('which-key')
      wk.setup()
      bindings.wk(wk)
    end,
  },
}

run['Buffer'] = {
  ['kazhala/close-buffers.nvim'] = {
    cmd = { 'CloseView', 'BWipeout' },
  },
  ['glepnir/flybuf.nvim'] = {
    cmd = { 'FlyBuf' },
    config = true,
  },
}

run['Syntax'] = {
  ['nvim-treesitter/nvim-treesitter'] = {
    cmd = { 'TSInstall', 'TSBufEnable', 'TSBufDisable', 'TSModuleInfo' },
    build = ':TSUpdate',
    config = function()
      local opts = {
        matchup = { enable = true },
        ensure_installed = { 'cpp', 'c', 'lua', 'cmake' },
      }
      if vim.g.NeXT == true then
        vim.list_extend(opts.ensure_installed, { 'regex', 'bash', 'markdown', 'markdown_inline' })
      end
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}

run['Editing Support'] = {
  ['andymass/vim-matchup'] = {
    event = 'BufReadPost',
  },
  ['fedepujol/move.nvim'] = {
    cmd = { 'MoveLine', 'MoveBlock', 'MoveHChar', 'MoveHBlock' },
  },
}

run['Search'] = {
  ['kevinhwang91/nvim-hlslens'] = {
    event = 'BufReadPost',
    config = function()
      require('hlslens').setup({
        build_position_cb = function(plist, _, _, _) require('scrollbar.handlers.search').handler.show(plist.start_pos) end,
      })
    end,
  },
}

run['Formatting'] = {
  ['mhartington/formatter.nvim'] = {
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
  },
  ['lukas-reineke/indent-blankline.nvim'] = {
    event = { 'BufReadPost', 'BufNewFile' },
  },
  ['HiPhish/nvim-ts-rainbow2'] = {
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
  },
}

run['Completion'] = {
  ['hrsh7th/nvim-cmp'] = {
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
      cmp.event:on(
        'confirm_done',
        require('nvim-autopairs.completion.cmp').on_confirm_done({ map_char = { tex = '' } })
      )
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
          { name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } },
        }),
      })
    end,
  },
}

run['C++'] = {
  ['p00f/godbolt.nvim'] = {
    cmd = { 'Godbolt' },
    config = function()
      require('godbolt').setup({
        languages = {
          cpp = { compiler = 'clangdefault', options = {} },
          c = { compiler = 'cclangdefault', options = {} },
        }, -- vc2017_64
        url = 'http://localhost:10240', -- https://godbolt.org
      })
    end,
  },
  ['Xertes0/cppdoc.nvim'] = {
    config = function() require('cppdoc').setup() end,
  },
}

run['Diagnostics'] = {
  ['folke/trouble.nvim'] = {
    cmd = { 'TroubleToggle' },
  },
}

run['LSP VIF'] = {
  ['stevearc/aerial.nvim'] = {
    config = function()
      local opts = { backends = { 'treesitter', 'lsp' }, layout = { max_width = { 60, 0.4 } } }
      opts = vim.tbl_deep_extend('error', opts, bindings.aerial())
      require('aerial').setup(opts)
    end,
  },
  ['DNLHC/glance.nvim'] = {
    cmd = { 'Glance' },
    config = function()
      require('glance').setup({
        border = {
          enable = true,
          top_char = '―',
          bottom_char = '―',
        },
        hooks = {
          before_open = function(results, open, jump, method)
            if #results == 1 then
              jump(results[1])
            else
              open(results)
            end
          end,
        },
      })
    end,
  },
  ['jackguo380/vim-lsp-cxx-highlight'] = {
    event = 'User ccls',
  },
  ['m-pilia/vim-ccls'] = {
    event = 'User ccls',
  },
  ['neovim/nvim-lspconfig'] = {
    ft = { 'c', 'cpp', 'lua' },
    config = require('module.lsp').lsp,
  },
  ['j-hui/fidget.nvim'] = {
    config = function() require('fidget').setup({ text = { done = ' ' }, window = { blend = 0 } }) end,
  },
  ['ray-x/lsp_signature.nvim'] = {
    config = function() require('lsp_signature').setup({ hint_prefix = ' ' }) end,
  },
}

run['DAP VIF'] = {
  ['mfussenegger/nvim-dap'] = {
    config = require('module.lsp').dap,
  },
}

local cached = {}
M.spec = function(url)
  if vim.tbl_isempty(cached) then
    for _, v in pairs(run) do
      cached = vim.tbl_deep_extend('error', cached, v)
    end
  end
  return vim.tbl_deep_extend('error', { url }, cached[url] or {})
end
return M
