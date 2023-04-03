local bindings = require('module.bindings')
local M = {}

M.lsp = function()
  vim.lsp.set_log_level('OFF')
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
  vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    { virtual_text = false, signs = false, update_in_insert = false, underline = false }
  )
  local on_attach = function(client, buffer)
    for _, keys in pairs(bindings.lsp) do
      bindings.map(keys.mode or 'n', keys[1], keys[2], { noremap = true, silent = true, buffer = buffer })
    end
    require('lsp-inlayhints').on_attach(client, buffer)
  end
  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- mason: It's important that you set up the plugins in the following order
  require('mason').setup()
  require('mason-lspconfig').setup({ ensure_installed = { 'lua_ls' } })
  require('neodev').setup()
  require('lsp-inlayhints').setup()
  require('lspconfig').lua_ls.setup({ on_attach = on_attach, capabilities = capabilities })
  local offset = {
    offsetEncoding = { 'utf-32' },
  }
  local clangd_capabilities = vim.tbl_deep_extend('error', capabilities, offset)
  require('lspconfig').clangd.setup({
    filetypes = { 'c', 'cpp' },
    init_options = {
      clangdFileStatus = true,
    },
    on_attach = on_attach,
    capabilities = clangd_capabilities,
  })
  local ccls_on_attach = function(client, buffer)
    -- Lsp workspace symbol, <,lS>
    client.server_capabilities.workspaceSymbolProvider = false
    -- Lsp finder
    client.server_capabilities.definitionProvider = false
    client.server_capabilities.referencesProvider = false
    --
    client.server_capabilities.implementationProvider = false
    client.server_capabilities.codeActionProvider = false
    client.server_capabilities.resolveProvider = false
    client.server_capabilities.documentSymbolProvider = false
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.documentOnTypeFormattingProvider = false
  end
  require('lspconfig').ccls.setup({
    filetypes = { 'c', 'cpp' },
    offset_encoding = 'utf-32',
    -- ccls does not support sending a null root directory
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
      clang = {
        excludeArgs = { '-frounding-math' },
      },
    },
    handlers = {
      ['textDocument/publishDiagnostics'] = function(...) return nil end,
      ['textDocument/hover'] = function(...) return nil end,
      ['textDocument/signatureHelp'] = function(...) return nil end,
      ['workspace/symbol'] = nil,
      ['textDocument/definition'] = nil,
      ['textDocument/implementation'] = nil,
      ['textDocument/references'] = nil,
      ['textDocument/formatting'] = nil,
      ['textDocument/rangeFormatting'] = nil,
    },
    on_attach = ccls_on_attach,
    capabilities = capabilities,
  })
end

M.dap = function()
  local dap = require('dap')
  dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode', -- must be absolute path
    name = 'lldb',
  }
  local dapui = require('dapui')
  dapui.setup()
  dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open({}) end
  dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close({}) end
  dap.listeners.before.event_exited['dapui_config'] = function() dapui.close({}) end
  require('nvim-dap-virtual-text').setup()
  require('persistent-breakpoints').setup({ load_breakpoints_event = { 'BufReadPost' } })
end

return M
