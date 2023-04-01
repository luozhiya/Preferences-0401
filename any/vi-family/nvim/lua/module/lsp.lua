local bindings = require('module.bindings')

local M = {}

M.lsp = function()
  vim.lsp.set_log_level('OFF')
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
  vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false, signs = false, update_in_insert = false, underline = false })
  local lsp_on_attach = function(client, buffer)
    for _, keys in pairs(bindings.lsp) do
      bindings.map(keys.mode or 'n', keys[1], keys[2], { noremap = true, silent = true, buffer = buffer })
    end
    require('lsp-inlayhints').on_attach(client, buffer)
  end
  local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
  require('neodev').setup()
  require('lspconfig').lua_ls.setup({ on_attach = lsp_on_attach, capabilities = lsp_capabilities })
  require('lspconfig').clangd.setup({ filetypes = { 'c', 'cpp' }, on_attach = lsp_on_attach, capabilities = lsp_capabilities })
end

M.setup = function() M.lsp() end

return M
