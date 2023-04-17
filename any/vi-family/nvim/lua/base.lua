local M = {}

local cached = {}

M.is_windows = function() return vim.loop.os_uname().sysname == 'Windows_NT' end
M.is_kernel = function() return vim.loop.os_uname().sysname == 'Linux' end
M.nt_sep = function() return '\\' end
M.kernel_sep = function() return '/' end
M.os_sep = function() return package.config:sub(1, 1) end
M.to_nt = function(s) return s:gsub(M.kernel_sep(), M.nt_sep()) end
M.to_kernel = function(s) return s:gsub(M.nt_sep(), M.kernel_sep()) end
M.to_native = function(s) return M.is_windows() and M.to_nt(s) or M.to_kernel(s) end
M.shellslash_safe = function(s) return M.nvim_sep() == M.kernel_sep() and s:gsub(M.nt_sep(), M.kernel_sep()) or s end
M.is_uri = function(path) return path:match('^%w+://') ~= nil end
M.file_exists = function(file) return vim.loop.fs_stat(file) ~= nil end
M.home = function() return vim.loop.os_homedir() end
M.root = function()
  return M.is_windows() and M.shellslash_safe(string.sub(vim.loop.cwd(), 1, 1) .. ':' .. M.nt_sep()) or M.kernel_sep()
end
M.concat_paths = function(...) return table.concat({ ... }, M.nvim_sep()) end
M.nvim_sep = function()
  if M.is_kernel() or (M.is_windows() and vim.opt.shellslash._value == true) then return M.kernel_sep() end
  return M.nt_sep()
end
M.open = function(uri)
  if uri == nil then return vim.notify('Open nil URI', vim.log.levels.INFO) end
  local cmd
  if M.is_windows() then
    cmd = { 'explorer', uri }
    cmd = M.to_nt(table.concat(cmd, ' '))
  else
    if vim.fn.executable('xdg-open') == 1 then cmd = { 'xdg-open', uri } end
  end
  local ret = vim.fn.jobstart(cmd, { detach = true })
  if ret <= 0 then
    local msg = {
      'Failed to open uri',
      ret,
      vim.inspect(cmd),
    }
    vim.notify(table.concat(msg, '\n'), vim.log.levels.ERROR)
  end
end

M.copy_to_clipboard = function(content)
  vim.fn.setreg('+', content)
  vim.fn.setreg('"', content)
  return vim.notify(string.format('Copied %s to system clipboard!', content), vim.log.levels.INFO)
end

M.is_root = function(path)
  if M.is_windows() then
    if M.nvim_sep() == M.kernel_sep() then
      return string.match(path, '^[A-Z]:/?$')
    else
      return string.match(path, '^[A-Z]:\\?$')
    end
  end
  return path == M.kernel_sep()
end

M.is_absolute = function(path)
  if M.is_windows() then
    if M.nvim_sep() == M.kernel_sep() then
      return string.match(path, '^[%a]:/.*$')
    else
      return string.match(path, '^[%a]:\\.*$')
    end
  end
  return string.sub(path, 1, 1) == M.kernel_sep()
end

M.rfind = function(s, sub)
  return (function()
    local r = { string.find(string.reverse(s), sub, 1, true) }
    return r[2]
  end)()
end

M.path_add_trailing = function(path)
  if path:sub(-1) == M.nvim_sep() then return path end
  return path .. M.nvim_sep()
end

M.path_relative = function(path, relative_to)
  local _, r = string.find(path, M.path_add_trailing(relative_to), 1, true)
  local p = path
  if r then
    -- take the relative path starting after '/'
    -- if somehow given a completely matching path,
    -- returns ""
    p = path:sub(r + 1)
  end
  return p
end

M.get_content = function() return vim.api.nvim_buf_get_text(0, 0, 0, -1, -1, {}) end
M.get_path = function() return M.get_current_buffer_name() end
M.get_relative_path = function() return M.path_relative(M.get_current_buffer_name(), vim.fn.getcwd()) end

M.get_current_buffer_name = function()
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  return M.shellslash_safe(name ~= '' and name or '[No Name]')
end

M.name = function()
  local path = M.get_current_buffer_name()
  local i = M.rfind(path, M.nvim_sep())
  return i and string.sub(path, -i + 1, -1) or path
end

M.get_name_without_ext = function()
  local name = M.name()
  local i = M.rfind(name, '.')
  return i and string.sub(name, 1, -i - 1) or name
end

M.get_contain_directory = function()
  local path = M.get_current_buffer_name()
  local i = M.rfind(path, M.nvim_sep())
  return i and string.sub(path, 1, #path - i + 1) or nil
end

M.notify = function(msg, opts)
  if vim.in_fast_event() then return vim.schedule(function() M.notify(msg, opts) end) end
  opts = opts or {}
  if type(msg) == 'table' then
    msg = table.concat(vim.tbl_filter(function(line) return line or false end, msg), '\n')
  end
  vim.notify(msg, opts.level or vim.log.levels.INFO, {
    title = opts.title or 'Notify From Base',
  })
end

M.info = function(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.INFO
  M.notify(msg, opts)
end

M.warn = function(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.WARN
  M.notify(msg, opts)
end

M.fetch = function(option, _local)
  if _local then return vim.opt_local[option]:get() end
  return vim.opt[option]:get()
end

M.set = function(option, _local, value)
  if _local then
    vim.opt_local[option] = value
  else
    vim.opt[option] = value
  end
  M.info('Set ' .. option .. ' to ' .. tostring(value), { title = 'Option Changed' })
end

M.toggle = function(option, _local, msg)
  M.set(option, _local, not M.fetch(option, _local))
  if msg and vim.tbl_count(msg) == 2 then
    if M.fetch(option, _local) then
      M.info(msg[1], { title = 'Option Toggle' })
    else
      M.info(msg[2], { title = 'Option Toggle' })
    end
  end
end

M.has = function(plugin) return require('lazy.core.config').plugins[plugin] ~= nil end

M.on_attach = function(on_attach)
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

M.on_very_lazy = function(fn)
  vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    callback = function() fn() end,
  })
end

return M
