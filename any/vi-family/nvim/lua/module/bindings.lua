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

M.cmp = function(cmp)
  local forward = function()
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
  local backward = function()
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
      ['<cr>'] = cmp.mapping.confirm({ select = true }),
      ['<c-space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<tab>'] = forward(),
      ['<s-tab>'] = backward(),
      ['<c-y>'] = cmp.mapping.confirm({ select = false }),
      ['<c-e>'] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
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
      local input_opts =
        { prompt = 'Path to executable ', default = vim.fn.getcwd() .. '/', 'file', completion = 'file' }
      vim.ui.input(input_opts, function(input)
        if not input then return end
        dap.configurations.cpp = {
          {
            name = 'Launch',
            type = 'lldb',
            request = 'launch',
            program = function() return input end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            args = {},
          },
        }
        dap.configurations.c = dap.configurations.cpp
        dap.continue()
      end)
    end
  end
  local _format = function()
    if type(vim.bo.filetype) == 'string' and vim.bo.filetype:match('cpp') then
      vim.lsp.buf.format({ async = true })
    else
      vim.cmd('FormatWriteLock')
    end
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
  -- stylua: ignore start
  local wk_ve = function()
    return {
      name = 'Edit Config',
      i = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/init.lua') end,                'init.lua (bootstrap)' },
      b = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/base.lua') end,            'base.lua' },
      k = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/module/bindings.lua') end, 'bindings.lua' },
      l = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/module/lsp.lua') end,      'lsp.lua' },
      o = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/module/options.lua') end,  'options.lua' },
      p = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/module/plugins.lua') end,  'plugins.lua' },
      s = { function() vim.cmd('e ' .. vim.fn.stdpath('config') .. '/lua/module/settings.lua') end, 'settings.lua' },
    }
  end
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
      y = { '<cmd>vsplit<cr><esc>', 'Split Left' },
      u = { '<cmd>split<cr><C-w>j<esc>', 'Split Down' },
      i = { '<cmd>split<cr><esc>', 'Split Up' },
      o = { '<cmd>vsplit<cr><C-w>l<esc>', 'Split Right' },
    },
    b = {
      name = 'Buffer',
      f = { '<cmd>FlyBuf<cr>', 'Fly Buffer' },
    },
    v = {
      name = 'Vim',
      i = { '<cmd>Lazy<cr>', 'Lazy Dashboard' },
      p = { '<cmd>Lazy profile<cr>', 'Lazy Profile' },
      u = { '<cmd>Lazy update<cr>', 'Lazy Update' },
      c = { '<cmd>Lazy clean<cr>', 'Lazy Clean' },
      e = wk_ve(),
    },
    l = {
      name = 'LSP',
      i = { '<cmd>LspInfo<cr>', 'Info' },
      l = { '<cmd>Lspsaga show_line_diagnostics<cr>', 'Lspsaga Show Line Diagnostics' },
      o = { '<cmd>AerialToggle<cr>', 'Outline' },
      f = { function() _format() end, 'Code Format' },
      x = { '<cmd>TroubleToggle<cr>', 'Trouble Toggle' },
      w = { '<cmd>TroubleToggle workspace_diagnostics<cr>', 'Trouble Workspace Diagnostics' },
      d = { '<cmd>TroubleToggle document_diagnostics<cr>', 'Trouble Document Diagnostics' },
      D = { '<cmd>Telescope diagnostics bufnr=0<cr>', 'Document Diagnostics' },
      q = { '<cmd>TroubleToggle quickfix<cr>', 'Trouble Quickfix' },
      L = { '<cmd>TroubleToggle loclist<cr>', 'Trouble Loclist' },
      r = { '<cmd>TroubleToggle lsp_references<cr>', 'Trouble LSP References' },
      s = { '<cmd>Telescope lsp_document_symbols<cr>', 'Document Symbols' },
      S = { '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', 'Workspace Symbols' },
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
      c = { function() _dap_continue() end, 'Continue' },
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
      f = { '<cmd>ToggleFocusMode<cr>', 'Focus Mode' },
      o = { '<cmd>BWipeout other<cr>', 'Only Current Buffer' },
      w = { '<cmd>ToggleWrap<cr>', 'Toggle Wrap' },
      s = { '<cmd>ToggleCaseSensitive<cr>', 'Toggle Case Sensitive' },
      m = { '<cmd>SublimeMerge<cr>', 'Sublime Merge' },
      s = { '<cmd>SublimeText<cr>', 'Sublime Text' },
      c = {
        name = 'Copy Information',
        c = { function() _copy_content() end, 'Copy Content' },
        n = { function() _copy_name() end, 'Copy File Name' },
        e = { function() _copy_name_without_ext() end, 'Copy File Name Without Ext' },
        d = { function() _copy_contain_directory() end, 'Copy Contain Directory' },
        p = { function() _copy_path() end, 'Copy Path' },
        r = { function() _copy_relative_path() end, 'Copy Relative Path' },
      },
    },
    f = {
      name = 'File Explorer',
      n = { function() vim.cmd('NnnPicker ' .. require('base').get_contain_directory()) end, 'nnn Explorer' },
      e = { '<cmd>NvimTreeFindFile<cr>', 'NvimTree Explorer' },
      d = { '<cmd>Neotree<cr>', 'Neotree Explorer' },
      t = { '<cmd>NvimTreeToggle<cr>', 'Toggle Tree Explorer' },
      v = { '<cmd>VFiler<cr>', 'VFiler File explorer' },
      s = { '<cmd>Telescope find_files theme=get_dropdown previewer=false<cr>', 'Find files' },
      l = { '<cmd>Telescope live_grep_args<cr>', 'Find Text Args' },
      -- p = { '<cmd>Telescope projects<cr>', 'Projects' },
      p = { function() _projects() end, 'Projects' },
      f = { '<cmd>Telescope oldfiles<cr>', 'Frecency Files' },
      u = { '<cmd>Telescope undo bufnr=0<cr>', 'Undo Tree' },
      o = { function() _open_with_default_app() end, 'Open With Default APP' },
      r = { function() _reveal_file_in_file_explorer() end, 'Reveal In File Explorer' },
    },
  }
  wk.register(n, { mode = 'n', prefix = '<leader>' })
end

M.nvim_tree = function()
  local ts_opts = function(path, tree, any)
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
          tree(filename, any)
        end)
        return true
      end,
    }
  end
  local telescope = require('telescope.builtin')
  local fs = require('nvim-tree.actions.node.open-file')
  local path = function()
    local node = require('nvim-tree.lib').get_node_at_cursor()
    if node == nil then return end
    local is_folder = node.fs_stat and node.fs_stat.type == 'directory' or false
    local basedir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ':h')
    if node.name == '..' and TreeExplorer ~= nil then basedir = TreeExplorer.cwd end
    return basedir
  end
-- stylua: ignore start
  return { view = { mappings = { list = {
          { key = '<c-f>', action_cb = function() telescope.find_files(ts_opts(path(), function(name) fs.fn('preview', name) end)) end, },
          { key = '<c-g>', action_cb = function() telescope.live_grep(ts_opts(path(), function(name) fs.fn('preview', name) end)) end, },
        }, }, }, }
  -- stylua: ignore end
end

M.setup_code = function()
  -- Core
  M.semicolon_to_colon()
  M.map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, noremap = true })
  M.map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, noremap = true })
  M.map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { noremap = true, desc = 'Escape And Clear hlsearch' })
  M.map('n', '<c-j>', '15gj', { noremap = true, desc = 'Move Down 15 Lines' })
  M.map('n', '<c-k>', '15gk', { noremap = true, desc = 'Move Up 15 Lines' })
  M.map('n', '<c-h>', '<c-w>h', { desc = 'Jump Left' })
  -- M.map('n', '<c-j>', '<c-w>j', { desc = 'Jump Down' })
  -- M.map('n', '<c-k>', '<c-w>k', { desc = 'Jump Up' })
  M.map('n', '<c-l>', '<c-w>l', { desc = 'Jump Right' })
  M.map('n', '<a-q>', '<cmd>ToggleWrap<cr>', { desc = 'Toggle Wrap' })
  M.map('v', '<', '<gv', { noremap = true, desc = 'deIndent Continuously' })
  M.map('v', '>', '>gv', { noremap = true, desc = 'Indent Continuously' })
  -- File
  M.map('n', '<c-q>', '<cmd>CloseView<cr>', { desc = 'Close' })
  M.map('n', '<c-n>', '<cmd>ene<cr>', { desc = 'New Text File' })
  -- Edit
  M.map('n', '<a-c>', '<cmd>ToggleCaseSensitive<cr>')
  M.map('n', '<c-/>', '<cmd>CommentLine<cr>')
  M.map('n', 'cc', '<cmd>CommentLine<cr>', { desc = 'Comment Line (Comment.nvim)' })
  M.map('x', 'cc', '<cmd>CommentLine<cr>', { desc = 'Comment Line (Comment.nvim)' })
  M.map('n', 'cb', '<cmd>CommentBlock<cr>', { desc = 'Comment Block (Comment.nvim)' })
  M.map('x', 'cb', '<cmd>CommentBlock<cr>', { desc = 'Comment Block (Comment.nvim)' })
  M.map('n', 'S', 'diw"0P', { desc = 'Replace' })
  -- Selection
  M.map('n', '<a-j>', '<cmd>MoveLine(1)<cr>', { noremap = true, desc = 'Line: Move Up (move.nvim)' })
  M.map('n', '<a-k>', '<cmd>MoveLine(-1)<cr>', { noremap = true, desc = 'Line: Move Down (move.nvim)' })
  M.map('n', '<a-h>', '<cmd>MoveHChar(-1)<cr>', { noremap = true, desc = 'Line: Move Left (move.nvim)' })
  M.map('n', '<a-l>', '<cmd>MoveHChar(1)<cr>', { noremap = true, desc = 'Line: Move Right (move.nvim)' })
  M.map('v', '<a-j>', '<cmd>MoveBlock(1)<cr>', { noremap = true, desc = 'Block: Move Up (move.nvim)' })
  M.map('v', '<a-k>', '<cmd>MoveBlock(-1)<cr>', { noremap = true, desc = 'Block: Move Down (move.nvim)' })
  M.map('v', '<a-h>', '<cmd>MoveHBlock(-1)<cr>', { noremap = true, desc = 'Block: Move Left (move.nvim)' })
  M.map('v', '<a-l>', '<cmd>MoveHBlock(1)<cr>', { noremap = true, desc = 'Block: Move Right (move.nvim)' })
  -- View
  M.map('n', '<c-s-p>', '<cmd>Telescope commands<cr>', { noremap = true, desc = 'Command Palette... (telescope.nvim)' })
  M.map('n', [[\]], '<cmd>Telescope commands<cr>', { noremap = true, desc = 'Command Palette... (telescope.nvim)' })
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
  local _close_view = function()
    if #vim.api.nvim_list_wins() == 1 then
      require('close_buffers').delete({ type = 'this' })
    else
      vim.api.nvim_win_close(0, true)
    end
  end
  vim.api.nvim_create_user_command(
    'ToggleFullScreen',
    function() vim.g.neovide_fullscreen = vim.g.neovide_fullscreen == false end,
    { desc = 'Toggle Full Screen' }
  )
  vim.api.nvim_create_user_command(
    'ToggleWrap',
    function() vim.opt.wrap = vim.opt.wrap._value == false end,
    { desc = 'Toggle Wrap' }
  )
  vim.api.nvim_create_user_command(
    'ToggleFocusMode',
    function() vim.opt.laststatus = vim.opt.laststatus._value == 0 and 3 or 0 end,
    { desc = 'Toggle Focus Mode' }
  )
  vim.api.nvim_create_user_command(
    'ToggleCaseSensitive',
    function() vim.opt.ignorecase = vim.opt.ignorecase._value == false end,
    { desc = 'Toggle Case Sensitive' }
  )
  vim.api.nvim_create_user_command(
    'RemoveExclusiveORM',
    function() vim.cmd([[:%s/\r//g]]) end,
    { desc = 'Remove Exclusive ORM' }
  )
  vim.api.nvim_create_user_command(
    'CommentLine',
    function() _any_comment(require('Comment.api').toggle.linewise) end,
    { desc = 'Comment Line' }
  )
  vim.api.nvim_create_user_command(
    'CommentBlock',
    function() _any_comment(require('Comment.api').toggle.blockwise) end,
    { desc = 'Comment Block' }
  )
  vim.api.nvim_create_user_command(
    'SublimeMerge',
    function() require('plenary.job'):new({ command = 'sublime_merge', args = { '-n', vim.fn.getcwd() } }):sync() end,
    { desc = 'Sublime Merge' }
  )
  vim.api.nvim_create_user_command(
    'SublimeText',
    function() require('plenary.job'):new({ command = 'sublime_text', args = { vim.fn.getcwd() } }):sync() end,
    { desc = 'Sublime Text' }
  )
  vim.api.nvim_create_user_command('CloseView', function() _close_view() end, { desc = 'Close View' })
end

M.setup_autocmd = function()
  vim.api.nvim_create_autocmd('BufRead', {
    pattern = { '*.c', '*.cpp', '*.cc', '*.hpp', '*.h', '*.lua' },
    callback = function()
      vim.api.nvim_create_autocmd('BufWinEnter', {
        once = true,
        command = 'normal! zx',
      })
    end,
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('NvimTreeClose', { clear = true }),
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
  vim.api.nvim_create_autocmd('User', {
    pattern = 'NeXT',
    once = true,
    -- callback = function() vim.notify('NeXT', vim.log.levels.INFO) end,
    callback = function() end,
  })
  local _next = function()
    vim.schedule(function()
      if vim.v.exiting ~= vim.NIL then return end
      if vim.g.NeXT == true then vim.api.nvim_exec_autocmds('User', { pattern = 'NeXT', modeline = false }) end
    end)
  end
  vim.api.nvim_create_autocmd('UIEnter', {
    once = true,
    callback = function() _next() end,
  })
  vim.api.nvim_create_autocmd('User', {
    pattern = 'ccls',
    once = true,
    -- callback = function() vim.notify('ccls', vim.log.levels.INFO) end,
    callback = function() end,
  })
  vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
    pattern = '*',
    command = 'checktime',
  })
  local _disable_syntax = function() vim.cmd('if getfsize(@%) > 1000000 | setlocal syntax=OFF | endif') end
  vim.api.nvim_create_autocmd('Filetype', {
    pattern = 'log',
    callback = function() _disable_syntax() end,
  })
  local _nofold = function() vim.cmd('set nofoldenable') end
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
    callback = function() _nofold() end,
  })
  vim.cmd([[:autocmd TermClose * execute 'bdelete! ' . expand('<abuf>')]])
end

return M
