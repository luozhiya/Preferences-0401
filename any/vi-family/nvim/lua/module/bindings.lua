local base = require('base')
local M = {}

M.map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

M.setup_leader = function()
  vim.g.mapleader = ','
  vim.g.maplocalleader = ','
end

M.semicolon_to_colon = function() M.map('n', ';', ':', { silent = false }) end

M.lsp = {
  { 'gD', vim.lsp.buf.definition, desc = 'Goto Definition' },
  { 'gd', '<cmd>Glance definitions<cr>', desc = 'Goto Definition' },
  { 'gh', vim.lsp.buf.hover, desc = 'Hover' },
  { 'K', vim.lsp.buf.hover, desc = 'Hover' },
  { 'gn', vim.lsp.buf.rename, desc = 'Rename' },
  { 'ga', vim.lsp.buf.code_action, desc = 'Code Action' },
  { '[d', vim.diagnostic.goto_prev, desc = 'Goto Diagnostic Prev' },
  { ']d', vim.diagnostic.goto_next, desc = 'Goto Diagnostic Next' },
}

M.alpha_val = function(button)
  local icons = require('module.options').icons.collects
  -- stylua: ignore
  return {
    button('f', icons.Search ..         ' Find file', ':Telescope find_files <cr>'),
    button('n', icons.File ..           ' New file', ':ene <bar> startinsert <cr>'),
    button('r', icons.Connectdevelop .. ' Recent files', ':Telescope oldfiles <cr>'), --    -- 
    button('p', icons.Chrome ..         ' Projects', ':Projects <cr>'),
    button('g', icons.ListAlt ..        ' Find text', ':Telescope live_grep <cr>'),
    button('c', icons.Cogs ..           ' Config', ':e $MYVIMRC <cr>'), --    -- 
    button('s', icons.IE ..             ' Restore Session', [[:lua require("persistence").load() <cr>]]),
    button('l', icons.Firefox ..        ' Lazy', ':Lazy<cr>'),
    button('q', icons.Modx ..           ' Quit', ':qa<cr>'), -- 
  }
end

M.cmp = function(cmp)
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
  -- stylua: ignore start
  return { defaults = { mappings = { i = {
          ['<esc>'] = actions.close,
        }, }, }, }
  -- stylua: ignore end
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
          telescope.find_files(
            get_telescope_opts(path, function(name, state) fs.navigate(state, state.path, name) end, state)
          )
        end,
        telescope_grep = function(state)
          local path = state.tree:get_node():get_id()
          telescope.live_grep(
            get_telescope_opts(path, function(name, state) fs.navigate(state, state.path, name) end, state)
          )
        end,
      },
    },
  }
end

M.wk = function(wk)
  function _any_toggle(cmd)
    local run = require('toggleterm.terminal').Terminal:new({
      cmd = cmd,
      dir = 'git_dir',
      direction = 'float',
      float_opts = { border = 'double' },
      on_open = function(term)
        vim.cmd('startinsert!')
        M.map('n', 'q', '<cmd>close<cr>', { noremap = true, silent = true, buffer = term.bufnr })
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
  local _dap_continue = function()
    local dap = require('dap')
    if dap.session() then
      dap.continue()
    else
      local prompt = 'Path to executable '
      local default = vim.fn.getcwd() .. '/'
      local input_opts = { prompt = prompt, default = default, 'file', completion = 'file' }
      vim.ui.input(input_opts, function(input)
        if not input then return end
        local cpp = {
          program = function() return input end,
        }
        dap.configurations.cpp = vim.tbl_deep_extend('force', dap.configurations.cpp, cpp)
        dap.configurations.c = dap.configurations.cpp
        dap.continue()
      end)
    end
  end
  local _format = function()
    if type(vim.bo.filetype) == 'string' and vim.bo.filetype:match('cpp') then
      vim.lsp.buf.format({ async = false })
    else
      vim.cmd('FormatWriteLock')
    end
    vim.cmd([[set ff=unix]])
  end
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
  -- stylua: ignore start
  local wk_ve = {
      name = 'Edit Config',
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
    q = {
      name = 'Quit',
      q = { '<cmd>qa<cr>', 'Quit All' },
      w = { '<cmd>wqall<cr>', 'Quit And Save Everything' },
      f = { '<cmd>q!<cr>', 'Quit Force' },
      F = { '<cmd>qa!<cr>', 'Quit All Force' },
      s = { '<cmd>w<cr>', 'Save' },
    },
    s = {
      name = 'Session',
      s = { '<cmd>SessionManager save_current_session<cr>', 'Save Current Session' },
      l = { '<cmd>SessionManager load_session<cr>', 'Select And Load Session.' },
      r = { '<cmd>SessionManager load_last_session<cr>', 'Restore Session' },
      -- S = { '<cmd>Obsession ~/session.vim<cr>', 'Save Session' },
      -- R = { '<cmd>Obsession ~/session.vim<cr>:!start neovide -- -S ~/session.vim<cr><cr>:wqall<cr>', 'Quit And Reload' },
      a = { '<cmd>lua require("persistence").load()<cr>', 'Restore AutoSaved Session (persistence.nvim)' },
    },
    c = {
      name = 'C++',
      a = { '<cmd>ClangAST<cr>', 'Clang AST' },
      t = { '<cmd>ClangdTypeHierarchy<cr>', 'Clang Type Hierarchy' },
      h = { '<cmd>ClangdSwitchSourceHeader<cr>', 'Switch C/C++ Header/Source' },
      m = { '<cmd>ClangdMemoryUsage<cr>', 'Clangd Memory Usage' },
      d = { function() require('cppdoc').open() end, 'Search cppreference Local' },
    },
    w = {
      name = 'Windows',
      h = { '<C-w>h', 'Jump Left' },
      j = { '<C-w>j', 'Jump Down' },
      k = { '<C-w>k', 'Jump Up' },
      l = { '<C-w>l', 'Jump Right' },
      e = { '<cmd>vsplit<cr><esc>', 'Split Left' },
      d = { '<cmd>split<cr><C-w>j<esc>', 'Split Down' },
      u = { '<cmd>split<cr><esc>', 'Split Up' },
      r = { '<cmd>vsplit<cr><C-w>l<esc>', 'Split Right' },
    },
    b = {
      name = 'Buffer',
      f = { '<cmd>FlyBuf<cr>', 'Fly Buffer' },
      p = { '<Cmd>BufferLineTogglePin<CR>', 'Toggle pin' },
      o = { '<Cmd>BufferLineGroupClose ungrouped<CR>', 'Delete non-pinned buffers, Only pinned' },
    },
    v = {
      name = 'Vim',
      i = { '<cmd>Lazy<cr>', 'Lazy Dashboard' },
      p = { '<cmd>Lazy profile<cr>', 'Lazy Profile' },
      u = { '<cmd>Lazy update<cr>', 'Lazy Update' },
      c = { '<cmd>Lazy clean<cr>', 'Lazy Clean' },
      -- n = { '<cmd>Telescope notify<cr>', 'Notification History' },
      n = { _notify_history, 'Notification History' },
      d = { _purge_notify, 'Delete all Notifications' },
      s = { '<cmd>lua vim.show_pos<cr>', 'Inspect Pos' },
      l = { '<cmd>lopen<cr>', 'Location List' },
      q = { '<cmd>copen<cr>', 'Quickfix List' },
      e = wk_ve,
    },
    l = {
      name = 'LSP',
      i = { '<cmd>LspInfo<cr>', 'Info' },
      -- l = { '<cmd>Lspsaga show_line_diagnostics<cr>', 'Lspsaga Show Line Diagnostics' },
      a = { '<cmd>AerialToggle<cr>', 'Aerial OutlineToggle (aerial.nvim)' },
      f = { _format, 'Code Format' },
      x = { '<cmd>TroubleToggle<cr>', 'Trouble Toggle' },
      o = { '<cmd>SymbolsOutline<cr>', 'Symbols Outline Toggle (symbols-outline.nvim)' },
      w = { '<cmd>TroubleToggle workspace_diagnostics<cr>', 'Trouble Workspace Diagnostics' },
      d = { '<cmd>TroubleToggle document_diagnostics<cr>', 'Trouble Document Diagnostics' },
      D = { '<cmd>Telescope diagnostics bufnr=0<cr>', 'Document Diagnostics' },
      q = { '<cmd>TroubleToggle quickfix<cr>', 'Trouble Quickfix' },
      L = { '<cmd>TroubleToggle loclist<cr>', 'Trouble Loclist' },
      r = { '<cmd>TroubleToggle lsp_references<cr>', 'Trouble LSP References' },
      s = { '<cmd>Telescope lsp_document_symbols<cr>', 'Document Symbols' },
      S = { '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', 'Workspace Symbols' },
      -- n = { _rename, 'Incremental LSP renaming (inc-rename.nvim)' },
      n = { ':IncRename ', 'Incremental LSP renaming (inc-rename.nvim)' },
      c = { function() require('refactoring').select_refactor() end, 'Refactoring' },
    },
    d = {
      name = 'Debug',
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
      r = { function() require('dap').run_last() end, 'Run last' },
      l = { function() require('dap').run_to_cursor() end, 'Run To Cursor' },
      x = { function() require('dap').terminate() end, 'Terminate' },
      u = { function() require('dapui').toggle({}) end, 'Dap UI' },
    },
    t = {
      name = 'Run In Command Terminal',
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
      name = 'Edit',
      f = { '<cmd>ToggleFocusMode<cr>', 'Toggle Focus Mode' },
      t = { '<cmd>Twilight<cr>', 'Toggle Twilight' },
      o = { '<cmd>BWipeout other<cr>', 'Only Current Buffer' },
      w = { '<cmd>ToggleWrap<cr>', 'Toggle Wrap' },
      s = { '<cmd>ToggleCaseSensitive<cr>', 'Toggle Case Sensitive' },
      m = { '<cmd>SublimeMerge<cr>', 'Sublime Merge' },
      s = { '<cmd>SublimeText<cr>', 'Sublime Text' },
      c = {
        name = 'Copy Information',
        c = { _copy_content, 'Copy Content' },
        n = { _copy_name, 'Copy File Name' },
        e = { _copy_name_without_ext, 'Copy File Name Without Ext' },
        d = { _copy_contain_directory, 'Copy Contain Directory' },
        p = { _copy_path, 'Copy Path' },
        r = { _copy_relative_path, 'Copy Relative Path' },
      },
      e = {
        name = 'Ending',
        l = { '<cmd>RemoveExclusiveORM<cr>', 'ORM Ending' },
        u = { '<cmd>set ff=unix<cr>', 'Unix Ending' },
        w = { '<cmd>set ff=dos<cr>', 'Windows Ending' },
        m = { '<cmd>set ff=mac<cr>', 'Mac Ending' },
      },
    },
    f = {
      name = 'File Explorer',
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
      o = { '<cmd>Telescope oldfiles<cr>', 'Frecency Files' },
      u = { '<cmd>Telescope undo bufnr=0<cr>', 'Undo Tree' },
      r = { '<cmd>Telescope repo list<cr>', 'Repo list' },
      a = { _open_with_default_app, 'Open With Default APP' },
      x = { _reveal_file_in_file_explorer, 'Reveal In File Explorer' },
    },
  }
  wk.register(n, { mode = 'n', prefix = '<leader>' })
end

M.nvim_tree = function()
  local _on_attach = function(bufnr)
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
    local _path = function()
      local node = require('nvim-tree.lib').get_node_at_cursor()
      if node == nil then return end
      local is_folder = node.fs_stat and node.fs_stat.type == 'directory' or false
      local basedir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ':h')
      if node.name == '..' and TreeExplorer ~= nil then basedir = TreeExplorer.cwd end
      return basedir
    end
    local telescope = require('telescope.builtin')
    local fs = require('nvim-tree.actions.node.open-file')
    local _opts = function(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    vim.keymap.set('n', '<c-f>', function()
      telescope.find_files(_ts_opts(_path(), function(name) fs.fn('preview', name) end))
    end, _opts('Find'))
    vim.keymap.set('n', '<c-g>', function()
      telescope.live_grep(_ts_opts(_path(), function(name) fs.fn('preview', name) end))
    end, _opts('Grep'))
  end
  return {
    on_attach = _on_attach,
  }
end

M.setup_code = function()
  -- Core
  M.semicolon_to_colon()
  -- Better up/down
  M.map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, noremap = true })
  M.map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, noremap = true })
  -- Better move cursor
  M.map('n', '<c-j>', '15gj', { noremap = true, desc = 'Move Down 15 Lines' })
  M.map('n', '<c-k>', '15gk', { noremap = true, desc = 'Move Up 15 Lines' })
  -- Move to window using the <ctrl> hjkl keys
  M.map('n', '<c-h>', '<c-w>h', { desc = 'Jump Left' })
  -- M.map('n', '<c-j>', '<c-w>j', { desc = 'Jump Down' })
  -- M.map('n', '<c-k>', '<c-w>k', { desc = 'Jump Up' })
  M.map('n', '<c-l>', '<c-w>l', { desc = 'Jump Right' })
  -- Resize window using <ctrl> arrow keys
  M.map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase window height' })
  M.map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease window height' })
  M.map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease window width' })
  M.map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase window width' })
  M.map('n', '<a-q>', '<cmd>ToggleWrap<cr>', { desc = 'Toggle Wrap' })
  -- Better indenting
  M.map('v', '<', '<gv', { noremap = true, desc = 'deIndent Continuously' })
  M.map('v', '>', '>gv', { noremap = true, desc = 'Indent Continuously' })
  -- Add undo break-points
  M.map('i', ',', ',<c-g>u')
  M.map('i', '.', '.<c-g>u')
  M.map('i', ';', ';<c-g>u')
  -- File
  -- M.map('n', '<c-q>', '<cmd>CloseView<cr>', { desc = 'Close' })
  M.map('n', '<c-w>', '<cmd>BDelete this<cr>', { desc = 'Delete current buffer' })
  M.map('n', '<c-n>', '<cmd>ene<cr>', { desc = 'New Text File' })
  M.map({ 'i', 'v', 'n', 's' }, '<c-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })
  -- Edit
  M.map('n', 'S', 'diw"0P', { desc = 'Replace' })
  M.map('n', '<a-c>', '<cmd>ToggleCaseSensitive<cr>')
  M.map('n', '<a-w>', '<cmd>ToggleWholeWord<cr>')
  M.map('n', '<c-f>', '<cmd>SearchCode<cr>')
  -- Comment
  M.map('n', '<c-/>', '<cmd>CommentLine<cr>')
  M.map('n', '<leader>cc', '<cmd>CommentLine<cr>', { desc = 'Comment Line (Comment.nvim)' })
  M.map('x', '<leader>cc', '<cmd>CommentLine<cr>', { desc = 'Comment Line (Comment.nvim)' })
  M.map('n', '<leader>cb', '<cmd>CommentBlock<cr>', { desc = 'Comment Block (Comment.nvim)' })
  M.map('x', '<leader>cb', '<cmd>CommentBlock<cr>', { desc = 'Comment Block (Comment.nvim)' })
  -- Selection/ Move Lines
  M.map('n', '<a-j>', '<cmd>MoveLine(1)<cr>', { noremap = true, desc = 'Line: Move Up (move.nvim)' })
  M.map('n', '<a-k>', '<cmd>MoveLine(-1)<cr>', { noremap = true, desc = 'Line: Move Down (move.nvim)' })
  M.map('n', '<a-h>', '<cmd>MoveHChar(-1)<cr>', { noremap = true, desc = 'Line: Move Left (move.nvim)' })
  M.map('n', '<a-l>', '<cmd>MoveHChar(1)<cr>', { noremap = true, desc = 'Line: Move Right (move.nvim)' })
  M.map('v', '<a-j>', '<cmd>MoveBlock(1)<cr>', { noremap = true, desc = 'Block: Move Up (move.nvim)' })
  M.map('v', '<a-k>', '<cmd>MoveBlock(-1)<cr>', { noremap = true, desc = 'Block: Move Down (move.nvim)' })
  M.map('v', '<a-h>', '<cmd>MoveHBlock(-1)<cr>', { noremap = true, desc = 'Block: Move Left (move.nvim)' })
  M.map('v', '<a-l>', '<cmd>MoveHBlock(1)<cr>', { noremap = true, desc = 'Block: Move Right (move.nvim)' })
  -- Search
  M.map({ 'n', 'x' }, 'gw', '*N', { desc = 'Search word under cursor' })
  -- Clear search with <esc>
  M.map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { noremap = true, desc = 'Escape And Clear hlsearch' })
  -- View
  M.map('n', '<c-s-p>', '<cmd>Telescope commands<cr>', { noremap = true, desc = 'Command Palette... (telescope.nvim)' })
  M.map('n', [[\]], '<cmd>Telescope commands<cr>', { noremap = true, desc = 'Command Palette... (telescope.nvim)' })
  -- Tabs
  M.map('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = 'Last Tab' })
  M.map('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = 'First Tab' })
  M.map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New Tab' })
  M.map('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
  M.map('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })
  M.map('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })
  -- Buffer
  -- M.map('n', '<tab>', ':bnext<CR>', { desc = 'Next Buffer' })
  -- M.map('n', '<s-tab>', ':bprevious<CR>', { desc = 'Previous Buffer' })
  M.map('n', '<s-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })
  M.map('n', '<s-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
  M.map('n', '[b', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })
  M.map('n', ']b', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
  M.map('n', '<s-tab>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })
  M.map('n', '<tab>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
  -- Go
  M.map(
    'n',
    '<c-p>',
    '<cmd>Telescope buffers show_all_buffers=true theme=get_dropdown previewer=false<cr>',
    { noremap = true, desc = 'Go To File... (telescope.nvim)' }
  )
  -- Run
  -- Terminal
  M.map('n', [[<c-\>]], '<cmd>ToggleTerm<cr>', { desc = 'Toggle Terminal' })
  -- M.map(
  --   'n',
  --   [[<c-\>]],
  --   function() vim.cmd('ToggleTerm dir=' .. require('base').get_contain_directory()) end,
  --   { desc = 'Toggle Terminal' }
  -- )
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
    -- vim.cmd([[:%s/\r//g]])
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
    if vim.g.wholeword == nil then vim.g.wholeword = false end
    vim.g.wholeword = not vim.g.wholeword
    if vim.g.wholeword == true then
      base.info('Match Whole Word', { title = 'Search Option' })
    else
      base.info('Dont Care Whole Word', { title = 'Search Option' })
    end
  end
  local _search = function()
    local _has_wholeword = function() return vim.g.wholeword and vim.g.wholeword == true end
    local mww = _has_wholeword() and 'match whole word + ' or 'dont case whole word + '
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
  vim.api.nvim_create_user_command('ToggleFullScreen', _toggle_fullscreen, { desc = 'Toggle Full Screen' })
  vim.api.nvim_create_user_command('ToggleWrap', _toggle_wrap, { desc = 'Toggle Wrap' })
  vim.api.nvim_create_user_command('ToggleFocusMode', _toggle_focus_mode, { desc = 'Toggle Focus Mode' })
  vim.api.nvim_create_user_command('ToggleCaseSensitive', _toggle_case_sensitive, { desc = 'Toggle Case Sensitive' })
  vim.api.nvim_create_user_command('ToggleWholeWord', _toggle_wholeword, { desc = 'Whole Word Toggle' })
  vim.api.nvim_create_user_command('ToggleDiagnostics', _toggle_diagnostics, { desc = 'Toggle Diagnostics' })
  vim.api.nvim_create_user_command('RemoveExclusiveORM', _remove_exclusive_orm, { desc = 'Remove Exclusive ORM' })
  -- vim.api.nvim_create_user_command('CloseView', _close_view, { desc = 'Close View' })
  vim.api.nvim_create_user_command('CommentLine', _comment_line, { desc = 'Comment Line' })
  vim.api.nvim_create_user_command('CommentBlock', _comment_block, { desc = 'Comment Block' })
  vim.api.nvim_create_user_command('InsertDate', _insert_date, { desc = 'Insert Date' })
  vim.api.nvim_create_user_command('InsertTime', _insert_time, { desc = 'Insert Time' })
  vim.api.nvim_create_user_command('SublimeMerge', _sublime_merge, { desc = 'Sublime Merge' })
  vim.api.nvim_create_user_command('SublimeText', _sublime_text, { desc = 'Sublime Text' })
  vim.api.nvim_create_user_command('Projects', _projects, { desc = 'Projects' })
  vim.api.nvim_create_user_command('SearchCode', _search, { desc = 'Search Code' })
end

M.setup_autocmd = function()
  local function augroup(name) return vim.api.nvim_create_augroup('bindings_' .. name, { clear = true }) end
  -- Unfold all level on open file
  vim.api.nvim_create_autocmd('BufRead', {
    group = augroup('unfold_open'),
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
    callback = function() _nofold() end,
  })
  -- Close Neovim when all buffer closed
  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup('NvimTreeClose'),
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
  vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI', 'TermClose', 'TermLeave' }, {
    group = augroup('checktime'),
    pattern = '*',
    command = 'checktime',
  })
  -- Disable syntax for loog file
  local _disable_syntax = function() vim.cmd('if getfsize(@%) > 1000000 | setlocal syntax=OFF | endif') end
  vim.api.nvim_create_autocmd('Filetype', {
    group = augroup('disable_syntax'),
    pattern = 'log',
    callback = function() _disable_syntax() end,
  })
  -- Terminal return program status
  vim.cmd([[:autocmd TermClose * execute 'bdelete! ' . expand('<abuf>')]])
  -- Close some filetypes with <q>
  vim.api.nvim_create_autocmd('FileType', {
    group = augroup('close_with_q'),
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
      vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
    end,
  })
  -- Auto create dir when saving a file, in case some intermediate directory does not exist
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    group = augroup('auto_create_dir'),
    callback = function(event)
      local file = vim.loop.fs_realpath(event.match) or event.match
      vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
    end,
  })
  -- Highlight on yank
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup('highlight_yank'),
    callback = function() vim.highlight.on_yank() end,
  })
end

return M
