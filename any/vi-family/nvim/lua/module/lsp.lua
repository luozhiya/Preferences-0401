local bindings = require('module.bindings')
local M = {}

local lsp_clangd = function(on_attach, capabilities)
  local opts = {
    filetypes = { 'c', 'cpp' },
    on_attach = on_attach,
    capabilities = vim.tbl_deep_extend('error', capabilities, {
      offsetEncoding = { 'utf-32' },
    }),
  }
  require('lspconfig').clangd.setup(opts)
end

local lsp_ccls = function()
  local on_attach = function(client, buffer)
    local disabled_provider = {
      'workspaceSymbolProvider',
      'definitionProvider',
      'referencesProvider',
      'implementationProvider',
      'codeActionProvider',
      'resolveProvider',
      'documentSymbolProvider',
      'documentFormattingProvider',
      'documentRangeFormattingProvider',
      'documentOnTypeFormattingProvider',
    }
    for _, v in ipairs(disabled_provider) do
      client.server_capabilities[v] = false
    end
  end
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
    on_attach = on_attach,
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  }
  require('lspconfig').ccls.setup(opts)
end

local setup_lsp_cpp = function(on_attach, capabilities)
  lsp_clangd(on_attach, capabilities)
  lsp_ccls()
end

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
  setup_lsp_cpp(on_attach, capabilities)
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
