local base = require('base')

local M = {}

M.map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  if type(opts) == 'string' then opts = { desc = opts } end
  if opts.silent == nil then opts.silent = true end
  -- By default, all mappings are nonrecursive by default
  vim.keymap.set(mode, lhs, rhs, opts)
end

M.command = function(name, func, opts)
  opts = opts or {}
  if type(opts) == 'string' then opts = { desc = opts } end
  vim.api.nvim_create_user_command(name, func, opts)
end

M.cmd = function(command) return table.concat({ '<cmd>', command, '<cr>' }) end

M.setup_leader = function()
  vim.g.mapleader = ','
  vim.g.maplocalleader = ','
end

M.semicolon_to_colon = function()
  -- M.map('n', ';', ':') -- BUG: don't show ':' sometimes
  vim.cmd([[
    nnoremap ; :
    nnoremap : ;
    vnoremap ; :
    vnoremap : ;
  ]])
end

local _dap_continue_cpp = function(dap)
  if dap.session() then
    dap.continue()
  else
    -- save dap-session to sql
    -- load dap-session
    -- telescope select (default selected last)
    -- New
    -- ui.input new path
    -- Enter dap mode
    local prompt = 'Path to executable '
    local default = vim.fn.getcwd() .. '/'
    if vim.g.lastdebugfile == nil then
      vim.g.lastdebugfile = default
    else
      default = vim.g.lastdebugfile
    end
    local input_opts = { prompt = prompt, default = default, 'file', completion = 'file' }
    vim.ui.input(input_opts, function(input)
      if not input then return end
      vim.g.lastdebugfile = input
      local cpp = { {
        program = function() return input end,
      } }
      dap.configurations.cpp = vim.tbl_deep_extend('force', cpp, dap.configurations.cpp)
      dap.configurations.c = dap.configurations.cpp
      dap.continue()
    end)
  end
end

local _dap_continue = function()
  local dap = require('dap')
  if vim.bo.filetype == 'c' or vim.bo.filetype == 'cpp' then
    _dap_continue_cpp(dap)
  else
    dap.continue()
  end
end

M.lsp = function(client, buffer)
  local _hover = function()
    local winid = require('ufo').peekFoldedLinesUnderCursor()
    if not winid then vim.lsp.buf.hover() end
  end
  local _opts = function(desc) return { buffer = buffer, desc = desc } end
  M.map('n', 'gl', vim.diagnostic.open_float, _opts('Line Diagnostics'))
  M.map('n', 'gL', '<cmd>Lspsaga show_line_diagnostics<cr>', _opts('Line Diagnostics'))
  M.map('n', 'K', _hover, _opts('Hover'))
  M.map('n', 'gh', _hover, _opts('Hover'))
  M.map('n', 'gK', vim.lsp.buf.signature_help, _opts('Signature Help'))
  M.map('i', '<c-k>', vim.lsp.buf.signature_help, _opts('Signature Help'))
  M.map('n', 'gK', vim.lsp.buf.signature_help, _opts('Signature Help'))
  M.map('i', '<c-k>', vim.lsp.buf.signature_help, _opts('Signature Help'))
  M.map('n', 'gn', vim.lsp.buf.rename, _opts('Rename'))
  M.map('n', 'gN', ':IncRename ', _opts('Incremental LSP renaming (inc-rename.nvim)'))
  M.map('n', 'gr', vim.lsp.buf.references, _opts('References'))
  M.map('n', 'gR', '<cmd>Telescope lsp_references<cr>', _opts('References'))
  M.map('n', 'gd', '<cmd>Glance definitions<cr>', _opts('Goto Definition'))
  -- M.map('n', 'gd', function() require('goto-preview').goto_preview_definition() end, _opts('Goto Definition'))
  M.map('n', 'gD', '<cmd>Telescope lsp_definitions<cr>', _opts('Goto Definition'))
  M.map('n', 'gy', '<cmd>Telescope lsp_type_definitions<cr>', _opts('Goto T[y]pe Definition'))
  M.map('n', 'gi', vim.lsp.buf.implementation, _opts('Implementation'))
  M.map('n', 'gI', '<cmd>Telescope lsp_implementations<cr>', _opts('Goto Implementation'))
  if client.supports_method('textDocument/codeAction') then
    M.map({ 'n', 'v' }, 'ga', vim.lsp.buf.code_action, _opts('Code Action'))
  end
  if client.supports_method('textDocument/rangeFormatting') then
    client.server_capabilities.documentRangeFormattingProvider = true
    M.map('x', '<leader>cf', function() vim.lsp.buf.format({ bufnr = buffer, force = true }) end, _opts('Format Range'))
  end
  if client.supports_method('textDocument/formatting') then
    client.server_capabilities.documentFormattingProvider = true
    M.map(
      'n',
      '<leader>cf',
      function() vim.lsp.buf.format({ bufnr = buffer, force = true }) end,
      _opts('Format Document')
    )
  end
end

M.alpha = function()
  local icons = require('module.options').icons.collects
  local button = require('alpha.themes.dashboard').button
  -- stylua: ignore
  return {
    button('f', icons.Search ..         ' Find file', ':Telescope find_files <cr>'),
    button('n', icons.File ..           ' New file', ':ene <bar> startinsert <cr>'),
    button('r', icons.Connectdevelop .. ' Recent files', ':Telescope oldfiles <cr>'),
    button('p', icons.Chrome ..         ' Projects', ':Projects <cr>'),
    button('g', icons.ListAlt ..        ' Find text', ':Telescope live_grep <cr>'),
    button('c', icons.Cogs ..           ' Config', ':e $MYVIMRC <cr>'),
    button('s', icons.IE ..             ' Restore Session', [[:lua require("persistence").load() <cr>]]),
    button('l', icons.Firefox ..        ' Lazy', ':Lazy<cr>'),
    button('q', icons.Modx ..           ' Quit', ':qa<cr>'),
  }
end

M.cmp = function()
  local cmp = require('cmp')
  local _forward = function()
    return cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require('luasnip').expand_or_jumpable() then
        require('luasnip').expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' })
  end
  local _backward = function()
    return cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require('luasnip').jumpable(-1) then
        require('luasnip').jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' })
  end
  return {
    mapping = {
      ['<c-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<c-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<c-b>'] = cmp.mapping.scroll_docs(-4),
      ['<c-f>'] = cmp.mapping.scroll_docs(4),
      ['<c-k>'] = cmp.mapping.select_prev_item(),
      ['<c-j>'] = cmp.mapping.select_next_item(),
      ['<up>'] = cmp.mapping.select_prev_item(),
      ['<down>'] = cmp.mapping.select_next_item(),
      ['<c-space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<tab>'] = _forward(),
      ['<s-tab>'] = _backward(),
      ['<c-y>'] = cmp.mapping.confirm({ select = false }),
      ['<c-e>'] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
      ['<cr>'] = cmp.mapping.confirm({ select = true }),
      ['<s-cr>'] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
  }
end

M.aerial = function()
  return {
    on_attach = function(buffer)
      M.map('n', '{', '<cmd>AerialPrev<cr>', { buffer = buffer })
      M.map('n', '}', '<cmd>AerialNext<cr>', { buffer = buffer })
    end,
  }
end

M.toggleterm = function()
  return {
    open_mapping = [[<c-\>]],
  }
end

M.telescope = function()
  local actions = require('telescope.actions')
  return {
    defaults = {
      mappings = {
        i = {
          ['<c-t>'] = function(...) return require('trouble.providers.telescope').open_with_trouble(...) end,
          ['<a-t>'] = function(...) return require('trouble.providers.telescope').open_selected_with_trouble(...) end,
          ['<a-i>'] = function() return require('telescope.builtin')['find_files']({ no_ignore = true }) end,
          ['<a-h>'] = function() return require('telescope.builtin')['find_files']({ hidden = true }) end,
          ['<c-down>'] = function(...) return actions.cycle_history_next(...) end,
          ['<c-up>'] = function(...) return actions.cycle_history_prev(...) end,
          ['<c-f>'] = function(...) return actions.preview_scrolling_down(...) end,
          ['<c-b>'] = function(...) return actions.preview_scrolling_up(...) end,
          -- ['<esc>'] = function(...) return actions.close(...) end,
        },
        n = {
          ['q'] = function(...) return actions.close(...) end,
        },
      },
    },
  }
end

local _ts_opts = function(path, callback, any)
  return {
    cwd = path,
    search_dirs = { path },
    attach_mappings = function(prompt_bufnr, map)
      local actions = require('telescope.actions')
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = require('telescope.actions.state').get_selected_entry()
        local filename = selection.filename
        if filename == nil then filename = selection[1] end
        callback(filename, any)
      end)
      return true
    end,
  }
end

M.neotree = function()
  local telescope = require('telescope.builtin')
  local fs = require('neo-tree.sources.filesystem')
  return {
    window = {
      mappings = {
        ['e'] = function() vim.api.nvim_exec('Neotree focus filesystem left', true) end,
        ['b'] = function() vim.api.nvim_exec('Neotree focus buffers left', true) end,
        ['g'] = function() vim.api.nvim_exec('Neotree focus git_status left', true) end,
      },
    },
    filesystem = {
      window = {
        mappings = {
          ['O'] = 'system_open',
          ['tf'] = 'telescope_find',
          ['tg'] = 'telescope_grep',
        },
      },
      commands = {
        system_open = function(state)
          local path = state.tree:get_node():get_id()
          require('base').open(path)
        end,
        telescope_find = function(state)
          local path = state.tree:get_node():get_id()
          telescope.find_files(_ts_opts(path, function(name, state) fs.navigate(state, state.path, name) end, state))
        end,
        telescope_grep = function(state)
          local path = state.tree:get_node():get_id()
          telescope.live_grep(_ts_opts(path, function(name, state) fs.navigate(state, state.path, name) end, state))
        end,
      },
    },
  }
end

M.nvim_tree = function()
  local _path = function()
    local node = require('nvim-tree.lib').get_node_at_cursor()
    if node == nil then return end
    local is_folder = node.fs_stat and node.fs_stat.type == 'directory' or false
    local basedir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ':h')
    if node.name == '..' and TreeExplorer ~= nil then basedir = TreeExplorer.cwd end
    return basedir
  end
  local _opts = function(desc, bufnr) return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, nowait = true } end
  local telescope = require('telescope.builtin')
  local fs = require('nvim-tree.actions.node.open-file')
  local _find = function()
    telescope.find_files(_ts_opts(_path(), function(name) fs.fn('preview', name) end))
  end
  local _grep = function()
    telescope.live_grep(_ts_opts(_path(), function(name) fs.fn('preview', name) end))
  end
  local _on_attach = function(bufnr)
    local api = require('nvim-tree.api')
    api.config.mappings.default_on_attach(bufnr)
    M.map('n', '<c-f>', _find, _opts('Find', bufnr))
    M.map('n', '<c-g>', _grep, _opts('Grep', bufnr))
  end
  return {
    on_attach = _on_attach,
  }
end

M.gitsigns = function()
  local opts = {
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns
      local _opts = function(desc) return { buffer = buffer, desc = desc } end
      M.map({ 'n', 'v' }, '<leader>ghs', ':Gitsigns stage_hunk<CR>', _opts('Stage Hunk'))
      M.map({ 'n', 'v' }, '<leader>ghr', ':Gitsigns reset_hunk<CR>', _opts('Reset Hunk'))
      M.map('n', '<leader>ghS', gs.stage_buffer, _opts('Stage Buffer'))
      M.map('n', '<leader>ghu', gs.undo_stage_hunk, _opts('Undo Stage Hunk'))
      M.map('n', '<leader>ghR', gs.reset_buffer, _opts('Reset Buffer'))
      M.map('n', '<leader>ghp', gs.preview_hunk, _opts('Preview Hunk'))
      M.map('n', '<leader>ghb', function() gs.blame_line({ full = true }) end, _opts('Blame Line'))
      M.map('n', '<leader>ghd', gs.diffthis, _opts('Diff This'))
      M.map('n', '<leader>ghD', function() gs.diffthis('~') end, _opts('Diff This ~'))
      M.map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', _opts('GitSigns Select Hunk'))
    end,
  }
  return opts
end

M.surround = function()
  local opts = {
    mappings = {
      add = 'gza', -- Add surrounding in Normal and Visual modes
      delete = 'gzd', -- Delete surrounding
      find = 'gzf', -- Find surrounding (to the right)
      find_left = 'gzF', -- Find surrounding (to the left)
      highlight = 'gzh', -- Highlight surrounding
      replace = 'gzr', -- Replace surrounding
      update_n_lines = 'gzn', -- Update `n_lines`
    },
  }
  return opts
end

M.ts = function()
  local opts = {
    incremental_selection = {
      keymaps = {
        init_selection = '<c-space>', -- 'Increment selection'
        node_incremental = '<c-space>', -- 'Increment selection'
        scope_incremental = '<nop>',
        node_decremental = '<bs>', -- 'Decrement selection'
      },
    },
  }
  return opts
end

M.marks = function()
  local mappings = {
    set = 'm',
    set_next = 'm,',
    toggle = 'm;',
    next = 'm]',
    prev = 'm[',
    preview = 'm:',
    next_bookmark = 'm}',
    prev_bookmark = 'm{',
    delete = 'dm',
    delete_line = 'dm-',
    delete_bookmark = 'dm=',
    delete_buf = 'dm<space>',
  }
  for i = 0, 9 do
    mappings['set_bookmark' .. i] = 'm' .. tostring(i)
    mappings['delete_bookmark' .. i] = 'dm' .. tostring(i)
  end
  for cmd, key in pairs(mappings) do
    -- print(vim.inspect(cmd))
    M.map({ 'n', 'x' }, key, " <cmd>lua require'marks'." .. cmd .. '()<cr>', cmd .. ' (marks.nvim)')
  end
end

M.neo_minimap = function(nm)
  -- Lua
  local lua = {
    events = { 'BufEnter' },
    query = {
      [[
              ;; query
              ;; ((function_declaration name: ((identifier) @name (#eq? @name "{cursorword}"))) @cap)
              ;; ((function_call name: ((identifier) @name (#eq? @name "{cursorword}"))) @cap)
              ;; ((dot_index_expression field: ((identifier) @name (#eq? @name "{cursorword}"))) @cap)
              ((function_declaration) @cap)
              ((assignment_statement(expression_list((function_definition) @cap))))
              ]],
      1,
      [[
              ;; query
              ((function_declaration) @cap)
              ((assignment_statement(expression_list((function_definition) @cap))))
              ((field (identifier) @cap) (#eq? @cap "keymaps"))
              ]],
      [[
              ;; query
              ((for_statement) @cap)
              ((function_declaration) @cap)
              ((assignment_statement(expression_list((function_definition) @cap))))

              ((function_call (identifier)) @cap (#vim-match? @cap "^__*" ))
              ((function_call (dot_index_expression) @field (#eq? @field "vim.keymap.set")) @cap)
              ]],
      [[
              ;; query
              ((for_statement) @cap)
              ((function_declaration) @cap)
              ((assignment_statement(expression_list((function_definition) @cap))))
              ]],
    },
    regex = {
      {},
      { [[^\s*---*\s\+\w\+]], [[--\s*=]] },
      { [[^\s*---*\s\+\w\+]], [[--\s*=]] },
      {},
    },
    search_patterns = {
      { 'function', '<c-j>', true },
      { 'function', '<c-k>', false },
      { 'keymap', '<a-j>', true },
      { 'keymap', '<a-k>', false },
    },
    -- auto_jump = false,
    -- open_win_opts = { border = "double" },
    win_opts = { scrolloff = 1 },
    disable_indentaion = true,
  }
  nm.set({ 'zi', 'zo', 'zu' }, '*.lua', lua)
  -- C++
  local cpp = {
    events = { 'BufEnter' },
    query = {
      [[
        ;; query
        ((function_definition) @cap)
      ]],
      -- [[
      --   ;; query
      --   (class_specifier
      --   name: (type_identifier) @cap
      --   ) @cap
      -- ]],
    },
    search_patterns = {
      { 'class', '<a-j>', true },
      { 'class', '<a-k>', false },
    },
    win_opts = { scrolloff = 1 },
    disable_indentaion = true,
  }
  nm.set({ 'zi', 'zo', 'zu' }, { '*.cpp', '*.h', '*.c' }, cpp)
  -- Rust
  local rust = {
    events = { 'BufEnter' },
    query = {
      [[
        ;; query
        (enum_item (type_identifier) @cap)
        (trait_item (type_identifier) @cap)
        (struct_item (type_identifier) @cap)
        ;; (impl_item (type_identifier) @cap)
        ((impl_item) @cap)
        (function_item (identifier) @cap)
        (mod_item (identifier) @cap)
        (macro_definition (identifier) @cap)
      ]],
      1,
    },
    regex = {},
    search_patterns = {
      { 'impl', '<c-j>', true },
      { 'impl', '<c-k>', false },
      { 'mod', '<c-l>', false },
    },
    height_toggle = { 20, 25 },
  }
  nm.set({ 'zi', 'zo' }, '*.rs', rust)
end

M.wk = function(wk)
  local function _any_toggle(cmd)
    local run = require('toggleterm.terminal').Terminal:new({
      cmd = cmd,
      dir = 'git_dir',
      direction = 'float',
      float_opts = { border = 'double' },
      on_open = function(term)
        vim.cmd('startinsert!')
        M.map('n', 'q', '<cmd>close<cr>', { buffer = term.bufnr })
      end,
      on_close = function(term) vim.cmd('startinsert!') end,
    })
    run:toggle()
  end
  local _copy_content = function() return base.copy_to_clipboard(base.get_content()) end
  local _copy_path = function() return base.copy_to_clipboard(base.to_native(base.get_path())) end
  local _copy_relative_path = function() return base.copy_to_clipboard(base.to_native(base.get_relative_path())) end
  local _copy_name = function() return base.copy_to_clipboard(base.name()) end
  local _copy_name_without_ext = function() return base.copy_to_clipboard(base.get_name_without_ext()) end
  local _copy_contain_directory = function() return base.copy_to_clipboard(base.to_native(base.get_contain_directory())) end
  local _reveal_cwd_in_file_explorer = function() base.open(vim.fn.getcwd()) end
  local _reveal_file_in_file_explorer = function() base.open(base.get_contain_directory()) end
  local _open_with_default_app = function() base.open(base.get_current_buffer_name()) end
  local _rename = function() vim.cmd('IncRename ' .. vim.fn.expand('<cword>')) end
  local _NvimTree_find = function()
    local path = require('base').get_path
    -- require('nvim-tree').change_dir(vim.loop.cwd())
    -- require('nvim-tree.actions.root.change-dir').fn(vim.loop.cwd())
    require('nvim-tree.api').tree.open({ find_file = true, focus = true, path = path, update_root = false })
  end
  local _notify_history = function()
    require('telescope').extensions.notify.notify({
      layout_strategy = 'vertical',
      layout_config = { preview_cutoff = 1, width = 0.8, height = 0.8 },
    })
  end
  local _purge_notify = function() require('notify').dismiss({ silent = true, pending = true }) end
  local _telescope_symbols = function(e)
    require('telescope.builtin')[e]({
      symbols = {
        'Class',
        'Function',
        'Method',
        'Constructor',
        'Interface',
        'Module',
        'Struct',
        'Trait',
        'Field',
        'Property',
      },
    })
  end
  local _hlslens_qf = function()
    vim.schedule(function()
      if require('hlslens').exportLastSearchToQuickfix() then vim.cmd('cw') end
    end)
    return vim.cmd([[noh]])
  end
  local _options_hydra = function()
    local Hydra = require('hydra')
    local hint = [[
  ^ ^        Options
  ^
  _v_ %{ve} virtual edit
  _i_ %{list} invisible characters
  _s_ %{spell} spell
  _w_ %{wrap} wrap
  _c_ %{cul} cursor line
  _n_ %{nu} number
  _r_ %{rnu} relative number
  ^
      ^^^^                _<Esc>_
    ]]
    local opts_hydra = Hydra({
      name = 'Options',
      hint = hint,
      config = {
        color = 'amaranth',
        invoke_on_body = true,
        hint = {
          border = 'rounded',
          position = 'middle',
        },
      },
      -- mode = { 'n', 'x' },
      -- body = '<leader>o',
      heads = {
        {
          'n',
          function()
            if vim.o.number == true then
              vim.o.number = false
            else
              vim.o.number = true
            end
          end,
          { desc = 'number' },
        },
        {
          'r',
          function()
            if vim.o.relativenumber == true then
              vim.o.relativenumber = false
            else
              vim.o.number = true
              vim.o.relativenumber = true
            end
          end,
          { desc = 'relativenumber' },
        },
        {
          'v',
          function()
            if vim.o.virtualedit == 'all' then
              vim.o.virtualedit = 'block'
            else
              vim.o.virtualedit = 'all'
            end
          end,
          { desc = 'virtualedit' },
        },
        {
          'i',
          function()
            if vim.o.list == true then
              vim.o.list = false
            else
              vim.o.list = true
            end
          end,
          { desc = 'show invisible' },
        },
        {
          's',
          function()
            if vim.o.spell == true then
              vim.o.spell = false
            else
              vim.o.spell = true
            end
          end,
          { exit = true, desc = 'spell' },
        },
        {
          'w',
          function()
            if vim.o.wrap ~= true then
              vim.o.wrap = true
              -- Dealing with word wrap:
              -- If cursor is inside very long line in the file than wraps
              -- around several rows on the screen, then 'j' key moves you to
              -- the next line in the file, but not to the next row on the
              -- screen under your previous position as in other editors. These
              -- bindings fixes this.
              vim.keymap.set(
                'n',
                'k',
                function() return vim.v.count > 0 and 'k' or 'gk' end,
                { expr = true, desc = 'k or gk' }
              )
              vim.keymap.set(
                'n',
                'j',
                function() return vim.v.count > 0 and 'j' or 'gj' end,
                { expr = true, desc = 'j or gj' }
              )
            else
              vim.o.wrap = false
              vim.keymap.del('n', 'k')
              vim.keymap.del('n', 'j')
            end
          end,
          { desc = 'wrap' },
        },
        {
          'c',
          function()
            if vim.o.cursorline == true then
              vim.o.cursorline = false
            else
              vim.o.cursorline = true
            end
          end,
          { desc = 'cursor line' },
        },
        { '<Esc>', nil, { exit = true } },
      },
    })
    opts_hydra:activate()
  end
  local _fuzzy_hydra = function()
    local Hydra = require('hydra')
    local cmd = require('hydra.keymap-util').cmd
    local hint = [[
                     _f_: files       _m_: marks
       🭇🬭🬭🬭🬭🬭🬭🬭🬭🬼    _o_: old files   _g_: live grep
      🭉🭁🭠🭘    🭣🭕🭌🬾   _p_: projects    _/_: search in file
      🭅█ ▁     █🭐
      ██🬿      🭊██   _r_: resume      _u_: undotree
     🭋█🬝🮄🮄🮄🮄🮄🮄🮄🮄🬆█🭀  _h_: vim help    _c_: execute command
     🭤🭒🬺🬹🬱🬭🬭🬭🬭🬵🬹🬹🭝🭙  _k_: keymaps     _;_: commands history
                     _O_: options     _?_: search history
     ^
                     _<Enter>_: Telescope           _<Esc>_
    ]]
    local opts = {
      name = 'Telescope',
      hint = hint,
      config = {
        color = 'teal',
        invoke_on_body = true,
        hint = {
          position = 'middle',
          border = 'rounded',
        },
      },
      -- mode = 'n',
      -- body = '<Leader>f',
      heads = {
        { 'f', cmd('Telescope find_files') },
        { 'g', cmd('Telescope live_grep') },
        { 'o', cmd('Telescope oldfiles'), { desc = 'recently opened files' } },
        { 'h', cmd('Telescope help_tags'), { desc = 'vim help' } },
        { 'm', cmd('MarksListBuf'), { desc = 'marks' } },
        { 'k', cmd('Telescope keymaps') },
        { 'O', cmd('Telescope vim_options') },
        { 'r', cmd('Telescope resume') },
        { 'p', cmd('Telescope projects'), { desc = 'projects' } },
        { '/', cmd('Telescope current_buffer_fuzzy_find'), { desc = 'search in file' } },
        { '?', cmd('Telescope search_history'), { desc = 'search history' } },
        { ';', cmd('Telescope command_history'), { desc = 'command-line history' } },
        { 'c', cmd('Telescope commands'), { desc = 'execute command' } },
        { 'u', cmd('silent! %foldopen! | UndotreeToggle'), { desc = 'undotree' } },
        { '<Enter>', cmd('Telescope'), { exit = true, desc = 'list all pickers' } },
        { '<Esc>', nil, { exit = true, nowait = true } },
      },
    }
    local fuzzy_hydra = Hydra(opts)
    fuzzy_hydra:activate()
  end
  local _draw_diagram_hydra = function()
    local Hydra = require('hydra')
    local hint = [[
  Arrow^^^^^^   Select region with <C-v>
  ^ ^ _K_ ^ ^   _f_: surround it with box
  _H_ ^ ^ _L_
  ^ ^ _J_ ^ ^                      _<Esc>_
    ]]
    local opts = {
      name = 'Draw Diagram',
      hint = hint,
      config = {
        color = 'pink',
        invoke_on_body = true,
        hint = {
          border = 'rounded',
        },
        on_enter = function() vim.o.virtualedit = 'all' end,
      },
      -- mode = 'n',
      -- body = '<leader>ed',
      heads = {
        { 'H', '<C-v>h:VBox<CR>' },
        { 'J', '<C-v>j:VBox<CR>' },
        { 'K', '<C-v>k:VBox<CR>' },
        { 'L', '<C-v>l:VBox<CR>' },
        { 'f', ':VBox<CR>', { mode = 'v' } },
        { '<Esc>', nil, { exit = true } },
      },
    }
    local draw_hydra = Hydra(opts)
    draw_hydra:activate()
  end
  -- Pink hydra
  local _git_hydra = function()
    local Hydra = require('hydra')
    local gitsigns = require('gitsigns')
    local hint = [[
  _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
  _K_: prev hunk   _u_: undo last stage   _p_: preview hunk   _B_: blame show full
  ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
  ^
  ^ ^              _<Enter>_: Neogit              _q_: exit
    ]]
    local opts = {
      name = 'Git',
      hint = hint,
      config = {
        buffer = bufnr,
        color = 'pink',
        invoke_on_body = true,
        hint = {
          border = 'rounded',
        },
        on_enter = function()
          vim.cmd('mkview')
          vim.cmd('silent! %foldopen!')
          vim.bo.modifiable = false
          gitsigns.toggle_signs(true)
          gitsigns.toggle_linehl(true)
        end,
        on_exit = function()
          local cursor_pos = vim.api.nvim_win_get_cursor(0)
          vim.cmd('loadview')
          vim.api.nvim_win_set_cursor(0, cursor_pos)
          vim.cmd('normal zv')
          gitsigns.toggle_signs(false)
          gitsigns.toggle_linehl(false)
          gitsigns.toggle_deleted(false)
        end,
      },
      -- mode = {'n','x'},
      -- body = '<leader>g',
      heads = {
        {
          'J',
          function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gitsigns.next_hunk() end)
            return '<Ignore>'
          end,
          { expr = true, desc = 'next hunk' },
        },
        {
          'K',
          function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gitsigns.prev_hunk() end)
            return '<Ignore>'
          end,
          { expr = true, desc = 'prev hunk' },
        },
        { 's', ':Gitsigns stage_hunk<CR>', { silent = true, desc = 'stage hunk' } },
        { 'u', gitsigns.undo_stage_hunk, { desc = 'undo last stage' } },
        { 'S', gitsigns.stage_buffer, { desc = 'stage buffer' } },
        { 'p', gitsigns.preview_hunk, { desc = 'preview hunk' } },
        { 'd', gitsigns.toggle_deleted, { nowait = true, desc = 'toggle deleted' } },
        { 'b', gitsigns.blame_line, { desc = 'blame' } },
        { 'B', function() gitsigns.blame_line({ full = true }) end, { desc = 'blame show full' } },
        { '/', gitsigns.show, { exit = true, desc = 'show base file' } }, -- show the base of the file
        { '<Enter>', '<Cmd>Neogit<CR>', { exit = true, desc = 'Neogit' } },
        { 'q', nil, { exit = true, nowait = true, desc = 'exit' } },
      },
    }
    local git_hydra = Hydra(opts)
    git_hydra:activate()
  end
  local _word_hydra = function()
    local Hydra = require('hydra')
    local word_hydra = Hydra({
      name = 'Quick words',
      config = {
        color = 'pink',
        hint = {
          type = 'window', -- statusline window
        },
      },
      -- mode = { 'n', 'x', 'o' },
      -- body = ',',
      heads = {
        { 'w', '<Plug>(smartword-w)' },
        { 'b', '<Plug>(smartword-b)' },
        { 'e', '<Plug>(smartword-e)' },
        { 'ge', '<Plug>(smartword-ge)' },
        { '<Esc>', nil, { exit = true, mode = 'n' } },
      },
    })
    word_hydra:activate()
  end
  local _buffer_win_hydra = function()
    local Hydra = require('hydra')
    local splits = require('smart-splits')
    local cmd = require('hydra.keymap-util').cmd
    local pcmd = require('hydra.keymap-util').pcmd
    local buffer_hydra = Hydra({
      name = 'Barbar',
      config = {
        on_key = function()
          -- Preserve animation
          vim.wait(200, function() vim.cmd('redraw') end, 30, false)
        end,
      },
      heads = {
        { 'h', function() vim.cmd('BufferPrevious') end, { on_key = false } },
        { 'l', function() vim.cmd('BufferNext') end, { desc = 'choose', on_key = false } },
        { 'H', function() vim.cmd('BufferMovePrevious') end },
        { 'L', function() vim.cmd('BufferMoveNext') end, { desc = 'move' } },
        { 'p', function() vim.cmd('BufferPin') end, { desc = 'pin' } },
        { 'd', function() vim.cmd('BufferClose') end, { desc = 'close' } },
        { 'c', function() vim.cmd('BufferClose') end, { desc = false } },
        { 'q', function() vim.cmd('BufferClose') end, { desc = false } },
        { 'od', function() vim.cmd('BufferOrderByDirectory') end, { desc = 'by directory' } },
        { 'ol', function() vim.cmd('BufferOrderByLanguage') end, { desc = 'by language' } },
        { '<Esc>', nil, { exit = true } },
      },
    })
    local function choose_buffer()
      if #vim.fn.getbufinfo({ buflisted = true }) > 1 then buffer_hydra:activate() end
    end
    local window_hint = [[
     ^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split
     ^^^^^^^^^^^^-------------  ^^-----------^^   ^^---------------
     ^ ^ _k_ ^ ^  ^ ^ _K_ ^ ^   ^   _<C-k>_   ^   _s_: horizontally
     _h_ ^ ^ _l_  _H_ ^ ^ _L_   _<C-h>_ _<C-l>_   _v_: vertically
     ^ ^ _j_ ^ ^  ^ ^ _J_ ^ ^   ^   _<C-j>_   ^   _q_, _c_: close
     focus^^^^^^  window^^^^^^  ^_=_: equalize^   _z_: maximize
     ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^   _o_: remain only
     _b_: choose buffer
    ]]
    local buffer_win_hydra = Hydra({
      name = 'Windows',
      hint = window_hint,
      config = {
        invoke_on_body = true,
        hint = {
          border = 'rounded',
          offset = -1,
        },
      },
      --  mode = 'n',
      --  body = '<C-w>',
      heads = {
        { 'h', '<C-w>h' },
        { 'j', '<C-w>j' },
        { 'k', pcmd('wincmd k', 'E11', 'close') },
        { 'l', '<C-w>l' },
        { 'H', cmd('WinShift left') },
        { 'J', cmd('WinShift down') },
        { 'K', cmd('WinShift up') },
        { 'L', cmd('WinShift right') },
        { '<C-h>', function() splits.resize_left(2) end },
        { '<C-j>', function() splits.resize_down(2) end },
        { '<C-k>', function() splits.resize_up(2) end },
        { '<C-l>', function() splits.resize_right(2) end },
        { '=', '<C-w>=', { desc = 'equalize' } },
        { 's', pcmd('split', 'E36') },
        { '<C-s>', pcmd('split', 'E36'), { desc = false } },
        { 'v', pcmd('vsplit', 'E36') },
        { '<C-v>', pcmd('vsplit', 'E36'), { desc = false } },
        { 'w', '<C-w>w', { exit = true, desc = false } },
        { '<C-w>', '<C-w>w', { exit = true, desc = false } },
        { 'z', cmd('WindowsMaximaze'), { exit = true, desc = 'maximize' } },
        { '<C-z>', cmd('WindowsMaximaze'), { exit = true, desc = false } },
        { 'o', '<C-w>o', { exit = true, desc = 'remain only' } },
        { '<C-o>', '<C-w>o', { exit = true, desc = false } },
        { 'b', choose_buffer, { exit = true, desc = 'choose buffer' } },
        { 'c', pcmd('close', 'E444') },
        { 'q', pcmd('close', 'E444'), { desc = 'close window' } },
        { '<C-c>', pcmd('close', 'E444'), { desc = false } },
        { '<C-q>', pcmd('close', 'E444'), { desc = false } },
        { '<Esc>', nil, { exit = true, desc = false } },
      },
    })
    buffer_win_hydra:activate()
  end
  -- stylua: ignore start
  local wk_ve = {
      name = '+Edit Config',
      i = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/init.lua') end,                'init.lua (bootstrap)' },
      b = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/base.lua') end,            'base.lua' },
      k = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/module/bindings.lua') end, 'bindings.lua' },
      l = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/module/lsp.lua') end,      'lsp.lua' },
      o = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/module/options.lua') end,  'options.lua' },
      p = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/module/plugins.lua') end,  'plugins.lua' },
      s = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/module/settings.lua') end, 'settings.lua' },
    }
  -- stylua: ignore end
  local n = {
    ['<tab>'] = { name = '+Tabs' },
    q = {
      name = '+Quit',
      q = { '<cmd>qa<cr>', 'Quit All' },
      w = { '<cmd>wqall<cr>', 'Quit And Save Everything' },
      f = { '<cmd>q!<cr>', 'Quit Force' },
      F = { '<cmd>qa!<cr>', 'Quit All Force' },
      -- s = { '<cmd>w<cr>', 'Save' },
      s = {
        name = '+Session',
        s = { '<cmd>SessionManager save_current_session<cr>', 'Save Current Session' },
        l = { '<cmd>SessionManager load_session<cr>', 'Select And Load Session.' },
        r = { '<cmd>SessionManager load_last_session<cr>', 'Restore Session' },
        -- S = { '<cmd>Obsession ~/session.vim<cr>', 'Save Session' },
        -- R = { '<cmd>Obsession ~/session.vim<cr>:!start neovide -- -S ~/session.vim<cr><cr>:wqall<cr>', 'Quit And Reload' },
        a = { '<cmd>lua require("persistence").load()<cr>', 'Restore AutoSaved Session (persistence.nvim)' },
        b = { function() require('persistence').load() end, 'Restore Session' },
        c = { function() require('persistence').load({ last = true }) end, 'Restore Last Session' },
        d = { function() require('persistence').stop() end, "Don't Save Current Session" },
      },
    },
    c = {
      name = '+C',
      a = { '<cmd>ClangAST<cr>', 'Clang AST' },
      t = { '<cmd>ClangdTypeHierarchy<cr>', 'Clang Type Hierarchy' },
      h = { '<cmd>ClangdSwitchSourceHeader<cr>', 'Switch C/C++ Header/Source' },
      m = { '<cmd>ClangdMemoryUsage<cr>', 'Clangd Memory Usage' },
      d = { function() require('cppdoc').open() end, 'Search cppreference Local' },
      g = { '<cmd>Godbolt!<cr>', 'Godbolt ASM Code' },
    },
    w = {
      name = '+Windows',
      w = { '<cmd>WinShift<cr>', 'Win-Move mode' },
      b = {
        name = '+Blank New File In A Split',
        h = { '<cmd>new<cr>', 'New Horizontal' },
        v = { '<cmd>vnew<cr>', 'New Vertically' },
      },
      h = { '<c-w>h', 'Jump Left' },
      j = { '<c-w>j', 'Jump Down' },
      k = { '<c-w>k', 'Jump Up' },
      l = { '<c-w>l', 'Jump Right' },
      e = { '<cmd>vsplit<cr><esc>', 'Split Left' },
      d = { '<cmd>split<cr><c-w>j<esc>', 'Split Down' },
      u = { '<cmd>split<cr><esc>', 'Split Up' },
      r = { '<cmd>vsplit<cr><c-w>l<esc>', 'Split Right' },
      o = { '<cmd>only<cr>', 'Only' },
      c = { '<cmd>close<cr>', 'Close' },
      s = {
        name = '+Swapping Buffers Between Windows',
        h = { function() require('smart-splits').swap_buf_left() end, 'Left' },
        l = { function() require('smart-splits').swap_buf_right() end, 'Right' },
        j = { function() require('smart-splits').swap_buf_down() end, 'Down' },
        k = { function() require('smart-splits').swap_buf_up() end, 'Up' },
      },
    },
    b = {
      name = '+Buffer',
      b = { _buffer_win_hydra, 'Buffer Hydra' },
      c = { '<cmd>Bdelete<cr>', 'Buffer Close' },
      e = { ':ene <bar> startinsert <cr>', 'New Buffer' },
      n = { ':ene <bar> startinsert <cr>', 'New Buffer' },
      f = { '<cmd>FlyBuf<cr>', 'Fly Buffer' },
      p = { '<Cmd>BufferLineTogglePin<CR>', 'Toggle pin' },
      o = { '<Cmd>BufferLineGroupClose ungrouped<CR>', 'Delete non-pinned buffers, Only pinned' },
      O = { '<cmd>BWipeout other<cr>', 'Only Current Buffer' },
      a = { '<cmd>Telescope buffers show_all_buffers=true<cr>', 'Switch Buffer' },
      d = { function() require('mini.bufremove').delete(0, false) end, 'Delete Buffer' },
      D = { function() require('mini.bufremove').delete(0, true) end, 'Delete Buffer (Force)' },
    },
    v = {
      name = '+Vim',
      a = { '<cmd>Alpha<cr>', 'Toggle Alpha Dashboard' },
      f = { '<cmd>ToggleFullScreen<cr>', 'Toggle FullScreen' },
      z = { '<cmd>ZenMode<cr>', 'Zen Mode' },
      e = wk_ve,
      i = { '<cmd>Lazy<cr>', 'Lazy Dashboard' },
      p = { '<cmd>Lazy profile<cr>', 'Lazy Profile' },
      u = { '<cmd>Lazy update<cr>', 'Lazy Update' },
      c = { '<cmd>Lazy clean<cr>', 'Lazy Clean' },
      s = { vim.show_pos, 'Inspect Pos' },
      o = { _options_hydra, 'Options' },
    },
    h = {
      name = '+History/Notifications',
      l = { function() require('noice').cmd('last') end, 'Noice Last Message' },
      h = { function() require('noice').cmd('history') end, 'Noice History' },
      a = { function() require('noice').cmd('all') end, 'Noice All' },
      d = { _purge_notify, 'Delete all Notifications' },
      c = { '<cmd>Telescope command_history<cr>', 'Command History' },
      -- n = { '<cmd>Telescope notify<cr>', 'Notification History' },
      n = { _notify_history, 'Notification History' },
    },
    l = {
      name = '+LSP',
      i = { '<cmd>LspInfo<cr>', 'Info' },
      -- l = { '<cmd>Lspsaga show_line_diagnostics<cr>', 'Lspsaga Show Line Diagnostics' },
      l = { vim.diagnostic.open_float, 'Line Diagnostics' },
      L = { function() require('lsp_lines').toggle() end, 'Toggle lsp_lines' },
      -- f = { '<cmd>FormatCode<cr>', 'Format Code' },
      f = { '<cmd>FormatDocument<cr>', 'Format Document' },
      a = { '<cmd>AerialToggle<cr>', 'Aerial OutlineToggle (aerial.nvim)' },
      o = { '<cmd>SymbolsOutline<cr>', 'Symbols Outline Toggle (symbols-outline.nvim)' },
      s = { function() _telescope_symbols('lsp_document_symbols') end, 'Document Symbols' },
      c = { function() _telescope_symbols('lsp_dynamic_workspace_symbols') end, 'Workspace Symbols' },
      n = { ':IncRename ', 'Incremental LSP renaming (inc-rename.nvim)' },
      -- g = { function() require('refactoring').select_refactor() end, 'Refactoring' },
    },
    d = {
      name = '+Debug',
      b = {
        name = 'Breakpoint',
        b = { '<cmd>PBToggleBreakpoint<cr>', 'Toggle Breakpoint' },
        c = { '<cmd>PBSetConditionalBreakpoint<cr>', 'Toggle Condition Breakpoint' },
        l = { '<cmd>PBLoad<cr>', 'Load Saved Breakpoint' },
        d = { '<cmd>PBClearAllBreakpoints<cr>', 'Clear All Breakpoint' },
      },
      c = { _dap_continue, 'Continue' },
      o = { function() require('dap').step_over() end, 'Step Over' },
      i = { function() require('dap').step_into() end, 'Step Into' },
      f = { function() require('dap').step_out() end, 'Step Out' },
      r = { function() require('dap').run_last() end, 'Run Last' },
      l = { function() require('dap').run_to_cursor() end, 'Run To Cursor Line' },
      x = { function() require('dap').terminate() end, 'Terminate' },
      e = { function() require('dap').repl.open() end, 'Repl Eval' },
      u = { function() require('dapui').toggle({}) end, 'Dap UI' },
      h = { function() require('dap.ui.widgets').hover() end, 'Hover' },
      s = { function() require('osv').launch({ port = 8086 }) end, 'Launch Lua Debugger Server' },
      X = { function() require('osv').stop() end, 'Stop Lua Debugger Server' },
      d = { function() require('osv').run_this() end, 'Launch Lua Debugger' },
    },
    x = {
      name = '+Diagnostics/Quickfix',
      d = { '<cmd>TroubleToggle document_diagnostics<cr>', 'Trouble Document Diagnostics (Trouble)' },
      w = { '<cmd>TroubleToggle workspace_diagnostics<cr>', 'Workspace Diagnostics (Trouble)' },
      l = { '<cmd>TroubleToggle loclist<cr>', 'Location List (Trouble)' },
      q = { '<cmd>TroubleToggle quickfix<cr>', 'Quickfix List (Trouble)' },
      t = { '<cmd>TodoTrouble<cr>', 'Todo (Trouble)' },
      k = { '<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>', 'Todo/Fix/Fixme (Trouble)' },
      L = { '<cmd>lopen<cr>', 'Location List' },
      Q = { '<cmd>copen<cr>', 'Quickfix List' },
      D = { '<cmd>Telescope diagnostics bufnr=0<cr>', 'Document Diagnostics' },
      x = { '<cmd>TroubleToggle<cr>', 'Trouble Toggle' },
      r = { '<cmd>TroubleToggle lsp_references<cr>', 'Trouble LSP References' },
    },
    s = {
      name = '+Search Code',
      c = { '<cmd>SearchCode<cr>', 'Search' },
      t = { '<cmd>TodoTelescope<cr>', 'Todo' },
      T = { '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>', 'Todo/Fix/Fixme' },
      r = { function() require('spectre').open() end, 'Replace in files (Spectre)' },
      f = { function() require('spectre').open_file_search() end, 'Search File' },
      p = { function() require('spectre').open() end, 'Search Project' },
      R = { function() require('ssr').open() end, 'Structural Replace' },
      l = { _hlslens_qf, 'Run `:nohlsearch` And Export Results To Quickfix' },
    },
    g = {
      name = '+Git',
      h = {
        name = '+Hunk',
      },
      m = { '<cmd>SublimeMerge<cr>', 'Sublime Merge' },
      g = { _git_hydra, 'Git Hydra' },
    },
    t = {
      name = '+Terminal',
      -- h = {
      --   function() vim.cmd('ToggleTerm direction=horizontal dir=' .. require('base').get_contain_directory()) end,
      --   'Terminal Horizontal',
      -- },
      -- f = {
      --   function() vim.cmd('ToggleTerm direction=float dir=' .. require('base').get_contain_directory()) end,
      --   'Terminal Floating',
      -- },
      h = { '<cmd>ToggleTerm direction=horizontal<cr>', 'Terminal Horizontal' },
      f = { '<cmd>ToggleTerm direction=float<cr>', 'Terminal Floating' },
      l = { function() _any_toggle('lazygit') end, 'Lazygit' },
      g = { function() _any_toggle('gitui') end, 'GitUI' },
      b = { function() _any_toggle('btop') end, 'btop' },
      t = { function() _any_toggle('htop') end, 'htop' },
      p = { function() _any_toggle('python') end, 'python' },
    },
    e = {
      name = '+Edit',
      t = {
        name = 'Toggle',
        a = { '<cmd>ToggleAutoFormat<cr>', 'Auto Format Toggle' },
        w = { '<cmd>ToggleWrap<cr>', 'Toggle Wrap' },
        c = { '<cmd>ToggleCaseSensitive<cr>', 'Toggle Case Sensitive' },
        t = { '<cmd>Twilight<cr>', 'Twilight Dims Inactive' },
        f = { '<cmd>ToggleFocusMode<cr>', 'Toggle Focus Mode' },
      },
      s = { '<cmd>SublimeText<cr>', 'Sublime Text' },
      i = {
        name = '+Insert',
        t = { '<cmd>InsertTime<cr>', 'Insert Time' },
        d = { '<cmd>InsertDate<cr>', 'Insert Date' },
      },
      c = {
        name = '+Copy Information',
        c = { _copy_content, 'Copy Content' },
        n = { _copy_name, 'Copy File Name' },
        e = { _copy_name_without_ext, 'Copy File Name Without Ext' },
        d = { _copy_contain_directory, 'Copy Contain Directory' },
        p = { _copy_path, 'Copy Path' },
        r = { _copy_relative_path, 'Copy Relative Path' },
      },
      e = {
        name = '+Ending',
        l = { '<cmd>RemoveExclusiveORM<cr>', 'ORM Ending' },
        u = { '<cmd>set ff=unix<cr>', 'Unix Ending' },
        w = { '<cmd>set ff=dos<cr>', 'Windows Ending' },
        m = { '<cmd>set ff=mac<cr>', 'Mac Ending' },
      },
      d = { _draw_diagram_hydra, 'Draw Diagram' },
      w = { _word_hydra, 'Word Hydra' },
    },
    f = {
      name = '+Fuzzy/File/Explorer',
      s = { '<cmd>confirm wa<cr>', 'Save All' },
      n = { function() vim.cmd('NnnPicker ' .. require('base').get_contain_directory()) end, 'nnn Explorer' },
      e = { _NvimTree_find, 'NvimTree Explorer' },
      d = { '<cmd>Neotree<cr>', 'Neotree Explorer' },
      t = { '<cmd>NvimTreeToggle<cr>', 'Toggle Tree Explorer' },
      v = { '<cmd>VFiler<cr>', 'VFiler File explorer' },
      f = { '<cmd>Telescope find_files theme=get_dropdown previewer=false<cr>', 'Find files' },
      l = { '<cmd>Telescope live_grep_args<cr>', 'Find Text Args' },
      -- p = { '<cmd>Telescope projects<cr>', 'Projects' },
      p = { '<cmd>Projects<cr>', 'Projects' },
      w = { '<cmd>Telescope projections<cr>', 'Workspaces' },
      o = { '<cmd>Telescope oldfiles<cr>', 'Frecency Files' },
      u = { '<cmd>Telescope undo bufnr=0<cr>', 'Undo Tree' },
      r = { '<cmd>Telescope repo list<cr>', 'Repo list' },
      a = { _open_with_default_app, 'Open With Default APP' },
      x = { _reveal_file_in_file_explorer, 'Reveal In File Explorer' },
      z = { _fuzzy_hydra, 'Fuzzy Hydra' },
    },
  }
  wk.register(n, { mode = { 'n', 'v', 'x' }, prefix = '<leader>' })
  local np = {
    mode = { 'n', 'v' },
    ['g'] = { name = '+Goto' },
    ['gz'] = { name = '+Surround' },
    [']'] = { name = '+Next' },
    ['['] = { name = '+Prev' },
  }
  wk.register(np)
end

M.setup_code = function()
  local _diagnostic_goto = function(next, severity)
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function() go({ severity = severity }) end
  end
  local _go_trouble = function(next)
    return function()
      if require('trouble').is_open() then
        local x = next == true and require('trouble').next or require('trouble').previous
        x({ skip_groups = true, jump = true })
      else
        local vimc = next == true and vim.cmd.cnext or vim.cmd.cprev
        vimc()
      end
    end
  end
  local _ref_map = function(key, dir)
    M.map(
      'n',
      key,
      function() require('illuminate')['goto_' .. dir .. '_reference'](false) end,
      { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference' }
    )
  end
  -- Core
  M.semicolon_to_colon()
  -- Better up/down
  M.map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
  M.map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
  -- Better move cursor
  M.map('n', '<c-j>', '15gj', 'Move Down 15 Lines')
  M.map('n', '<c-k>', '15gk', 'Move Up 15 Lines')
  -- Move to window using the <ctrl> hjkl keys
  M.map('n', '<c-h>', '<c-w>h', 'Jump Left')
  -- M.map('n', '<c-j>', '<c-w>j', 'Jump Down')
  -- M.map('n', '<c-k>', '<c-w>k', 'Jump Up')
  M.map('n', '<c-l>', '<c-w>l', 'Jump Right')
  -- Move to window using the movement keys
  -- M.map('n', '<left>', '<c-w>h', 'Jump Left')
  -- M.map('n', '<down>', '<c-w>j', 'Jump Down')
  -- M.map('n', '<up>', '<c-w>k', 'Jump Up')
  -- M.map('n', '<right>', '<c-w>l', 'Jump Right')
  M.map('n', '<left>', function() require('smart-splits').move_cursor_left() end, 'Jump Left')
  M.map('n', '<down>', function() require('smart-splits').move_cursor_down() end, 'Jump Down')
  M.map('n', '<up>', function() require('smart-splits').move_cursor_up() end, 'Jump Up')
  M.map('n', '<right>', function() require('smart-splits').move_cursor_right() end, 'Jump Right')
  -- Automatically expand width of the current window.
  M.map('n', '<c-w>z', M.cmd('WindowsMaximize'))
  M.map('n', '<c-w>_', M.cmd('WindowsMaximizeVertically'))
  M.map('n', '<c-w>|', M.cmd('WindowsMaximizeHorizontally'))
  M.map('n', '<c-w>=', M.cmd('WindowsEqualize'))
  -- Resize window using <ctrl> arrow keys
  -- M.map('n', '<c-up>', '<cmd>resize +2<cr>', 'Increase window height')
  -- M.map('n', '<c-down>', '<cmd>resize -2<cr>', 'Decrease window height')
  -- M.map('n', '<c-left>', '<cmd>vertical resize -2<cr>', 'Decrease window width')
  -- M.map('n', '<c-right>', '<cmd>vertical resize +2<cr>', 'Increase window width')
  M.map('n', '<c-left>', function() require('smart-splits').resize_left() end, 'Increase window width')
  M.map('n', '<c-right>', function() require('smart-splits').resize_right() end, 'Decrease window width')
  M.map('n', '<c-down>', function() require('smart-splits').resize_down() end, 'Increase window height')
  M.map('n', '<c-up>', function() require('smart-splits').resize_up() end, 'Decrease window height')
  -- Window Move
  M.map('n', '<s-left>', M.cmd('WinShift left'), 'Move Window To Left ')
  M.map('n', '<s-right>', M.cmd('WinShift right'), 'Move Window To Right')
  M.map('n', '<s-down>', M.cmd('WinShift down'), 'Move Window To Down')
  M.map('n', '<s-up>', M.cmd('WinShift up'), 'Move Window To Up')
  -- Wrap
  M.map('n', '<a-q>', '<cmd>ToggleWrap<cr>', 'Toggle Wrap')
  -- Better indenting
  M.map('v', '<', '<gv', 'deIndent Continuously')
  M.map('v', '>', '>gv', 'Indent Continuously')
  -- Add undo break-points
  -- M.map('i', '<tab>', ' <c-g>u')
  M.map('i', '<cr>', '<cr><c-g>u')
  M.map('i', ' ', ' <c-g>u')
  M.map('i', ':', ':<c-g>u')
  M.map('i', ',', ',<c-g>u')
  M.map('i', '.', '.<c-g>u')
  M.map('i', ';', ';<c-g>u')
  -- change word with <c-c>
  M.map('n', '<c-c>', '<cmd>normal! ciw<cr>a', 'Change Word')
  -- File
  -- M.map('n', '<c-q>', '<cmd>CloseView<cr>', 'Close')
  -- M.map('n', '<c-w>', '<cmd>BDelete this<cr>', 'Delete current buffer')
  -- M.map('n', '<c-n>', '<cmd>ene<cr>', 'New Text File')
  -- Alternative way to save and exit in Normal mode.
  -- NOTE: Adding `redraw` helps with `cmdheight=0` if buffer is not modified
  M.map('n', '<c-s>', '<cmd>silent! update | redraw<cr>', { desc = 'Save' })
  M.map({ 'i', 'x' }, '<c-s>', '<esc><cmd>silent! update | redraw<cr>', { desc = 'Save and go to Normal mode' })
  -- M.map({ 'i', 'v', 'n', 's' }, '<c-s>', '<cmd>w<cr><esc>', 'Save file')
  -- Edit
  M.map('n', 'S', 'diw"0P', 'Replace')
  M.map('n', '<a-c>', '<cmd>ToggleCaseSensitive<cr>')
  M.map('n', '<a-w>', '<cmd>ToggleWholeWord<cr>')
  -- M.map('n', '<c-c>', '<cmd>SearchCode<cr>')
  -- Comment
  M.map('n', '<c-/>', '<cmd>CommentLine<cr>')
  M.map('n', '<leader>cc', '<cmd>CommentLine<cr>', 'Comment Line (Comment.nvim)')
  M.map('x', '<leader>cc', '<cmd>CommentLine<cr>', 'Comment Line (Comment.nvim)')
  M.map('n', '<leader>cb', '<cmd>CommentBlock<cr>', 'Comment Block (Comment.nvim)')
  M.map('x', '<leader>cb', '<cmd>CommentBlock<cr>', 'Comment Block (Comment.nvim)')
  -- Selection/ Move Lines
  M.map('n', '<a-j>', '<cmd>MoveLine(1)<cr>', 'Line: Move Up (move.nvim)')
  M.map('n', '<a-k>', '<cmd>MoveLine(-1)<cr>', 'Line: Move Down (move.nvim)')
  M.map('n', '<a-h>', '<cmd>MoveHChar(-1)<cr>', 'Line: Move Left (move.nvim)')
  M.map('n', '<a-l>', '<cmd>MoveHChar(1)<cr>', 'Line: Move Right (move.nvim)')
  -- M.map('x', '<a-j>', '<cmd>MoveBlock(1)<cr>', 'Block: Move Up (move.nvim)')
  -- M.map('x', '<a-k>', '<cmd>MoveBlock(-1)<cr>', 'Block: Move Down (move.nvim)')
  -- M.map('x', '<a-h>', '<cmd>MoveHBlock(-1)<cr>', 'Block: Move Left (move.nvim)')
  -- M.map('x', '<a-l>', '<cmd>MoveHBlock(1)<cr>', 'Block: Move Right (move.nvim)')
  M.map('v', '<a-j>', ':MoveBlock(1)<cr>', 'Block: Move Up (move.nvim)')
  M.map('v', '<a-k>', ':MoveBlock(-1)<cr>', 'Block: Move Down (move.nvim)')
  M.map('v', '<a-h>', ':MoveHBlock(-1)<cr>', 'Block: Move Left (move.nvim)')
  M.map('v', '<a-l>', ':MoveHBlock(1)<cr>', 'Block: Move Right (move.nvim)')
  -- [ ] Move
  M.map('n', ']d', _diagnostic_goto(true), 'Next Diagnostic')
  M.map('n', '[d', _diagnostic_goto(false), 'Prev Diagnostic')
  M.map('n', ']e', _diagnostic_goto(true, 'ERROR'), 'Next Error')
  M.map('n', '[e', _diagnostic_goto(false, 'ERROR'), 'Prev Error')
  M.map('n', ']w', _diagnostic_goto(true, 'WARN'), 'Next Warning')
  M.map('n', '[w', _diagnostic_goto(false, 'WARN'), 'Prev Warning')
  M.map('n', ']b', '<cmd>BufferLineCycleNext<cr>', 'Next buffer')
  M.map('n', '[b', '<cmd>BufferLineCyclePrev<cr>', 'Previous buffer')
  M.map('n', ']q', _go_trouble(true), 'Next trouble/quickfix item')
  M.map('n', '[q', _go_trouble(false), 'Previous trouble/quickfix item')
  M.map('n', ']t', function() require('todo-comments').jump_next() end, 'Next todo comment')
  M.map('n', '[t', function() require('todo-comments').jump_prev() end, 'Previous todo comment')
  M.map('n', ']h', function() require('gitsigns').next_hunk() end, 'Next Hunk')
  M.map('n', '[h', function() require('gitsigns').prev_hunk() end, 'Prev Hunk')
  _ref_map(']r', 'next')
  _ref_map('[r', 'prev')
  M.map('n', ']a', '<cmd>AerialNext<cr>', 'Jump forwards symbols')
  M.map('n', '[a', '<cmd>AerialPrev<cr>', 'Jump backwards symbols')
  -- Yank
  M.map({ 'n', 'x' }, 'y', '<Plug>(YankyYank)')
  M.map({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)')
  M.map({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
  M.map({ 'n', 'x' }, 'gp', '<Plug>(YankyGPutAfter)')
  M.map({ 'n', 'x' }, 'gP', '<Plug>(YankyGPutBefore)')
  -- M.map('n', '<c-n>', '<Plug>(YankyCycleForward)')
  -- M.map('n', '<c-p>', '<Plug>(YankyCycleBackward)')
  M.map('n', ']p', '<Plug>(YankyPutIndentAfterLinewise)')
  M.map('n', '[p', '<Plug>(YankyPutIndentBeforeLinewise)')
  M.map('n', ']P', '<Plug>(YankyPutIndentAfterLinewise)')
  M.map('n', '[P', '<Plug>(YankyPutIndentBeforeLinewise)')
  M.map('n', '>p', '<Plug>(YankyPutIndentAfterShiftRight)')
  M.map('n', '<p', '<Plug>(YankyPutIndentAfterShiftLeft)')
  M.map('n', '>P', '<Plug>(YankyPutIndentBeforeShiftRight)')
  M.map('n', '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)')
  M.map('n', '=p', '<Plug>(YankyPutAfterFilter)')
  M.map('n', '=P', '<Plug>(YankyPutBeforeFilter)')
  M.map(
    'n',
    '<leader>P',
    function() require('telescope').extensions.yank_history.yank_history({}) end,
    { desc = 'Paste from Yanky' }
  )
  -- Reselect latest changed, put, or yanked text
  M.map('n', 'gV', '"`[" . strpart(getregtype(), 0, 1) . "`]"', { expr = true, desc = 'Visually select changed text' })
  -- Join
  M.map('n', 'J', '<cmd>TSJToggle<cr>', 'Join Toggle')
  -- Fold
  M.map('n', 'zR', function() require('ufo').openAllFolds() end)
  M.map('n', 'zM', function() require('ufo').closeAllFolds() end)
  M.map('n', 'zr', function() require('ufo').openFoldsExceptKinds() end)
  M.map('n', 'zm', function() require('ufo').closeFoldsWith() end) -- closeAllFolds == closeFoldsWith(0)
  -- Search
  -- Clear search with <esc>
  M.map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', 'Escape And Clear hlsearch')
  -- Search word under cursor
  M.map({ 'n', 'x' }, 'gw', '*N', 'Search word under cursor')
  -- Search visually selected text (slightly better than builtins in Neovim>=0.8)
  -- M.map('x', '*', [[y/\V<C-R>=escape(@", '/\')<CR><CR>]])
  -- M.map('x', '#', [[y?\V<C-R>=escape(@", '?\')<CR><CR>]])
  -- *-Improved by hlslens
  local function nN(char)
    local ok, winid = require('hlslens').nNPeekWithUFO(char)
    if ok and winid then
      -- Safe to override buffer scope keymaps remapped by ufo,
      -- ufo will restore previous buffer keymaps before closing preview window
      -- Type <cr> will switch to preview window and fire `trace` action
      M.map('n', '<cr>', function()
        local keyCodes = vim.api.nvim_replace_termcodes('<tab><cr>', true, false, true)
        vim.api.nvim_feedkeys(keyCodes, 'im', false)
      end, { buffer = true })
    end
  end
  M.map({ 'n', 'x' }, 'n', function() nN('n') end)
  M.map({ 'n', 'x' }, 'N', function() nN('N') end)
  -- M.map('n', 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]])
  -- M.map('n', 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]])
  -- M.map('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]])
  -- M.map('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]])
  -- M.map('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]])
  -- M.map('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]])
  -- *-Improved by hlslens with asterisk
  M.map('n', '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]])
  M.map('n', '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]])
  M.map('n', 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]])
  M.map('n', 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]])
  M.map('x', '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]])
  M.map('x', '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]])
  M.map('x', 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]])
  M.map('x', 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]])
  -- Scroll
  -- stylua: ignore start
  M.map({ 'i', 'n', 's' }, '<c-f>', function() if not require('noice.lsp').scroll(4) then return '<c-f>' end end, { expr = true, desc = 'Scroll forward' })
  M.map({ 'i', 'n', 's' }, '<c-b>', function() if not require('noice.lsp').scroll(-4) then return '<c-b>' end end, { expr = true, desc = 'Scroll backward' })
  -- stylua: ignore end
  -- View
  M.map('n', '<c-s-p>', '<cmd>Telescope commands<cr>', 'Command Palette... (telescope.nvim)')
  M.map('n', [[\]], '<cmd>Telescope commands<cr>', 'Command Palette... (telescope.nvim)')
  -- Tabs
  M.map('n', '<leader><tab>l', '<cmd>tablast<cr>', 'Last Tab')
  M.map('n', '<leader><tab>f', '<cmd>tabfirst<cr>', 'First Tab')
  M.map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', 'New Tab')
  M.map('n', '<leader><tab>]', '<cmd>tabnext<cr>', 'Next Tab')
  M.map('n', '<leader><tab>d', '<cmd>tabclose<cr>', 'Close Tab')
  M.map('n', '<leader><tab>[', '<cmd>tabprevious<cr>', 'Previous Tab')
  -- Buffer
  -- M.map('n', '<tab>', ':bnext<CR>', 'Next Buffer')
  -- M.map('n', '<s-tab>', ':bprevious<CR>', 'Previous Buffer')
  M.map('n', '<s-h>', '<cmd>BufferLineCyclePrev<cr>', 'Previous buffer')
  M.map('n', '<s-l>', '<cmd>BufferLineCycleNext<cr>', 'Next buffer')
  M.map('n', '<s-tab>', '<cmd>BufferLineCyclePrev<cr>', 'Previous buffer')
  M.map('n', '<tab>', '<cmd>BufferLineCycleNext<cr>', 'Next buffer')
  -- Go
  M.map(
    'n',
    '<c-p>',
    '<cmd>Telescope buffers show_all_buffers=true theme=get_dropdown previewer=false<cr>',
    'Go To File... (telescope.nvim)'
  )
  M.map('c', '<s-enter>', function() require('noice').redirect(vim.fn.getcmdline()) end, 'Redirect Cmdline')
  -- Run
  -- Debug
  if base.is_kernel() then
    M.map('n', '<f5>', '<cmd>DAP continue<cr>', 'Start Debug/Conitnue')
    M.map('n', '<f10>', '<cmd>DAP step_over<cr>', 'Step Over')
    M.map('n', '<f11>', '<cmd>DAP step_into<cr>', 'Step Into')
    M.map('n', '<f9>', '<cmd>DAP toggle_bp<cr>', 'Toggle Breakpoint')
  end

  -- Terminal
  M.map('n', [[<c-\>]], '<cmd>ToggleTerm<cr>', 'Toggle Terminal')
  -- M.map(
  --   'n',
  --   [[<c-\>]],
  --   function() vim.cmd('ToggleTerm dir=' .. require('base').get_contain_directory()) end,
  --   { desc = 'Toggle Terminal' }
  -- )
end

M._dap_varg = function(...)
  local function _get_front(...)
    local args = { ... }
    if vim.tbl_islist(args) and #args == 1 and type(args[1]) == 'table' then args = args[1] end
    local opts = {}
    for key, value in pairs(args) do
      opts[key] = value
    end
    return opts and opts[1] or ''
  end
  local action = _get_front(...)
  if action == 'continue' then
    _dap_continue()
  elseif action == 'step_over' then
    require('dap').step_over()
  elseif action == 'step_into' then
    require('dap').step_into()
  elseif action == 'step_out' then
    require('dap').step_out()
  elseif action == 'run_last' then
    require('dap').run_last()
  elseif action == 'run_to_cursor' then
    require('dap').run_to_cursor()
  elseif action == 'terminate' then
    require('dap').terminate()
  elseif action == 'toggle_bp' then
    -- vim.cmd([[PBToggleBreakpoint]])
    require('persistent-breakpoints.api').toggle_breakpoint()
  elseif action == 'toggle_ui' then
    require('dapui').toggle({})
  else
    base.warn('Unknown option')
  end
end

M.setup_comands = function()
  local _any_comment = function(wise)
    local mode = vim.api.nvim_get_mode().mode
    if mode:find('n') then
      wise.current()
    elseif mode:find('V') then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'nx', false)
      wise(vim.fn.visualmode())
    end
  end
  local _comment_line = function() _any_comment(require('Comment.api').toggle.linewise) end
  local _comment_block = function() _any_comment(require('Comment.api').toggle.blockwise) end
  local _close_view = function()
    if #vim.api.nvim_list_wins() == 1 then
      require('close_buffers').delete({ type = 'this' })
    else
      vim.api.nvim_win_close(0, true)
    end
  end
  local _toggle_wrap = function() base.toggle('wrap', false, { 'Wrap Hard', 'Not Wrap' }) end
  local _toggle_case_sensitive = function() base.toggle('ignorecase', false, { 'Ignore Case', 'Case Sensitive' }) end
  local _toggle_fullscreen = function() vim.g.neovide_fullscreen = vim.g.neovide_fullscreen == false end
  local _toggle_focus_mode = function() vim.opt.laststatus = vim.opt.laststatus._value == 0 and 3 or 0 end
  local _toggle_diagnostics = function()
    if vim.diagnostic.is_disabled() then
      vim.diagnostic.enable()
      base.info('Enabled diagnostics', { title = 'Diagnostics' })
    else
      vim.diagnostic.disable()
      base.warn('Disabled diagnostics', { title = 'Diagnostics' })
    end
  end
  local _remove_exclusive_orm = function()
    vim.cmd([[:%s/\r//g]])
    vim.cmd([[set ff=unix]])
  end
  local _insert_date = function()
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('i', true, true, true), 'n', true)
    -- vim.cmd([[i]])
    vim.cmd([[startinsert]])
    vim.api.nvim_feedkeys(os.date('%Y-%m-%d', os.time()) .. ' ', 'i', true)
  end
  local _insert_time = function()
    vim.cmd([[startinsert]])
    vim.api.nvim_feedkeys(os.date('%H:%M:%S', os.time()) .. ' ', 'i', true)
  end
  local _sublime_merge = function()
    require('plenary.job'):new({ command = 'sublime_merge', args = { '-n', vim.fn.getcwd() } }):sync()
  end
  local _sublime_text = function()
    require('plenary.job'):new({ command = 'sublime_text', args = { vim.fn.getcwd() } }):sync()
  end
  local _projects = function()
    require('project_nvim')
    local timer = vim.loop.new_timer()
    local picker = function()
      timer:stop()
      require('telescope').extensions.projects.projects()
    end
    timer:start(8, 0, vim.schedule_wrap(picker))
  end
  local _toggle_wholeword = function()
    base.g_toggle('wholeword', { 'Match Whole Word', 'Dont Care Whole Word', 'Search Option' })
  end
  local _search = function()
    local _has_wholeword = function() return vim.g.wholeword and vim.g.wholeword == true end
    local mww = _has_wholeword() and 'match whole word + ' or 'dont care whole word + '
    local mc = vim.opt.ignorecase:get() == false and 'match case' or 'ignore case'
    local prompt = 'Search (' .. mww .. mc .. ')'
    local input_opts = { prompt = prompt, completion = 'lsp' }
    vim.ui.input(input_opts, function(input)
      if not input then return end
      if vim.g.wholeword == true then
        vim.cmd('/\\<' .. input .. '\\>')
      else
        vim.cmd('/' .. input)
      end
    end)
  end
  local _format = function()
    if type(vim.bo.filetype) == 'string' and vim.bo.filetype:match('lua') then
      vim.cmd('FormatWriteLock')
    else
      vim.lsp.buf.format({ async = false })
    end
  end
  local _format_document = function()
    _format()
    -- vim.cmd([[confirm! set ff=unix]])
    -- vim.cmd([[set modifiable]])
    -- vim.cmd([[set ff=unix]])
    -- vim.cmd([[wa]])
  end
  local _toggle_autoformat = function()
    base.g_toggle('autoformat', { 'Auto format before saved', 'Dont auto format', 'Auto Format' })
  end
  -- stylua: ignore start
  M.command('ToggleFullScreen',     _toggle_fullscreen,      'Full Screen Toggle')
  M.command('ToggleWrap',           _toggle_wrap,            'Wrap Toggle')
  M.command('ToggleFocusMode',      _toggle_focus_mode,      'Focus Mode Toggle')
  M.command('ToggleCaseSensitive',  _toggle_case_sensitive,  'Case Sensitive Toggle')
  M.command('ToggleWholeWord',      _toggle_wholeword,       'Whole Word Toggle')
  M.command('ToggleDiagnostics',    _toggle_diagnostics,     'Diagnostics Toggle')
  M.command('ToggleAutoFormat',     _toggle_autoformat,      'Auto Format Toggle')
  M.command('RemoveExclusiveORM',   _remove_exclusive_orm,   'Remove Exclusive ORM')
  M.command('CommentLine',          _comment_line,           'Comment Line')
  M.command('CommentBlock',         _comment_block,          'Comment Block')
  M.command('InsertDate',           _insert_date,            'Insert Date')
  M.command('InsertTime',           _insert_time,            'Insert Time')
  M.command('SublimeMerge',         _sublime_merge,          'Sublime Merge')
  M.command('SublimeText',          _sublime_text,           'Sublime Text')
  M.command('Projects',             _projects,               'Projects')
  M.command('SearchCode',           _search,                 'Search Code')
  -- M.command('FormatCode',           _format,                 'Format Code')
  M.command('FormatDocument',       _format_document,        'Format Document')
  -- stylua: ignore end
  -- M.command('CloseView', _close_view, 'Close View')
  if base.is_kernel() then
    vim.cmd([[
    command! -nargs=* -complete=custom,s:complete DAP lua require'module.bindings'._dap_varg(<f-args>)
  ]])
  end
end

M.setup_autocmd = function()
  local _augroup = function(name) return vim.api.nvim_create_augroup('bindings_' .. name, { clear = true }) end
  -- Unfold all level on open file
  vim.api.nvim_create_autocmd('BufRead', {
    group = _augroup('unfold_open'),
    pattern = { '*.c', '*.cpp', '*.cc', '*.hpp', '*.h', '*.lua' },
    callback = function()
      vim.api.nvim_create_autocmd('BufWinEnter', {
        once = true,
        command = 'normal! zx',
      })
    end,
  })
  local _nofold = function() vim.cmd('set nofoldenable') end
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
    group = _augroup('nofoldenable'),
    callback = function() _nofold() end,
  })
  -- Close Neovim when all buffer closed
  vim.api.nvim_create_autocmd('BufEnter', {
    group = _augroup('NvimTreeClose'),
    pattern = 'NvimTree_*',
    callback = function()
      local layout = vim.api.nvim_call_function('winlayout', {})
      if
        layout[1] == 'leaf'
        and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), 'filetype') == 'NvimTree'
        and layout[3] == nil
      then
        vim.cmd('confirm quit')
      end
    end,
  })
  -- Create `User Next` event
  vim.api.nvim_create_autocmd('User', {
    pattern = 'NeXT',
    once = true,
    -- callback = function() vim.notify('NeXT', vim.log.levels.INFO) end,
    callback = function() end,
  })
  local _next = function()
    vim.schedule(function()
      if vim.v.exiting ~= vim.NIL then return end
      vim.api.nvim_exec_autocmds('User', { pattern = 'NeXT', modeline = false })
    end)
  end
  vim.api.nvim_create_autocmd('UIEnter', {
    once = true,
    callback = function() _next() end,
  })
  -- For ccls
  vim.api.nvim_create_autocmd('User', {
    pattern = 'ccls',
    once = true,
    -- callback = function() vim.notify('ccls', vim.log.levels.INFO) end,
    callback = function() end,
  })
  -- Check if we need to reload the file when it changed
  local chengd_event = { 'FocusGained', 'CursorHold', 'CursorHoldI', 'TermClose', 'TermLeave' }
  -- local chengd_event = { 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI', 'TermClose', 'TermLeave' }
  -- Bug: neo-minimap conficts 'BufEnter' checktime
  vim.api.nvim_create_autocmd(chengd_event, {
    group = _augroup('checktime'),
    pattern = '*',
    command = 'checktime',
  })
  -- Disable syntax for loog file
  local _disable_syntax = function() vim.cmd('if getfsize(@%) > 1000000 | setlocal syntax=OFF | endif') end
  vim.api.nvim_create_autocmd('Filetype', {
    group = _augroup('disable_syntax'),
    pattern = 'log',
    callback = function() _disable_syntax() end,
  })
  -- Terminal return program status
  vim.cmd([[:autocmd TermClose * execute 'bdelete! ' . expand('<abuf>')]])
  -- Close some filetypes with <q>
  vim.api.nvim_create_autocmd('FileType', {
    group = _augroup('close_with_q'),
    pattern = {
      'PlenaryTestPopup',
      'help',
      'lspinfo',
      'man',
      'notify',
      'qf',
      'spectre_panel',
      'startuptime',
      'tsplayground',
    },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      M.map('n', 'q', '<cmd>close<cr>', { buffer = event.buf })
    end,
  })
  -- Auto create dir when saving a file, in case some intermediate directory does not exist
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    group = _augroup('auto_create_dir'),
    callback = function(event)
      local file = vim.loop.fs_realpath(event.match) or event.match
      vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
    end,
  })
  -- Highlight on yank
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = _augroup('highlight_yank'),
    callback = function() vim.highlight.on_yank() end,
  })
  -- Auto toggle status and tablines for alpha
  -- vim.cmd([[autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2]])
  vim.api.nvim_create_autocmd('User', {
    group = _augroup('showtabline'),
    pattern = 'AlphaReady',
    callback = function()
      local prev_showtabline = vim.opt.showtabline
      local prev_status = vim.opt.laststatus
      vim.opt.laststatus = 0
      vim.opt.showtabline = 0
      vim.opt_local.winbar = nil
      vim.api.nvim_create_autocmd('BufUnload', {
        pattern = '<buffer>',
        callback = function()
          vim.opt.laststatus = prev_status
          vim.opt.showtabline = prev_showtabline
        end,
      })
    end,
  })
  -- Auto format before write
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    group = _augroup('autoformat'),
    callback = function(event)
      if vim.g.autoformat == true then vim.cmd([[FormatCode]]) end
    end,
  })
  -- Show cursor line only in active window
  vim.api.nvim_create_autocmd({ 'InsertLeave', 'WinEnter' }, {
    callback = function()
      local ok, cl = pcall(vim.api.nvim_win_get_var, 0, 'auto-cursorline')
      if ok and cl then
        vim.wo.cursorline = true
        vim.api.nvim_win_del_var(0, 'auto-cursorline')
      end
    end,
  })
  vim.api.nvim_create_autocmd({ 'InsertEnter', 'WinLeave' }, {
    callback = function()
      local cl = vim.wo.cursorline
      if cl then
        vim.api.nvim_win_set_var(0, 'auto-cursorline', cl)
        vim.wo.cursorline = false
      end
    end,
  })
  vim.api.nvim_create_autocmd('User', {
    pattern = 'HijackDirectories',
    once = true,
    callback = function() end,
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = _augroup('hijack_directories'),
    pattern = '*',
    callback = function(args)
      local info = vim.loop.fs_stat(args.file)
      if info and info.type == 'directory' then
        vim.cmd('Neotree position=current ' .. args.file)
        -- vim.cmd('NvimTreeOpen ' .. args.file)
        -- require('nvim-tree.api').tree.open({ path = args.file })
        vim.api.nvim_exec_autocmds('User', { pattern = 'HijackDirectories', modeline = false })
      end
    end,
    desc = 'Hijack Directories',
  })
  -- auto show hydra on nvimtree focus
  local _show_hydra_on_nvimtree_focus = function()
    local _change_root_to_global_cwd = function()
      local api = require('nvim-tree.api')
      local global_cwd = vim.fn.getcwd()
      -- local global_cwd = vim.fn.getcwd(-1, -1)
      api.tree.change_root(global_cwd)
    end
    local hint = [[
   _w_: cd CWD  _c_: Path yank  _/_: Filter
   _y_: Copy    _x_: Cut        _p_: Paste
   _r_: Rename  _d_: Remove     _n_: New
   _h_: Hidden  _?_: Help
   ^
    ]]
    -- ^ ^           _q_: exit
    local nvim_tree_hydra = nil
    local Hydra = require('hydra')
    local _spawn_nvim_tree_hydra = function()
      local api = require('nvim-tree.api')
      nvim_tree_hydra = Hydra({
        name = 'NvimTree',
        hint = hint,
        config = {
          color = 'pink',
          invoke_on_body = true,
          buffer = 0, -- only for active buffer
          hint = {
            position = 'bottom',
            border = 'rounded',
          },
        },
        mode = 'n',
        body = 'H',
        heads = {
          { 'w', _change_root_to_global_cwd, { silent = true } },
          { 'c', api.fs.copy.absolute_path, { silent = true } },
          { '/', api.live_filter.start, { silent = true } },
          { 'y', api.fs.copy.node, { silent = true } },
          { 'x', api.fs.cut, { exit = true, silent = true } },
          { 'p', api.fs.paste, { exit = true, silent = true } },
          { 'r', api.fs.rename, { silent = true } },
          { 'd', api.fs.remove, { silent = true } },
          { 'n', api.fs.create, { silent = true } },
          { 'h', api.tree.toggle_hidden_filter, { silent = true } },
          { '?', api.tree.toggle_help, { silent = true } },
          -- { "q", nil, { exit = true, nowait = true } },
        },
      })
      nvim_tree_hydra:activate()
    end
    vim.api.nvim_create_autocmd({ 'BufEnter' }, {
      pattern = '*',
      callback = function(opts)
        if vim.bo[opts.buf].filetype == 'NvimTree' then
          _spawn_nvim_tree_hydra()
        else
          if nvim_tree_hydra then nvim_tree_hydra:exit() end
        end
      end,
      group = _augroup('NvimTreeHydraAu'),
    })
  end
  _show_hydra_on_nvimtree_focus()
end

return M
