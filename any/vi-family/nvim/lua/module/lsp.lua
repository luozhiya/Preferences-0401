local bindings = require('module.bindings')
local M = {}

local _lsp_clangd = function(on_attach, capabilities)
  local _clangd_on_attach = function(client, buffer)
    local caps = client.server_capabilities
    if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
      local augroup = vim.api.nvim_create_augroup('SemanticTokens', {})
      vim.api.nvim_create_autocmd('TextChanged', {
        group = augroup,
        buffer = bufnr,
        callback = function() vim.lsp.buf.semantic_tokens_full() end,
      })
      -- fire it first time on load as well
      vim.lsp.buf.semantic_tokens_full()
    end
    on_attach(client, buffer)
  end
  local opts = {
    cmd = { 'clangd', '--header-insertion=never' },
    filetypes = { 'c', 'cpp' },
    -- root_dir = function(fname) return require('lspconfig.util').find_git_ancestor(fname) end,
    on_attach = on_attach,
    capabilities = vim.tbl_deep_extend('error', capabilities, {
      offsetEncoding = { 'utf-32' },
    }),
  }
  -- require('lspconfig').clangd.setup(opts)
  require('clangd_extensions').setup({ server = opts })
end

local _lsp_ccls = function(on_attach, capabilities)
  local opts = {
    filetypes = { 'c', 'cpp' },
    offset_encoding = 'utf-32',
    single_file_support = true,
    init_options = {
      highlight = { lsRanges = true },
      cache = {
        directory = '/tmp/ccls-cache',
      },
      compilationDatabaseDirectory = 'build',
      index = {
        threads = 0,
      },
    },
    on_attach = on_attach,
    capabilities = capabilities,
  }
  require('lspconfig').ccls.setup(opts)
  vim.api.nvim_exec_autocmds('User', { pattern = 'ccls', modeline = false })
end

local _lsp_cpp = function(on_attach, capabilities)
  if vim.g.lsp_cpp_provider == 'clangd' then
    _lsp_clangd(on_attach, capabilities)
  elseif vim.g.lsp_cpp_provider == 'ccls' then
    _lsp_ccls(on_attach, capabilities)
  end
end

local _lsp_handlers = function()
  local diagnostics = {
    virtual_text = {
      severity_limit = 'Error',
      spacing = 4,
      prefix = '●',
    },
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
  }
  -- Use Noice hover, fix rainbow pairs in hover window
  -- vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
  vim.lsp.handlers['textDocument/publishDiagnostics'] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, diagnostics)
  vim.diagnostic.config(diagnostics)
end

local _lsp_client_preferences = function()
  local on_attach = function(client, buffer)
    bindings.lsp(client, buffer)
    -- require('lsp_signature').on_attach()
  end
  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport =
    { properties = { 'documentation', 'detail', 'additionalTextEdits' } }
  return on_attach, capabilities
end

local _lsp_lightbulb = function()
  local _hl_group = function() return 'LightBulb' end
  local _is_codeaction = function()
    for _, client in pairs(vim.lsp.buf_get_clients()) do
      if client and client.supports_method('textDocument/codeAction') then return true end
    end
    return false
  end
  local _init = function()
    local icons = require('module.options').icons
    if vim.tbl_isempty(vim.fn.sign_getdefined(_hl_group())) then
      vim.fn.sign_define(_hl_group(), { text = icons.diagnostics.Hint, texthl = _hl_group() })
    end
    vim.api.nvim_set_hl(0, _hl_group(), { link = 'DiagnosticSignHint', default = true })
  end
  local _update_bulb = function(buffer, line)
    if vim.w.lightbulb_line == 0 then vim.w.lightbulb_line = 1 end
    if vim.w.lightbulb_line ~= 0 then
      vim.fn.sign_unplace(_hl_group(), { id = vim.w.lightbulb_line, buffer = buffer })
    end
    if line then
      vim.fn.sign_place(line, _hl_group(), _hl_group(), buffer, { lnum = line + 1, priority = 10 })
      vim.w.lightbulb_line = line
    end
  end
  local _send_request = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.w.lightbulb_line = vim.w.lightbulb_line or 0
    local diagnostics = vim.lsp.diagnostic.get_line_diagnostics(buf)
    local context = { diagnostics = diagnostics }
    local params = vim.lsp.util.make_range_params()
    params.context = context
    local line = params.range.start.line
    local _responses_slove = function(responses)
      local has_actions = false
      for _, resp in pairs(responses or {}) do
        if resp.result and not vim.tbl_isempty(resp.result) then
          has_actions = true
          break
        end
      end
      _update_bulb(buf, has_actions == true and line or nil)
    end
    vim.lsp.buf_request_all(buf, 'textDocument/codeAction', params, _responses_slove)
  end
  local _render_bulb = function(buffer)
    if not _is_codeaction() then return end
    require('plenary.async').run(_send_request)
  end
  local _autocmd = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('LspLightBulb', { clear = true }),
      callback = function(opt)
        local buf = opt.buf
        local group = vim.api.nvim_create_augroup(_hl_group() .. tostring(buf), {})
        vim.api.nvim_create_autocmd('CursorHold', {
          group = group,
          buffer = buf,
          callback = function() _render_bulb(buf) end,
        })
        vim.api.nvim_create_autocmd('BufLeave', {
          group = group,
          buffer = buf,
          callback = function() _update_bulb(buf, nil) end,
        })
        vim.api.nvim_create_autocmd('BufDelete', {
          buffer = buf,
          once = true,
          callback = function() pcall(vim.api.nvim_del_augroup_by_id, group) end,
        })
      end,
    })
  end
  _init()
  _autocmd()
end

local _lsp_signdefine = function()
  local icons = require('module.options').icons
  for type, icon in pairs(icons.diagnostics) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
  end
  -- `DapBreakpoint` for breakpoints (default: `B`)
  -- `DapBreakpointCondition` for conditional breakpoints (default: `C`)
  -- `DapLogPoint` for log points (default: `L`)
  -- `DapStopped` to indicate where the debugee is stopped (default: `→`)
  -- `DapBreakpointRejected` to indicate breakpoints rejected by the debug adapter (default: `R`)
  vim.fn.sign_define('DapBreakpoint', { text = 'ﱣ', texthl = 'Error', linehl = '', numhl = '' })
  vim.fn.sign_define('DapBreakpointCondition', { text = 'ﱣ', texthl = 'Function', linehl = '', numhl = '' })
  vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'Comment', linehl = '', numhl = '' })
  vim.fn.sign_define('DapStopped', { text = '🠶', texthl = 'String', linehl = 'DiffAdd', numhl = '' })
end

local _mason = function()
  local opts = {
    ensure_installed = {
      'stylua',
      'shfmt',
      -- "flake8",
      'prettierd',
    },
  }
  require('mason').setup(opts)
  local mr = require('mason-registry')
  local function ensure_installed()
    for _, tool in ipairs(opts.ensure_installed) do
      local p = mr.get_package(tool)
      if not p:is_installed() then p:install() end
    end
  end
  if mr.refresh then
    mr.refresh(ensure_installed)
  else
    ensure_installed()
  end
  local lsp = {
    ensure_installed = {
      'lua_ls',
      'cmake',
      'asm_lsp',
      'pylsp',
      'vimls',
    },
  }
  require('mason-lspconfig').setup(lsp)
end

local _null_ls = function()
  local null_ls = require('null-ls')
  local opts = {
    root_dir = require('null-ls.utils').root_pattern('.null-ls-root', '.neoconf.json', 'Makefile', '.git'),
    sources = {
      -- null_ls.builtins.formatting.stylua,
      -- null_ls.builtins.diagnostics.eslint,
      -- null_ls.builtins.completion.spell,
      -- null_ls.builtins.formatting.prettierd,
      null_ls.builtins.formatting.prettier.with({
        filetypes = { 'html', 'json', 'yaml', 'markdown' },
        extra_args = { '--no-semi', '--single-quote', '--jsx-single-quote' },
      }),
      -- null_ls.builtins.formatting.black.with({ extra_args = { '--fast' } }),
      -- null_ls.builtins.formatting.stylua,
    },
  }
  null_ls.setup(opts)
end

local _lsp = function()
  local lsp = require('lspconfig')
  local on_attach, capabilities = _lsp_client_preferences()
  _lsp_cpp(on_attach, capabilities)
  lsp.lua_ls.setup({ on_attach = on_attach, capabilities = capabilities })
  lsp.cmake.setup({ on_attach = on_attach, capabilities = capabilities })
end

M.lsp = function()
  vim.lsp.set_log_level('OFF')
  _lsp_handlers()
  _lsp_lightbulb()
  _lsp_signdefine()
  -- mason: It's important that you set up the plugins in the following order
  _mason()
  require('neodev').setup()
  _lsp()
  _null_ls()
end

M.dap = function()
  local dap = require('dap')
  dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode', -- must be absolute path
    name = 'lldb',
  }
  dap.configurations.cpp = {
    {
      name = 'Launch',
      type = 'lldb',
      request = 'launch',
      -- program = '',
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
    },
  }
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.lua = {
    {
      type = 'nlua',
      request = 'attach',
      name = 'Attach to running Neovim instance',
    },
  }
  dap.adapters.nlua = function(callback, config)
    callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
  end
  local dapui = require('dapui')
  dapui.setup()
  dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open({}) end
  dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close({}) end
  dap.listeners.before.event_exited['dapui_config'] = function() dapui.close({}) end
  require('nvim-dap-virtual-text').setup()
  require('persistent-breakpoints').setup({ load_breakpoints_event = { 'BufReadPost' } })
end

return M
