local bindings = require('module.bindings')
local M = {}
local run = {}

run['Neovim Lua Library'] = {
  ['anuvyklack/middleclass'] = {},
}

run['Storage'] = {
  ['kkharji/sqlite.lua'] = {
    config = function()
      if require('base').is_windows() then
        local nvim = 'nvim.exe'
        vim.g.sqlite_clib_path = string.sub(vim.loop.exepath(nvim), 1, -(#nvim + 1)) .. 'sqlite3.dll'
      end
    end,
  },
  ['tpope/vim-dadbod'] = {
    cmd = { 'DB' },
  },
  ['kristijanhusak/vim-dadbod-ui'] = {
    -- sqlite:/path/to/sqlite_database.db
    cmd = { 'DBUIAddConnection' },
    dependencies = { 'tpope/vim-dadbod' },
  },
}

run['UI Library'] = {
  ['ray-x/guihua.lua'] = {
    build = 'cd lua/fzy && make',
  },
  ['anuvyklack/animation.nvim'] = {
    dependencies = { 'anuvyklack/middleclass' },
  },
}

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
      local _new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require('mini.starter')
      --stylua: ignore
      local config = {
        evaluate_single = true,
        header = logo,
        items = {
          _new_section("Find file",    "Telescope find_files", "Telescope"),
          _new_section("Recent files", "Telescope oldfiles",   "Telescope"),
          _new_section("Grep text",    "Telescope live_grep",  "Telescope"),
          _new_section("init.lua",     "e $MYVIMRC",           "Config"),
          _new_section("Lazy",         "Lazy",                 "Config"),
          _new_section("New file",     "ene | startinsert",    "Built-in"),
          _new_section("Quit",         "qa",                   "Built-in"),
          _new_section("Session restore", [[lua require("persistence").load()]], "Session"),
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
        [[                    Why or Why not                    ]],
        -- [[                   Paper Tiger                   ]],
        -- [[           good good study, day day up           ]],
      }
      dashboard.section.buttons.val = bindings.alpha()
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

run['Columns And Lines'] = {
  -- Status column plugin that provides a configurable 'statuscolumn' and click handlers.
  ['luukvbaal/statuscol.nvim'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      vim.opt.foldcolumn = '1'
      local builtin = require('statuscol.builtin')
      local opts = {
        ft_ignore = { 'NvimTree', 'Outline' },
        segments = {
          { text = { '%s' }, click = 'v:lua.ScSa' },
          { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
          {
            text = { ' ', builtin.foldfunc, ' ' },
            condition = { builtin.not_empty, true, builtin.not_empty },
            click = 'v:lua.ScFa',
          },
        },
      }
      require('statuscol').setup(opts)
    end,
  },
  -- Display folding info on sign column
  ['yaocccc/nvim-foldsign'] = {
    config = function()
      local opts = {
        offset = -2,
        foldsigns = {
          open = '-', -- mark the beginning of a fold
          close = '+', -- show a closed fold
          seps = { '│', '┃' }, -- open fold middle marker
        },
      }
      require('nvim-foldsign').setup(opts)
    end,
  },
  ['petertriho/nvim-scrollbar'] = {
    enabled = false,
    event = { 'User NeXT' },
    config = function()
      local scrollbar = require('scrollbar')
      local colors = require('tokyonight.colors').setup()
      local opts = {
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
      }
      scrollbar.setup(opts)
    end,
  },
  ['lewis6991/satellite.nvim'] = {
    -- enabled = false,
    event = 'User NeXT', -- BufReadPost -- No Lazy
    config = function()
      local opts = {
        winblend = 0,
      }
      require('satellite').setup(opts)
    end,
  },
  ['dstein64/nvim-scrollview'] = {
    config = function()
      require('scrollview').setup({
        current_only = true,
      })
    end,
  },
  ['nvim-lualine/lualine.nvim'] = {
    -- event = { 'User NeXT' },
    event = { 'User AlphaClosed', 'BufNewFile', 'BufReadPost', 'BufNew', 'User HijackDirectories' },
    config = function()
      local icons = require('module.options').icons
      local _lsp_active = function()
        local names = {}
        local bufnr = vim.api.nvim_get_current_buf()
        for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
          table.insert(names, client.name)
        end
        return vim.tbl_isempty(names) and '' or icons.collects.Tomatoes .. table.concat(names, ' ')
        -- return 'LSP<' .. table.concat(names, ', ') .. '>'
      end
      local _location = function()
        return string.format('%3d:%-2d ', vim.fn.line('.'), vim.fn.virtcol('.')) .. icons.collects.Pagelines
      end
      local _fg = function(name)
        return function()
          local hl = vim.api.nvim_get_hl_by_name(name, true)
          return hl and hl.foreground and { fg = string.format('#%06x', hl.foreground) }
        end
      end
      local _osv = function() return require('osv').is_running() and 'OSV Running' or '' end
      local fileformat = { 'fileformat', icons_enabled = false }
      local _diff_source = function()
        local gitsigns = vim.b.gitsigns_status_dict
        if gitsigns then
          return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
          }
        end
      end
      local _trunc = function(trunc_width, trunc_len, hide_width, no_ellipsis)
        return function(str)
          local win_width = vim.fn.winwidth(0)
          if hide_width and win_width < hide_width then
            return ''
          elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
            return str:sub(1, trunc_len) .. (no_ellipsis and '' or '...')
          end
          return str
        end
      end
      --function for optimizing the search count
      local _search_count = function()
        if vim.api.nvim_get_vvar('hlsearch') == 1 then
          local res = vim.fn.searchcount({ maxcount = 999, timeout = 500 })
          if res.total > 0 then return string.format(icons.collects.Search .. '%d/%d', res.current, res.total) end
        end
        return ''
      end
      local _macro_reg = function() return vim.fn.reg_recording() end
      local git_blame = require('gitblame')
      local opts = {
        options = {
          section_separators = '',
          component_separators = '',
          theme = 'tokyonight', -- catppuccin auto tokyonight
          globalstatus = true,
          disabled_filetypes = { statusline = { 'dashboard', 'alpha' } },
        },
        sections = {
          lualine_a = { 'mode', { _macro_reg, type = 'lua_expr', color = 'WarningMsg' } },
          lualine_b = {
            'branch',
            {
              'diff',
              source = _diff_source,
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
            { _search_count, type = 'lua_expr' },
          },
          lualine_c = {
            {
              'diagnostics',
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
            { 'filename', path = 1, symbols = { modified = '  ', readonly = '', unnamed = '' } },
            -- stylua: ignore
            {
              function() return require("nvim-navic").get_location() end,
              cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
            },
            { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
          },
          lualine_x = {
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = _fg("Statement")
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = _fg("Constant") ,
            },
            { require('lazy.status').updates, cond = require('lazy.status').has_updates, color = _fg('Special') },
            'cdate',
            'ctime',
            _lsp_active,
            -- { function() return require('lsp-status').status() end, fmt = _trunc(120, 20, 60) },
            'osv',
            'encoding',
            -- fileformat,
            {
              'fileformat',
              icons_enabled = true,
              symbols = {
                unix = 'LF',
                dos = 'CRLF',
                mac = 'CR',
              },
            },
            'filetype',
          },
          lualine_z = { _location },
        },
        extensions = { 'neo-tree', 'nvim-tree', 'lazy' },
      }
      require('lualine').setup(opts)
    end,
  },
  ['utilyre/barbecue.nvim'] = {
    -- event = { 'User NeXT' },
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      local opts = {
        -- show_dirname = false,
        -- show_basename = false,
      }
      require('barbecue').setup(opts)
    end,
  },
  ['b0o/incline.nvim'] = {
    -- enabled = false,
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      -- local colors = require('tokyonight.colors').setup()
      local opts = {
        -- highlight = {
        --   groups = {
        --     InclineNormal = { guibg = '#FC56B1', guifg = colors.black },
        --     InclineNormalNC = { guifg = '#FC56B1', guibg = colors.black },
        --   },
        -- },
        -- window = { margin = { vertical = 0, horizontal = 1 } },
        -- render = function(props)
        --   local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        --   local icon, color = require('nvim-web-devicons').get_icon_color(filename)
        --   return { { icon }, { ' ' }, { filename } }
        -- end,
      }
      require('incline').setup(opts)
    end,
  },
  ['nanozuki/tabby.nvim'] = {
    enabled = false,
    event = { 'VeryLazy' },
    config = function() require('tabby.tabline').use_preset('tab_only') end,
  },
  ['akinsho/bufferline.nvim'] = {
    -- enabled = false,
    -- event = { 'VeryLazy' },
    event = { 'User AlphaClosed', 'BufNewFile', 'BufReadPre', 'User HijackDirectories' },
    config = function()
      local opts = {
        options = {
          -- diagnostics = false,
          diagnostics = 'nvim_lsp',
          separator_style = 'slant', -- slope thick thin slant
          always_show_bufferline = true,
          diagnostics_indicator = function(_, _, diag)
            local icons = require('module.options').icons.diagnostics
            local ret = (diag.error and icons.Error .. diag.error .. ' ' or '')
              .. (diag.warning and icons.Warn .. diag.warning or '')
            return vim.trim(ret)
          end,
          offsets = {
            {
              filetype = 'NvimTree',
              text = 'File Explorer',
              highlight = 'Directory',
              separator = true,
              text_align = 'left',
            },
            {
              filetype = 'neo-tree',
              text = 'Neo Explorer',
              highlight = 'Directory',
              separator = true,
              text_align = 'left',
            },
          },
        },
      }
      require('bufferline').setup(opts)
    end,
  },
  ['romgrk/barbar.nvim'] = {},
}

run['Colorschemes'] = {
  ['folke/tokyonight.nvim'] = {
    lazy = false,
    priority = 1000,
    config = function() vim.cmd([[colorscheme tokyonight-moon]]) end,
  },
  ['catppuccin'] = {
    config = function()
      local opts = {
        flavour = 'mocha', -- mocha, macchiato, frappe, latte
        term_colors = true,
        integrations = {
          nvimtree = true,
          cmp = true,
          gitsigns = true,
          telescope = true,
          treesitter = true,
        },
        transparent_background = false,
      }
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme('catppuccin')
      local colors = require('catppuccin.palettes.mocha')
      vim.api.nvim_set_hl(0, 'Tabline', { fg = colors.green, bg = colors.mantle })
      vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#A6E3A1', bg = '#A6E3A1' })
    end,
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
      local opts = {
        input = {
          enabled = true,
          prompt_align = 'center',
          relative = 'editor',
          prefer_width = 0.6,
          win_options = { winblend = 0 },
        },
        select = { enabled = true, backend = { 'telescope' } },
      }
      require('dressing').setup(opts)
    end,
  },
  ['CosmicNvim/cosmic-ui'] = {
    dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
    config = function() require('cosmic-ui').setup() end,
  },
  ['rcarriga/nvim-notify'] = {
    -- enabled = false,
    config = function()
      local opts = {
        stages = 'static',
        timeout = 2000,
        render = 'minimal',
        max_height = function() return math.floor(vim.o.lines * 0.75) end,
        max_width = function() return math.floor(vim.o.columns * 0.75) end,
      }
      local notfiy = require('notify')
      notfiy.setup(opts)
      -- vim.notify = notfiy
      -- require('telescope').load_extension('notify')
    end,
  },
  ['folke/noice.nvim'] = {
    -- enabled = false,
    event = { 'User NeXT' },
    config = function()
      local opts = {
        cmdline = {
          enabled = false,
        },
        popupmenu = {
          enabled = false,
        },
        messages = {
          -- NOTE: If you enable messages, then the cmdline is enabled automatically.
          -- This is a current Neovim limitation.
          enabled = false,
        },
        lsp = {
          hover = {
            enabled = true,
          },
          progress = {
            enabled = false,
          },
          signature = {
            enabled = false,
          },
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
        },
        notify = {
          -- Noice can be used as `vim.notify` so you can route any notification like other messages
          -- Notification messages have their level and other properties set.
          -- event is always "notify" and kind can be any log level as a string
          -- The default routes will forward notifications to nvim-notify
          -- Benefit of using Noice for this is the routing and consistent history view
          enabled = true,
          -- view = 'mini',
          view = 'notify',
        },
        routes = {
          {
            filter = {
              event = 'msg_show',
              find = '%d+L, %d+B',
            },
            view = 'mini',
          },
        },
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = true, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
          cmdline_output_to_split = false,
        },
        commands = {
          all = {
            -- options for the message history that you get with `:Noice`
            view = 'split',
            opts = { enter = true, format = 'details' },
            filter = {},
          },
        },
        format = {
          level = {
            icons = false,
          },
        },
      }
      require('noice').setup(opts)
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
  ['kevinhwang91/nvim-bqf'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    dependencies = { 'junegunn/fzf' },
    config = function()
      local opts = {}
      require('bqf').setup(opts)
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
    -- lazy = false,
    dependencies = { 'anuvyklack/hydra.nvim' },
    -- event = 'VeryLazy',
    -- cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
    -- config = true,
    config = function()
      local opts = {
        sort_by = 'case_sensitive',
        sync_root_with_cwd = false,
        respect_buf_cwd = false,
        disable_netrw = true,
        hijack_directories = { enable = true, auto_open = true },
        update_focused_file = { enable = true, update_root = false },
        actions = { open_file = { resize_window = false } },
        view = { adaptive_size = false, preserve_window_proportions = true, width = 35 },
        git = { enable = false },
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.nvim_tree())
      require('nvim-tree').setup(opts)
    end,
  },
  ['obaland/vfiler.vim'] = {
    cmd = { 'VFiler' },
    config = function()
      local opts = {
        options = {
          auto_cd = true,
          auto_resize = true,
          keep = true,
          layout = 'left',
          name = 'explorer',
          width = 30,
          columns = 'indent,icon,name',
        },
      }
      require('vfiler/config').setup(opts)
    end,
  },
  ['nvim-neo-tree/neo-tree.nvim'] = {
    -- event = 'VeryLazy',
    cmd = { 'Neotree' },
    config = function()
      vim.g.neo_tree_remove_legacy_commands = 1
      local opts = {
        source_selector = {
          winbar = false, -- toggle to show selector on winbar
          statusline = false, -- toggle to show selector on statusline
          show_scrolled_off_parent_node = false, -- boolean
        },
        enable_git_status = false,
        enable_diagnostics = false,
        -- async_directory_scan = 'never',
        -- log_level = 'trace',
        -- log_to_file = false,
        close_if_last_window = true,
        filesystem = {
          bind_to_cwd = false,
          follow_current_file = true,
          -- hijack_netrw_behavior = "open_default", -- "open_current",  -- "disabled",
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
  ['nikvdp/neomux'] = {
    cmd = { 'Neomux' },
    -- (Optional, for speed) install neovim-remote.
  },
}

run['Window Management'] = {
  ['spolu/dwm.vim'] = {
    enabled = false,
    event = { 'VeryLazy' },
  },
  ['sindrets/winshift.nvim'] = {
    cmd = { 'WinShift' },
    config = function() require('winshift').setup() end,
  },
  ['mrjones2014/smart-splits.nvim'] = {
    config = function() require('smart-splits').setup({}) end,
  },
  ['anuvyklack/windows.nvim'] = {
    cmd = { 'WindowsMaximize', 'WindowsMaximizeVertically', 'WindowsMaximizeHorizontally', 'WindowsEqualize' },
    dependencies = {
      'anuvyklack/middleclass',
      'anuvyklack/animation.nvim',
    },
    config = function()
      vim.o.winwidth = 10
      vim.o.winminwidth = 10
      vim.o.equalalways = false
      require('windows').setup()
    end,
  },
}

run['Project'] = {
  ['ahmedkhalf/project.nvim'] = {
    -- event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    -- event = { 'VeryLazy' },
    config = function()
      require('project_nvim').setup({
        silent_chdir = true,
      })
    end,
  },
  ['pluffie/neoproj'] = {
    cmd = { 'ProjectOpen', 'ProjectNew' },
  },
  ['gnikdroy/projections.nvim'] = {
    -- event = 'VeryLazy',
    config = function()
      local opts = {
        workspaces = { -- Default workspaces to search for
          -- { "~/Documents/dev", { ".git" } },        Documents/dev is a workspace. patterns = { ".git" }
          { 'E:\\DataCenter', {} },
          { '~/Code', {} }, -- An empty pattern list indicates that all subdirectories are considered projects
          { '~/Code/me', {} }, -- An empty pattern list indicates that all subdirectories are considered projects
          -- "~/dev",                                  dev is a workspace. default patterns is used (specified below)
        },
        store_hooks = {
          pre = function()
            -- nvim-tree
            local nvim_tree_present, api = pcall(require, 'nvim-tree.api')
            if nvim_tree_present then api.tree.close() end
            -- neo-tree
            if pcall(require, 'neo-tree') then vim.cmd([[Neotree action=close]]) end
          end,
        },
      }
      require('projections').setup(opts)
      -- Bind <leader>fp to Telescope projections
      require('telescope').load_extension('projections')
      -- Autostore session on VimExit
      local Session = require('projections.session')
      vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
        callback = function() Session.store(vim.loop.cwd()) end,
      })
      -- Switch to project if vim was started in a project dir
      local switcher = require('projections.switcher')
      vim.api.nvim_create_autocmd({ 'VimEnter' }, {
        callback = function()
          if vim.fn.argc() == 0 then switcher.switch(vim.loop.cwd()) end
        end,
      })
    end,
  },
}

run['Todo'] = {
  ['folke/todo-comments.nvim'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
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
  ['rmagatti/auto-session'] = {
    config = function()
      require('auto-session').setup({
        -- log_level = "error",
        auto_session_suppress_dirs = { '~/', '/' },
      })
    end,
  },
  ['folke/persistence.nvim'] = {
    event = 'BufReadPre',
    config = function() require('persistence').setup() end,
  },
  ['vladdoster/remember.nvim'] = {
    -- enabled = false,
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function() require('remember') end,
  },
  ['ethanholz/nvim-lastplace'] = {
    config = function() require('nvim-lastplace').setup({}) end,
  },
}

run['View'] = {
  ['folke/zen-mode.nvim'] = {
    cmd = { 'ZenMode' },
    config = function()
      local opts = {
        plugins = {
          gitsigns = true,
          tmux = true,
          kitty = { enabled = false, font = '+2' },
        },
      }
      require('zen-mode').setup(opts)
    end,
  },
  ['Pocco81/true-zen.nvim'] = {
    cmd = { 'TZFocus', 'TZMinimalist', 'TZAtaraxis', 'TZNarrow' },
    config = function() require('true-zen').setup() end,
  },
}

run['Git'] = {
  ['lewis6991/gitsigns.nvim'] = {
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local opts = {
        signs = {
          add = { text = '▎' },
          change = { text = '▎' },
          delete = { text = '' },
          topdelete = { text = '' },
          changedelete = { text = '▎' },
          untracked = { text = '▎' },
        },
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.gitsigns())
      require('gitsigns').setup(opts)
    end,
  },
  ['sindrets/diffview.nvim'] = {
    cmd = { 'DiffviewOpen' },
  },
  ['f-person/git-blame.nvim'] = {
    -- enabled = false,
    event = { 'BufReadPost', 'BufNewFile' },
    config = function() vim.g.gitblame_display_virtual_text = 0 end,
  },
  ['TimUntersberger/neogit'] = {
    cmd = { 'Neogit' },
    config = function()
      local neogit = require('neogit')
      neogit.setup({})
    end,
  },
}

run['Fuzzy Finder'] = {
  ['nvim-telescope/telescope.nvim'] = {
    cmd = { 'Telescope' },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local previewers = require('telescope.previewers')
      local _new_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        filepath = vim.fn.expand(filepath)
        vim.loop.fs_stat(filepath, function(_, stat)
          if not stat then return end
          if stat.size > 100000 then
            return
          else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
          end
        end)
      end
      local opts = {
        defaults = {
          prompt_prefix = ' ',
          selection_caret = ' ',
          buffer_previewer_maker = _new_maker,
          file_ignore_patterns = { 'node_modules', '%_files/*.html', '%_cache', '.git/', 'site_libs', '.venv' },
          layout_strategy = 'flex',
          sorting_strategy = 'ascending',
          layout_config = {
            prompt_position = 'top',
          },
        },
        pickers = {
          buffers = {
            ignore_current_buffer = false,
            sort_lastused = true,
            sort_mru = true,
          },
          find_files = {
            hidden = true,
            find_command = {
              'rg',
              '--no-ignore',
              '--files',
              '--hidden',
              '--glob',
              '!.git/*',
              '--glob',
              '!**/.Rproj.user/*',
              '-L',
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.telescope())
      telescope.setup(opts)
      telescope.load_extension('undo')
      telescope.load_extension('fzf')
      telescope.load_extension('live_grep_args')
      telescope.load_extension('projects')
      telescope.load_extension('repo')
      telescope.load_extension('refactoring')
      telescope.load_extension('notify')
      telescope.load_extension('ui-select')
      telescope.load_extension('file_browser')
      telescope.load_extension('dap')
      telescope.load_extension('projections')
      vim.cmd([[autocmd User TelescopePreviewerLoaded setlocal wrap]])
    end,
  },
  ['nvim-telescope/telescope-fzf-native.nvim'] = {
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
  },
  ['romgrk/fzy-lua-native'] = {
    build = 'make',
  },
  ['junegunn/fzf'] = {
    -- build = function() vim.fn['fzf#install']() end,
  },
  ['junegunn/fzf.vim'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
  },
}

run['Bindings Management'] = {
  ['folke/which-key.nvim'] = {
    keys = { { ',' }, { 'g' } },
    -- event = { 'VeryLazy' },
    -- lazy = false,
    -- Bug: handle marks.nvim m
    config = function()
      local wk = require('which-key')
      wk.setup()
      bindings.wk(wk)
    end,
  },
  --  Key mapping hints in a floating window
  ['linty-org/key-menu.nvim'] = {
    -- enabled = false,
    -- event = { 'VeryLazy' },
    -- keys = { { 'm' } },
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      -- pop up a hint window
      require('key-menu').set(
        'n', -- in Normal mode
        'm'
      )
      -- require('key-menu').set(
      --   'n', -- in Normal mode
      --   'd'
      -- )
    end,
  },
  ['mrjones2014/legendary.nvim'] = {
    config = function()
      local opts = { which_key = { auto_register = true } }
      require('legendary').setup(opts)
    end,
  },
  ['b0o/mapx.nvim'] = {
    --
  },
  ['anuvyklack/keymap-layer.nvim'] = {},
  ['anuvyklack/keymap-amend.nvim'] = {},
}

run['Buffer'] = {
  ['kazhala/close-buffers.nvim'] = {
    cmd = { 'BWipeout', 'BDelete' },
  },
  ['glepnir/flybuf.nvim'] = {
    cmd = { 'FlyBuf' },
    config = true,
  },
  ['moll/vim-bbye'] = {
    event = { 'BufAdd' },
  },
  ['echasnovski/mini.bufremove'] = {
    keys = { { '<leader>bd' }, { '<leader>bD' } },
    -- config = true, -- Bug: no mini module
  },
  ['jlanzarotta/bufexplorer'] = {
    cmd = { 'BufExplorer', 'ToggleBufExplorer', 'BufExplorerHorizontalSplit', 'BufExplorerVerticalSplit' },
    init = function() vim.g.bufExplorerDisableDefaultKeyMapping = true end,
    config = function() end,
  },
  ['kwkarlwang/bufresize.nvim'] = {
    config = function() require('bufresize').setup() end,
  },
}

run['Syntax'] = {
  ['nvim-treesitter/nvim-treesitter'] = {
    cmd = { 'TSInstall', 'TSBufEnable', 'TSBufDisable', 'TSModuleInfo' },
    build = ':TSUpdate',
    keys = {
      { '<c-space>', desc = 'Increment selection' },
      { '<bs>', desc = 'Decrement selection', mode = 'x' },
    },
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'chrisgrieser/nvim-various-textobjs',
      'RRethy/nvim-treesitter-textsubjects',
      'nvim-treesitter/playground',
    },
    config = function()
      local opts = {
        matchup = { enable = true },
        ensure_installed = {
          'bash',
          'c',
          'cpp',
          'cmake',
          'html',
          'javascript',
          'json',
          'lua',
          'luadoc',
          'markdown',
          'markdown_inline',
          'python',
          'query', -- Neovim Treesitter Playground
          'regex',
          'typescript',
          'vim',
          'vimdoc',
          'yaml',
        },
        highlight = { enable = true },
        -- indent = { enable = true }, -- ignore cinoptions, set indentexpr=nvim_treesitter#indent()
        indent = {
          enable = true,
          disable = { 'cpp' },
        },
        context_commentstring = { enable = true, enable_autocmd = false },
        incremental_selection = {
          enable = true,
        },
        playground = {
          enable = true,
        },
        endwise = {
          enable = true,
        },
        textobjects = {
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>A'] = '@parameter.inner',
            },
          },
        },
        textsubjects = {
          enable = true,
          prev_selection = ' ', -- (Optional) keymap to select the previous selection
          keymaps = {
            ['<cr>'] = 'textsubjects-smart',
            [','] = 'textsubjects-container-outer',
            ['i.'] = 'textsubjects-container-inner',
          },
        },
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.ts())
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
  ['nvim-treesitter/nvim-treesitter-textobjects'] = {
    --
  },
  ['chrisgrieser/nvim-various-textobjs'] = {
    config = function()
      local opts = {
        -- lines to seek forwards for "small" textobjs (most characterwise)
        -- set to 0 to only look in the current line
        lookForwardSmall = 5,
        -- lines to seek forwards for "big" textobjs
        -- (linewise textobjs & url textobj)
        lookForwardBig = 15,
        -- use suggested keymaps (see README)
        useDefaultKeymaps = false,
      }
      require('various-textobjs').setup(opts)
      vim.keymap.set({ 'o', 'x' }, '?', '<cmd>lua require("various-textobjs").diagnostic()<CR>')
    end,
  },
  ['RRethy/nvim-treesitter-textsubjects'] = {
    --
  },
  ['RRethy/nvim-treesitter-endwise'] = {
    --
  },
  ['nvim-treesitter/playground'] = {
    --
  },
  -- Create your own "minimap" from Treesitter Queries or Vim Regex.
  ['ziontee113/neo-minimap'] = {
    -- enabled = false,
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      local nm = require('neo-minimap')
      nm.setup_defaults({
        height_toggle = { 20, 25 },
        width = 80,
        height = 18,
        hl_group = 'DiagnosticWarn',
      })
      bindings.neo_minimap(nm)
    end,
  },
}

run['Editing Motion Support'] = {
  ['andymass/vim-matchup'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function() vim.g.matchup_matchparen_offscreen = { method = 'status_manual' } end,
  },
  ['echasnovski/mini.pairs'] = {
    -- event = "VeryLazy",
    config = function(_, opts) require('mini.pairs').setup(opts) end,
  },
  ['fedepujol/move.nvim'] = {
    cmd = { 'MoveLine', 'MoveBlock', 'MoveHChar', 'MoveHBlock' },
  },
  ['m4xshen/autoclose.nvim'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function() require('autoclose').setup() end,
  },
  ['nacro90/numb.nvim'] = {
    keys = { { ':' } },
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    -- event = 'VeryLazy',
    config = function() require('numb').setup() end,
  },
  ['folke/twilight.nvim'] = {
    cmd = { 'Twilight', 'TwilightEnable' },
    config = function() require('twilight').setup() end,
  },
  ['ggandor/flit.nvim'] = {
    keys = function()
      local ret = {}
      for _, key in ipairs({ 'f', 'F', 't', 'T' }) do
        ret[#ret + 1] = { key, mode = { 'n', 'x', 'o' }, desc = key }
      end
      return ret
    end,
    config = function()
      local opts = { labeled_modes = 'nx' }
      require('flit').setup(opts)
    end,
  },
  ['ggandor/leap.nvim'] = {
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, desc = 'Leap forward to' },
      { 'S', mode = { 'n', 'x', 'o' }, desc = 'Leap backward to' },
      { 'gs', mode = { 'n', 'x', 'o' }, desc = 'Leap from windows' },
    },
    config = function()
      local leap = require('leap')
      leap.add_default_mappings(true)
      vim.keymap.del({ 'x', 'o' }, 'x')
      vim.keymap.del({ 'x', 'o' }, 'X')
    end,
  },
  ['echasnovski/mini.surround'] = {
    keys = function(_, keys)
      local defined_keys = bindings.surround().mappings
      local descs = {
        { desc = 'Add surrounding', mode = { 'n', 'v' } },
        { desc = 'Delete surrounding' },
        { desc = 'Find right surrounding' },
        { desc = 'Find left surrounding' },
        { desc = 'Highlight surrounding' },
        { desc = 'Replace surrounding' },
        { desc = 'Update `MiniSurround.config.n_lines`' },
      }
      local mappings = {}
      for _, k in pairs(defined_keys) do
        mappings[#mappings + 1] = vim.tbl_deep_extend('error', { k }, descs[#mappings + 1])
      end
      return mappings
    end,
    config = function()
      local opts = {}
      opts = vim.tbl_deep_extend('error', opts, bindings.surround())
      -- use gz mappings instead of s to prevent conflict with leap
      require('mini.surround').setup(opts)
    end,
  },
  ['Wansmer/treesj'] = {
    cmd = { 'TSJToggle' },
    config = function()
      local opts = { use_default_keymaps = false, max_join_length = 150 }
      require('treesj').setup(opts)
    end,
  },
  ['haya14busa/vim-asterisk'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
  },
  ['mg979/vim-visual-multi'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
  },
  ['anuvyklack/vim-smartword'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
  },
}

run['Comment'] = {
  ['numToStr/Comment.nvim'] = {
    config = function()
      local opts = {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
        mappings = {
          ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
          basic = false,
          ---Extra mapping; `gco`, `gcO`, `gcA`
          extra = false,
        },
      }
      require('Comment').setup(opts)
    end,
  },
  ['JoosepAlviste/nvim-ts-context-commentstring'] = {},
  ['echasnovski/mini.comment'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      local opts = {
        hooks = {
          pre = function() require('ts_context_commentstring.internal').update_commentstring() end,
        },
      }
      require('mini.comment').setup(opts)
    end,
  },
  ['charkuils/nvim-hemingway'] = {
    --
  },
}

run['Yank'] = {
  ['gbprod/yanky.nvim'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      local opts = {
        highlight = {
          timer = 150,
        },
        ring = {
          -- storage = jit.os:find("Windows") and "shada" or "sqlite",
          storage = 'sqlite',
        },
      }
      require('yanky').setup(opts)
    end,
  },
}

run['Search'] = {
  ['kevinhwang91/nvim-hlslens'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      require('hlslens').setup({
        build_position_cb = function(plist, _, _, _) require('scrollbar.handlers.search').handler.show(plist.start_pos) end,
      })
    end,
  },
  ['windwp/nvim-spectre'] = {
    keys = {
      { '<leader>sr' },
    },
    config = function() require('spectre').setup() end,
  },
  ['cshuaimin/ssr.nvim'] = {
    keys = {
      { '<leader>sR' },
    },
    config = function() require('ssr').setup({}) end,
  },
}

run['Undo'] = {
  ['mbbill/undotree'] = {
    cmd = { 'UndotreeToggle' },
  },
}

run['Marks'] = {
  ['chentoast/marks.nvim'] = {
    -- lazy = false,
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    init = function() bindings.marks() end, -- MUST Register key in init
    config = function()
      local opts = {
        -- whether to map keybinds or not. default true
        default_mappings = false,
        -- which builtin marks to show. default {}
        builtin_marks = { '.', '<', '>', '^' },
        -- whether movements cycle back to the beginning/end of buffer. default true
        cyclic = true,
        -- whether the shada file is updated after modifying uppercase marks. default false
        force_write_shada = false,
        -- how often (in ms) to redraw signs/recompute mark positions.
        -- higher values will have better performance but may cause visual lag,
        -- while lower values may cause performance penalties. default 150.
        refresh_interval = 250,
        -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
        -- marks, and bookmarks.
        -- can be either a table with all/none of the keys, or a single number, in which case
        -- the priority applies to all marks.
        -- default 10.
        sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
        -- disables mark tracking for specific filetypes. default {}
        excluded_filetypes = {},
        -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
        -- sign/virttext. Bookmarks can be used to group together positions and quickly move
        -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
        -- default virt_text is "".
        bookmark_0 = {
          sign = '⚑',
          virt_text = 'hello world',
          -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
          -- defaults to false.
          annotate = false,
        },
        mappings = {},
      }
      require('marks').setup(opts)
    end,
  },
}

run['Folding'] = {
  ['kevinhwang91/nvim-ufo'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    dependencies = { 'kevinhwang91/promise-async' },
    config = function()
      -- vim.o.foldcolumn = '1'
      local _handler = function(virtText, lnum, endLnum, width, truncate)
        local new_virt_text = {}
        local suffix = ('  %d '):format(endLnum - lnum)
        local suf_width = vim.fn.strdisplaywidth(suffix)
        local target_width = width - suf_width
        local cur_width = 0
        for _, chunk in ipairs(virtText) do
          local chunk_text = chunk[1]
          local chunk_width = vim.fn.strdisplaywidth(chunk_text)
          if target_width > cur_width + chunk_width then
            table.insert(new_virt_text, chunk)
          else
            chunk_text = truncate(chunk_text, target_width - cur_width)
            local hl_group = chunk[2]
            table.insert(new_virt_text, { chunk_text, hl_group })
            chunk_width = vim.fn.strdisplaywidth(chunk_text)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if cur_width + chunk_width < target_width then
              suffix = suffix .. (' '):rep(target_width - cur_width - chunk_width)
            end
            break
          end
          cur_width = cur_width + chunk_width
        end
        table.insert(new_virt_text, { suffix, 'MoreMsg' })
        return new_virt_text
      end
      local opts = {
        fold_virt_text_handler = _handler,
        open_fold_hl_timeout = 100,
        -- provider_selector = function(bufnr, filetype, buftype)
        --   return {'treesitter', 'indent'}
        -- end,
        preview = {
          win_config = {
            border = 'rounded',
            winblend = 2,
            winhighlight = 'Normal:Normal',
            maxheight = 20,
          },
        },
      }
      require('ufo').setup(opts)
    end,
  },
  ['anuvyklack/pretty-fold.nvim'] = {
    config = function()
      local opts = {
        sections = {
          left = {
            'content',
          },
          right = {
            ' ',
            'number_of_folded_lines',
            ': ',
            'percentage',
            ' ',
            function(config) return config.fill_char:rep(3) end,
          },
        },
        fill_char = '•',
        remove_fold_markers = true,
        -- Keep the indentation of the content of the fold string.
        keep_indentation = true,
        -- Possible values:
        -- "delete" : Delete all comment signs from the fold string.
        -- "spaces" : Replace all comment signs with equal number of spaces.
        -- false    : Do nothing with comment signs.
        process_comment_signs = 'spaces',
        -- Comment signs additional to the value of `&commentstring` option.
        comment_signs = {},
        -- List of patterns that will be removed from content foldtext section.
        stop_words = {
          '@brief%s*', -- (for C++) Remove '@brief' and all spaces after.
        },
        add_close_pattern = true, -- true, 'last_line' or false
        matchup_patterns = {
          { '{', '}' },
          { '%(', ')' }, -- % to escape lua pattern char
          { '%[', ']' }, -- % to escape lua pattern char
        },
        ft_ignore = { 'neorg' },
      }
      require('pretty-fold').setup()
    end,
  },
  ['anuvyklack/fold-preview.nvim'] = {
    config = function()
      require('fold-preview').setup({
        -- Your configuration goes here.
      })
    end,
  },
}

run['Editing Visual Formatting'] = {
  ['mhartington/formatter.nvim'] = {
    cmd = { 'FormatWriteLock' },
    config = function()
      -- local unix_ff = function() vim.cmd([[set ff=unix]]) end
      require('formatter').setup({
        logging = false,
        filetype = {
          lua = { require('formatter.filetypes.lua').stylua },
          ['*'] = {
            require('formatter.filetypes.any').remove_trailing_whitespace,
            -- unix_ff,
          },
        },
      })
    end,
  },
  ['lukas-reineke/indent-blankline.nvim'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      local opts = {
        char = '│',
        filetype_exclude = { 'help', 'alpha', 'dashboard', 'neo-tree', 'NvimTree', 'Trouble', 'lazy' },
        show_trailing_blankline_indent = false,
        -- show_current_context = true,
      }
      require('indent_blankline').setup(opts)
    end,
  },
  ['HiPhish/nvim-ts-rainbow2'] = {
    -- enabled = false,
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      local opts = {
        rainbow = {
          enable = { 'c', 'cpp' },
          query = 'rainbow-parens',
          strategy = require('ts-rainbow').strategy['local'],
        },
      }
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
  ['echasnovski/mini.indentscope'] = {
    -- enabled = false,
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'help', 'alpha', 'dashboard', 'neo-tree', 'NvimTree', 'Trouble', 'lazy', 'mason' },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
      local opts = {
        -- symbol = "▏",
        symbol = '│',
        options = { try_as_border = true },
        draw = {
          -- Animation rule for scope's first drawing. A function which, given
          -- next and total step numbers, returns wait time (in ms). See
          -- |MiniIndentscope.gen_animation| for builtin options. To disable
          -- animation, use `require('mini.indentscope').gen_animation.none()`.
          animation = require('mini.indentscope').gen_animation.none(),
        },
      }
      local indentscope = require('mini.indentscope')
      indentscope.setup(opts)
    end,
  },
  ['NvChad/nvim-colorizer.lua'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      local opts = {
        filetypes = { 'css', 'html', 'lua' },
      }
      require('colorizer').setup(opts)
    end,
  },
  -- automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.
  ['RRethy/vim-illuminate'] = {
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      local opts = { delay = 200 }
      require('illuminate').configure(opts)
    end,
  },
}

run['Editing Action'] = {
  ['AntonVanAssche/date-time-inserter.nvim'] = {
    enabled = false,
  },
  ['ziontee113/color-picker.nvim'] = {
    cmd = { 'PickColor', 'PickColorInsert' },
    config = function() require('color-picker').setup() end,
  },
  ['nvim-colortils/colortils.nvim'] = {
    cmd = 'Colortils',
    config = function() require('colortils').setup() end,
  },
  ['uga-rosa/ccc.nvim'] = {
    cmd = { 'CccPick', 'CccConvert', 'CccHighlighterToggle' },
    config = function()
      local opts = {
        highlighter = {
          auto_enable = false,
          lsp = false,
        },
      }
      require('color-picker').setup(opts)
    end,
  },
  ['ThePrimeagen/refactoring.nvim'] = {
    keys = {},
    config = function() require('refactoring').setup() end,
  },
  ['charkuils/nvim-soil'] = {
    -- Java and sxiv are required to be installed in order to use this plugin.
    -- plantuml is optional to be installed or used in jar format.
    config = function()
      local opts = {
        image = {
          darkmode = false, -- Enable or disable darkmode
          format = 'png', -- Choose between png or svg
        },
      }
      require('soil').setup(opts)
    end,
  },
  ['chrishrb/gx.nvim'] = {
    -- event = { 'BufEnter' },
    keys = { { 'gx' } },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local opts = {
        -- open_browser_app = 'xdg-open', -- specify your browser app; default for macos is "open" and for linux "xdg-open"
        -- open_browser_args = { },
        handlers = {
          plugin = true, -- open plugin links in lua (e.g. packer, lazy, ..)
          github = true, -- open github issues
          package_json = true, -- open dependencies from package.json
        },
      }
      require('gx').setup(opts)
    end,
  },
  ['axieax/urlview.nvim'] = {
    cmd = { 'UrlView' },
    config = function() require('urlview').setup() end,
  },
  ['ellisonleao/carbon-now.nvim'] = {
    cmd = { 'CarbonNow' },
    config = function() require('carbon-now').setup() end,
  },
  ['jbyuki/venn.nvim'] = {
    -- cmd = { 'VBox' },
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function() end,
  },
}

run['Completion'] = {
  ['hrsh7th/nvim-cmp'] = {
    -- enabled = false,
    event = { 'InsertEnter' },
    -- event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      -- 'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-emoji',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local fmt_presets = {
        native = {
          fields = { 'abbr', 'kind', 'menu' },
          format = function(entry, vim_item)
            local ellipsis_char = '…'
            local maxwidth = 50
            local get_ws = function(max, len) return (' '):rep(max - len) end
            local icons = require('module.options').icons.kinds
            vim_item.kind = string.format('%s', icons[vim_item.kind])
            vim_item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip = '[Snippet]',
              buffer = '[Buffer]',
              path = '[Path]',
            })[entry.source.name]
            local content = vim_item.abbr
            if type(content) == 'string' then
              if #content > maxwidth then
                vim_item.abbr = vim.fn.strcharpart(content, 0, maxwidth) .. ellipsis_char
              else
                vim_item.abbr = content .. get_ws(maxwidth, #content)
              end
            end
            return vim_item
          end,
        },
        lazy = {
          format = function(_, item)
            local icons = require('module.options').icons.kinds
            if icons[item.kind] then item.kind = icons[item.kind] .. item.kind end
            return item
          end,
        },
        wbthomason = {
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            local formated = require('lspkind').cmp_format({
              mode = 'symbol_text',
              maxwidth = 50,
              symbol_map = require('module.options').icons.kinds,
            })(entry, vim_item)
            local strings = vim.split(formated.kind, '%s', { trimempty = true })
            formated.kind = ' ' .. strings[1] .. ' '
            if vim.tbl_count(strings) == 2 then formated.menu = '    (' .. strings[2] .. ')' end
            return formated
          end,
        },
        vscode = {
          format = require('lspkind').cmp_format({
            symbol_map = require('module.options').icons.kinds,
            mode = 'symbol_text',
            maxwidth = 50,
            before = function(entry, vim_item) return vim_item end,
            menu = {
              nvim_lsp = '[LSP]',
              luasnip = '[Snippet]',
              buffer = '[Buffer]',
              path = '[Path]',
            },
          }),
        },
      }
      local cmp = require('cmp')
      local opts = {
        completion = {
          completeopt = 'menuone,noselect',
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
          { name = 'emoji' },
        },
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        formatting = fmt_presets.vscode,
        experimental = {
          ghost_text = {
            hl_group = 'LspCodeLens',
          },
        },
      }
      opts = vim.tbl_deep_extend('error', opts, bindings.cmp())
      cmp.setup(opts)
      -- cmp.setup.cmdline(':', {
      --   completion = {
      --     completeopt = 'menuone,noselect,noinsert',
      --   },
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = cmp.config.sources({
      --     { name = 'path' },
      --     { name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } },
      --   }),
      -- })
      -- cmp.setup.cmdline('/', {
      --   completion = {
      --     completeopt = 'menuone,noselect,noinsert',
      --   },
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = { { name = 'buffer' } },
      -- })
      -- C++ fix indent
      -- cmp.event:on('confirm_done', function(evt)
      --   local cxxindent = { 'public:', 'private:', 'protected:' }
      --   if vim.tbl_contains(cxxindent, evt.entry:get_word()) then
      --     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<cr>', true, true, true), 'i', true)
      --     -- local keymap = require('cmp.utils.keymap')
      --     -- vim.api.nvim_feedkeys(keymap.t('<cr>'), 'i', true)
      --     -- vim.api.nvim_feedkeys('<cr>', 'i', true)
      --   end
      -- end)
    end,
  },
  ['gelguy/wilder.nvim'] = {
    -- enabled = false,
    event = { 'CmdlineEnter' },
    config = function()
      local wilder = require('wilder')
      wilder.setup({ modes = { ':', '/', '?' } })
      wilder.set_option('pipeline', {
        wilder.branch(wilder.cmdline_pipeline(), wilder.search_pipeline()),
      })
      wilder.set_option(
        'renderer',
        wilder.wildmenu_renderer({
          highlighter = wilder.basic_highlighter(),
        })
      )
    end,
  },
}

run['Snippet'] = {
  ['L3MON4D3/LuaSnip'] = {
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
    config = function()
      require('luasnip').config.set_config({
        history = true,
        delete_check_events = 'TextChanged',
        updateevents = 'TextChanged, TextChangedI',
      })
    end,
  },
  ['rafamadriz/friendly-snippets'] = {
    config = function()
      -- Sync load luasnip cost ~600ms
      vim.loop
        .new_timer()
        :start(3000, 0, vim.schedule_wrap(function() require('luasnip.loaders.from_vscode').lazy_load() end))
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
        quickfix = {
          enable = false, -- whether to populate the quickfix list in case of errors
          auto_open = false, -- whether to open the quickfix list in case of errors
        },
      })
    end,
  },
  ['Xertes0/cppdoc.nvim'] = {
    config = function() require('cppdoc').setup() end,
  },
  ['Civitasv/cmake-tools.nvim'] = {
    ft = { 'c', 'cpp' },
    config = function()
      local opts = {
        cmake_command = 'cmake',
        cmake_build_directory = '',
        cmake_build_directory_prefix = 'cmake_build_', -- when cmake_build_directory is "", this option will be activated
        cmake_generate_options = { '-D', 'CMAKE_EXPORT_COMPILE_COMMANDS=1' },
        cmake_soft_link_compile_commands = true, -- if softlink compile commands json file
        cmake_build_options = {},
        cmake_console_size = 10, -- cmake output window height
        cmake_console_position = 'belowright', -- "belowright", "aboveleft", ...
        cmake_show_console = 'always', -- "always", "only_on_error"
        -- cmake_dap_configuration = { name = "cpp", type = "lldb", request = "launch" }, -- dap configuration, optional
        cmake_variants_message = {
          short = { show = true },
          long = { show = true, max_length = 40 },
        },
      }
      require('cmake-tools').setup(opts)
    end,
  },
}

run['Diagnostics'] = {
  ['folke/trouble.nvim'] = {
    cmd = { 'TroubleToggle' },
    config = function()
      local opts = { use_diagnostic_signs = true, icons = true }
      require('trouble').setup(opts)
    end,
  },
}

run['LSP VIF'] = {
  ['neovim/nvim-lspconfig'] = {
    -- ft = { 'c', 'cpp', 'lua' },
    event = { 'BufReadPre' },
    config = require('module.lsp').lsp,
  },
  ['stevearc/aerial.nvim'] = {
    cmd = { 'AerialNext', 'AerialPrev', 'AerialToggle' },
    config = function()
      local opts = { backends = { 'treesitter', 'lsp' }, layout = { width = 35 } }
      opts = vim.tbl_deep_extend('error', opts, bindings.aerial())
      require('aerial').setup(opts)
    end,
  },
  ['DNLHC/glance.nvim'] = {
    cmd = { 'Glance' },
    config = function()
      local opts = {
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
      }
      require('glance').setup(opts)
    end,
  },
  ['jackguo380/vim-lsp-cxx-highlight'] = {
    event = 'User ccls',
  },
  ['m-pilia/vim-ccls'] = {
    event = 'User ccls',
  },
  ['j-hui/fidget.nvim'] = {
    -- enabled = false,
    event = { 'LspAttach' },
    config = function()
      vim.cmd([[highlight FidgetTitle ctermfg=110 guifg=#0887c7]])
      vim.cmd([[highlight FidgetTask ctermfg=110 guifg=#0887c7]])
      local icons = require('module.options').icons
      local opts = { text = { done = icons.collects.Tomatoes }, window = { blend = 0 } }
      require('fidget').setup(opts)
    end,
  },
  ['ray-x/lsp_signature.nvim'] = {
    -- enabled = false,
    -- event = { 'LspAttach' },
    -- event = { 'VeryLazy' },
    event = { 'BufReadPost', 'BufNewFile', 'BufNew' },
    config = function()
      local icons = require('module.options').icons
      local opts = {
        floating_window = true,
        hint_prefix = icons.collects.Tomatoes,
      }
      require('lsp_signature').setup(opts)
    end,
  },
  ['nvimdev/lspsaga.nvim'] = {
    -- enabled = false,
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
  ['smjonas/inc-rename.nvim'] = {
    cmd = { 'IncRename' },
    config = function() require('inc_rename').setup() end,
  },
  ['VidocqH/lsp-lens.nvim'] = {
    enabled = false,
    event = { 'LspAttach' },
    config = function() require('lsp-lens').setup() end,
  },
  ['simrat39/symbols-outline.nvim'] = {
    event = { 'LspAttach' },
    config = function()
      local opts = {
        -- position = 'left',
        -- width = 25,
      }
      require('symbols-outline').setup(opts)
    end,
  },
  ['rmagatti/goto-preview'] = {
    enabled = false,
    event = { 'LspAttach' },
    config = function()
      local opts = {
        width = 120, -- Width of the floating window
      }
      require('goto-preview').setup({ opts })
    end,
  },
  ['ray-x/navigator.lua'] = {
    enabled = false,
    event = { 'LspAttach' },
    dependencies = {
      'ray-x/guihua.lua',
    },
    config = function() require('navigator').setup() end,
  },
  ['lewis6991/hover.nvim'] = {},
  ['Fildo7525/pretty_hover'] = {
    config = function() require('pretty_hover').setup() end,
  },
  ['lsp_lines.nvim'] = {
    -- enabled = false,
    event = { 'LspAttach' },
    config = function() require('lsp_lines').setup() end,
  },
  ['nvim-lua/lsp-status.nvim'] = {
    enabled = false,
    event = { 'LspAttach' },
    config = function()
      local icons = require('module.options').icons
      require('lsp-status').status()
      require('lsp-status').register_progress()
      local opts = {
        indicator_errors = '✗',
        indicator_warnings = '⚠',
        indicator_info = '',
        indicator_hint = '',
        indicator_ok = '✔',
        current_function = true,
        diagnostics = false,
        select_symbol = nil,
        update_interval = 100,
        status_symbol = icons.collects.Tomatoes,
      }
      require('lsp-status').config(opts)
    end,
  },
  ['kosayoda/nvim-lightbulb'] = {
    enabled = false,
    event = { 'LspAttach' },
    config = function()
      local icons = require('module.options').icons
      local opts = {
        -- LSP client names to ignore
        -- Example: {"sumneko_lua", "null-ls"}
        ignore = {},
        sign = {
          enabled = true,
          -- Priority of the gutter sign
          priority = 10,
          text = icons.diagnostics.Hint, -- '💡',
        },
        float = {
          enabled = false,
          -- Text to show in the popup float
          text = icons.diagnostics.Hint, -- '💡',
          -- Available keys for window options:
          -- - height     of floating window
          -- - width      of floating window
          -- - wrap_at    character to wrap at for computing height
          -- - max_width  maximal width of floating window
          -- - max_height maximal height of floating window
          -- - pad_left   number of columns to pad contents at left
          -- - pad_right  number of columns to pad contents at right
          -- - pad_top    number of lines to pad contents at top
          -- - pad_bottom number of lines to pad contents at bottom
          -- - offset_x   x-axis offset of the floating window
          -- - offset_y   y-axis offset of the floating window
          -- - anchor     corner of float to place at the cursor (NW, NE, SW, SE)
          -- - winblend   transparency of the window (0-100)
          win_opts = {},
        },
        virtual_text = {
          enabled = false,
          -- Text to show at virtual text
          text = icons.diagnostics.Hint, -- '💡',
          -- highlight mode to use for virtual text (replace, combine, blend), see :help nvim_buf_set_extmark() for reference
          hl_mode = 'replace',
        },
        status_text = {
          enabled = false,
          -- Text to provide when code actions are available
          text = icons.diagnostics.Hint, -- '💡',
          -- Text to provide when no actions are available
          text_unavailable = '',
        },
        autocmd = {
          enabled = true,
          -- see :help autocmd-pattern
          pattern = { '*' },
          -- see :help autocmd-events
          events = { 'CursorHold', 'CursorHoldI' },
        },
      }
      -- Showing defaults
      require('nvim-lightbulb').setup(opts)
    end,
  },
  ['SmiteshP/nvim-navic'] = {
    config = function()
      vim.g.navic_silence = true
      require('base').on_attach(function(client, buffer)
        if client.server_capabilities.documentSymbolProvider then require('nvim-navic').attach(client, buffer) end
      end)
      local opts = {
        separator = ' ',
        highlight = true,
        depth_limit = 5,
        icons = require('module.options').icons.kinds,
      }
      require('nvim-navic').setup(opts)
    end,
  },
}

run['DAP VIF'] = {
  ['mfussenegger/nvim-dap'] = {
    ft = { 'c', 'cpp', 'lua' },
    config = require('module.lsp').dap,
    dependencies = {
      'jbyuki/one-small-step-for-vimkind',
    },
  },
}

run['Performance'] = {
  ['dstein64/vim-startuptime'] = {
    cmd = 'StartupTime',
    config = function() vim.g.startuptime_tries = 10 end,
  },
}

run['Job'] = {
  ['charkuils/nvim-spinetta'] = {
    --
  },
}

run['Network'] = {
  ['charkuils/nvim-ship'] = {
    cmd = { 'Ship' },
    dependencies = { 'charkuils/nvim-spinetta' },
    config = function()
      local opts = {
        request = {
          timeout = 30,
          autosave = true,
        },
        response = {
          show_headers = 'all',
          horizontal = true,
          size = 20,
          redraw = true,
        },
        output = {
          save = false,
          override = true,
          folder = 'output',
        },
      }
      require('ship').setup(opts)
    end,
  },
}

run['Dev'] = {
  ['lualine-osv'] = {
    -- name = 'lualine-osv',
    -- lazy = false,
  },
}

local cached = {}
M.spec = function(url, named)
  if vim.tbl_isempty(cached) then
    for _, v in pairs(run) do
      cached = vim.tbl_deep_extend('error', cached, v)
    end
  end
  local key = url
  local pack = url
  if named then
    key = url['name']
  else
    pack = { url }
  end
  return vim.tbl_deep_extend('error', pack, cached[key] or {})
end
return M
