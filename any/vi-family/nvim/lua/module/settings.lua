local bindings = require('module.bindings')
local M = {}
local run = {}

run['Start Screen'] = {
  ['nvimdev/dashboard-nvim'] = {
    enabled = false,
    event = 'VimEnter',
    config = function()
      local opts = {
        -- theme = 'doom',
        config = {
          header = { 'Paper Tiger' },
          footer = { 'good good study, day day up' },
        },
      }
      require('dashboard').setup(opts)
    end,
  },
  ['echasnovski/mini.starter'] = {
    enabled = false,
    event = 'VimEnter',
    opts = function()
      local logo = table.concat({
        '██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z',
        '██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z',
        '██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z',
        '██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z',
        '███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║',
        '╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝',
      }, '\n')
      local pad = string.rep(' ', 22)
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require('mini.starter')
      --stylua: ignore
      local config = {
        evaluate_single = true,
        header = logo,
        items = {
          new_section("Find file",    "Telescope find_files", "Telescope"),
          new_section("Recent files", "Telescope oldfiles",   "Telescope"),
          new_section("Grep text",    "Telescope live_grep",  "Telescope"),
          new_section("init.lua",     "e $MYVIMRC",           "Config"),
          new_section("Lazy",         "Lazy",                 "Config"),
          new_section("New file",     "ene | startinsert",    "Built-in"),
          new_section("Quit",         "qa",                   "Built-in"),
          new_section("Session restore", [[lua require("persistence").load()]], "Session"),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(pad .. "░ ", false),
          starter.gen_hook.aligning("center", "center"),
        },
      }
      return config
    end,
    config = function(_, config)
      -- close Lazy and re-open when starter is ready
      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'MiniStarterOpened',
          callback = function() require('lazy').show() end,
        })
      end

      local starter = require('mini.starter')
      starter.setup(config)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        callback = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local pad_footer = string.rep(' ', 8)
          starter.config.footer = pad_footer .. '⚡ Neovim loaded ' .. stats.count .. ' plugins in ' .. ms .. 'ms'
          pcall(starter.refresh)
        end,
      })
    end,
  },
  ['goolord/alpha-nvim'] = {
    -- enabled = false,
    event = 'VimEnter',
    config = function()
      local dashboard = require('alpha.themes.dashboard')
      dashboard.section.header.val = {
        [[                   Paper Tiger                   ]],
        -- [[           good good study, day day up           ]],
      }
      dashboard.section.buttons.val = bindings.alpha_val(dashboard.button)
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = 'AlphaButtons'
        button.opts.hl_shortcut = 'AlphaShortcut'
      end
      dashboard.section.header.opts.hl = 'AlphaHeader'
      dashboard.section.buttons.opts.hl = 'AlphaButtons'
      dashboard.section.footer.opts.hl = 'AlphaFooter'
      dashboard.opts.layout[1].val = 2

      local alpha = require('alpha')
      alpha.setup(dashboard.config)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        callback = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = '⚡ Neovim loaded ' .. stats.count .. ' plugins in ' .. ms .. 'ms'
          pcall(alpha.redraw)
        end,
      })
    end,
  },
}

run['Bars And Lines'] = {
  ['luukvbaal/statuscol.nvim'] = {
    event = 'BufReadPost',
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
    event = { 'User NeXT' },
    -- enable = false,
    config = function()
      local scrollbar = require('scrollbar')
      local colors = require('tokyonight.colors').setup()
      scrollbar.setup({
        handle = { color = colors.green2 },
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
    event = { 'User NeXT' },
    config = function()
      local function lsp_active()
        local names = {}
        local bufnr = vim.api.nvim_get_current_buf()
        for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
          table.insert(names, client.name)
        end
        return vim.tbl_isempty(names) and '' or ' ' .. table.concat(names, ' ')
        -- return 'LSP<' .. table.concat(names, ', ') .. '>'
      end
      local function location() return string.format('%3d:%-2d ', vim.fn.line('.'), vim.fn.virtcol('.')) end
      local fileformat = { 'fileformat', icons_enabled = false }
      local opts = {
        sections = {
          lualine_x = { 'cdate', 'ctime', lsp_active, 'encoding', fileformat, 'filetype' },
          lualine_z = { location },
        },
      }
      require('lualine').setup(opts)
    end,
  },
  ['utilyre/barbecue.nvim'] = {
    event = { 'User NeXT' },
    config = function()
      local opts = {
        show_dirname = false,
      }
      require('barbecue').setup(opts)
    end,
  },
  ['b0o/incline.nvim'] = {
    event = { 'BufReadPost' },
    config = function()
      local colors = require('tokyonight.colors').setup()
      local opts = {
        -- highlight = {
        --   groups = {
        --     InclineNormal = { guibg = '#FC56B1', guifg = colors.black },
        --     InclineNormalNC = { guifg = '#FC56B1', guibg = colors.black },
        --   },
        -- },
        window = { margin = { vertical = 0, horizontal = 1 } },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
          local icon, color = require('nvim-web-devicons').get_icon_color(filename)
          return { { icon }, { ' ' }, { filename } }
        end,
      }
      require('incline').setup(opts)
    end,
  },
}

run['Colorschemes'] = {
  ['folke/tokyonight.nvim'] = {
    lazy = false,
    priority = 1000,
    config = function() vim.cmd([[colorscheme tokyonight-moon]]) end,
  },
}

run['Icon'] = {
  ['nvim-tree/nvim-web-devicons'] = {
    config = function() require('nvim-web-devicons').setup() end,
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
    -- enabled = false,
    config = function()
      local opts = {
        stages = 'static',
      }
      require('notify').setup(opts)
      vim.notify = require('notify')
    end,
  },
  ['folke/noice.nvim'] = {
    -- enabled = false,
    event = { 'User NeXT' },
    config = function()
      require('noice').setup({
        lsp = {
          hover = {
            enabled = false,
          },
          progress = {
            enabled = false,
          },
        },
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
      })
    end,
  },
  ['vigoux/notifier.nvim'] = {
    enabled = false,
    event = 'VeryLazy',
    config = function()
      local opts = {
        components = { -- Order of the components to draw from top to bottom (first nvim notifications, then lsp)
          'nvim', -- Nvim notifications (vim.notify and such)
          -- "lsp"  -- LSP status updates
        },
      }
      require('notifier').setup(opts)
    end,
  },
}

run['Sudo'] = {
  ['lambdalisue/suda.vim'] = {
    cmd = { 'SudaRead', 'SudaWrite' },
  },
}

run['File Explorer'] = {
  ['nvim-tree/nvim-tree.lua'] = {
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
    config = function()
      local opts = {
        sort_by = 'case_sensitive',
        sync_root_with_cwd = false,
        respect_buf_cwd = false,
        hijack_directories = { enable = true },
        update_focused_file = { enable = true, update_root = false },
        actions = { open_file = { resize_window = false } },
        view = { adaptive_size = false, preserve_window_proportions = true, width = { min = 40 } },
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
        -- async_directory_scan = 'never',
        -- log_level = 'trace',
        -- log_to_file = false,
        close_if_last_window = true,
        -- source_selector = { winbar = true, statusline = true },
        filesystem = {
          bind_to_cwd = false,
          follow_current_file = true,
        },
        default_component_configs = {
          indent = {
            with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = '',
            expander_expanded = '',
            expander_highlight = 'NeoTreeExpander',
          },
        },
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.neotree())
      require('neo-tree').setup(opts)
    end,
  },
  ['luukvbaal/nnn.nvim'] = {
    cmd = { 'NnnExplorer', 'NnnPicker' },
    config = function() require('nnn').setup() end,
  },
  ['lmburns/lf.nvim'] = {
    enabled = false,
    config = function() require('lf').setup() end,
  },
}

run['Terminal Integration'] = {
  ['akinsho/toggleterm.nvim'] = {
    cmd = { 'ToggleTerm' },
    config = function()
      local opts = {
        autochdir = true,
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.toggleterm())
      require('toggleterm').setup(opts)
    end,
  },
}

run['Project'] = {
  ['ahmedkhalf/project.nvim'] = {
    -- event = { 'BufReadPost' },
    event = { 'VeryLazy' },
    config = function()
      require('project_nvim').setup({
        silent_chdir = true,
      })
    end,
  },
}

run['Todo'] = {
  ['folke/todo-comments.nvim'] = {
    event = { 'BufReadPost' },
    config = function() require('todo-comments').setup() end,
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
  ['folke/persistence.nvim'] = {
    event = 'BufReadPre',
    config = function() require('persistence').setup() end,
  },
}

run['View'] = {
  ['folke/zen-mode.nvim'] = {
    cmd = { 'ZenMode' },
    config = function() require('zen-mode').setup() end,
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
  ['f-person/git-blame.nvim'] = {
    enabled = false,
    event = 'BufReadPost',
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
            sort_mru = true,
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
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}

run['Editing Motion Support'] = {
  ['andymass/vim-matchup'] = {
    event = 'BufReadPost',
  },
  ['fedepujol/move.nvim'] = {
    cmd = { 'MoveLine', 'MoveBlock', 'MoveHChar', 'MoveHBlock' },
  },
  ['m4xshen/autoclose.nvim'] = {
    event = 'BufReadPost',
    config = function() require('autoclose').setup() end,
  },
  ['nacro90/numb.nvim'] = {
    -- keys = { { ';' } },
    event = 'VeryLazy',
    config = function() require('numb').setup() end,
  },
  ['folke/twilight.nvim'] = {
    cmd = { 'Twilight', 'TwilightEnable' },
    config = function() require('twilight').setup() end,
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
      local unix_ff = function() vim.cmd([[set ff=unix]]) end
      require('formatter').setup({
        logging = false,
        filetype = {
          lua = { require('formatter.filetypes.lua').stylua },
          ['*'] = {
            require('formatter.filetypes.any').remove_trailing_whitespace,
            unix_ff,
          },
        },
      })
    end,
  },
  ['lukas-reineke/indent-blankline.nvim'] = {
    event = { 'BufReadPost', 'BufNewFile' },
  },
  ['HiPhish/nvim-ts-rainbow2'] = {
    -- enabled = false,
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
  ['echasnovski/mini.indentscope'] = {
    enabled = false,
    event = 'BufReadPost',
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'lazy', 'mason' },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
      local opts = {
        -- symbol = "▏",
        symbol = '│',
        options = { try_as_border = true },
      }
      require('mini.indentscope').setup(opts)
    end,
  },
  ['NvChad/nvim-colorizer.lua'] = {
    event = 'BufReadPost',
    config = function() require('colorizer').setup() end,
  },
}

run['Editing Piece'] = {
  ['AntonVanAssche/date-time-inserter.nvim'] = {
    enabled = false,
  },
}

run['Completion'] = {
  ['hrsh7th/nvim-cmp'] = {
    -- enabled = false,
    event = { 'BufReadPost', 'CmdlineEnter' },
    dependencies = { 'hrsh7th/cmp-cmdline', 'hrsh7th/cmp-path', 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer' },
    config = function()
      local cmp = require('cmp')
      local opts = {
        sources = { { name = 'nvim_lsp' }, { name = 'path' } },
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.cmp(cmp))
      cmp.setup(opts)
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
          { name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } },
        }),
      })
      cmp.setup.cmdline('/', { mapping = cmp.mapping.preset.cmdline(), sources = { { name = 'buffer' } } })
      cmp.event:on('confirm_done', function(evt)
        local cxxindent = { 'public:', 'private:', 'protected:' }
        if vim.tbl_contains(cxxindent, evt.entry:get_word()) then
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'i', true)
          -- local keymap = require('cmp.utils.keymap')
          -- vim.api.nvim_feedkeys(keymap.t('<cr>'), 'i', true)
          -- vim.api.nvim_feedkeys('<cr>', 'i', true)
        end
      end)
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
    config = function() require('trouble').setup({ icons = true }) end,
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
    -- enabled = false,
    event = { 'LspAttach' },
    config = function()
      vim.cmd([[highlight FidgetTitle ctermfg=110 guifg=#0887c7]])
      vim.cmd([[highlight FidgetTask ctermfg=110 guifg=#0887c7]])
      require('fidget').setup({ text = { done = ' ' }, window = { blend = 0 } })
    end,
  },
  ['ray-x/lsp_signature.nvim'] = {
    enabled = false,
    event = { 'LspAttach' },
    config = function() require('lsp_signature').setup({ hint_prefix = ' ' }) end,
  },
  ['glepnir/lspsaga.nvim'] = {
    enabled = false,
    cmd = { 'Lspsaga' },
    config = function()
      local opts = {
        diagnostic = {
          show_code_action = true,
          show_source = true,
          jump_num_shortcut = true,
          max_width = 0.7,
          keys = {
            exec_action = 'o',
            quit = 'q',
            go_action = 'g',
          },
        },
      }
      require('lspsaga').setup(opts)
    end,
  },
  ['theHamsta/nvim-semantic-tokens'] = {
    enabled = false,
    event = { 'LspAttach' },
    config = function()
      local opts = {
        preset = 'default',
        -- highlighters is a list of modules following the interface of nvim-semantic-tokens.table-highlighter or
        -- function with the signature: highlight_token(ctx, token, highlight) where
        --        ctx (as defined in :h lsp-handler)
        --        token  (as defined in :h vim.lsp.semantic_tokens.on_full())
        --        highlight (a helper function that you can call (also multiple times) with the determined highlight group(s) as the only parameter)
        highlighters = { require('nvim-semantic-tokens.table-highlighter') },
      }
      require('nvim-semantic-tokens').setup(opts)
    end,
  },
  ['VidocqH/lsp-lens.nvim'] = {
    enabled = false,
    event = { 'LspAttach' },
    config = function() require('lsp-lens').setup() end,
  },
  ['simrat39/symbols-outline.nvim'] = {
    event = { 'LspAttach' },
    config = function() require('symbols-outline').setup() end,
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
