local M = {}

local cached = {}

M.is_windows = function() return vim.loop.os_uname().sysname == 'Windows_NT' end
M.is_linux = function() return vim.loop.os_uname().sysname == 'Linux' end
M.nt_sep = function() return '\\' end
M.kernel_sep = function() return '/' end
M.os_sep = function() return package.config:sub(1, 1) end
M.nvim_sep = function() return (M.is_windows() and vim.opt.shellslash._value == 0) and M.nt_sep() or M.kernel_sep() end
M.to_nt = function(s) return s:gsub(M.kernel_sep(), M.nt_sep()) end
M.to_kernel = function(s) return s:gsub(M.nt_sep(), M.kernel_sep()) end
M.to_native = function(s) return M.is_windows() and M.to_nt(s) or M.to_kernel(s) end
M.shellslash_safe = function(s) return M.nvim_sep() == M.kernel_sep() and s:gsub(M.nt_sep(), M.kernel_sep()) or s end
M.is_uri = function(path) return path:match('^%w+://') ~= nil end
M.file_exists = function(file) return vim.loop.fs_stat(file) ~= nil end
M.home = function() return vim.loop.os_homedir() end
M.root = function() return M.is_windows() and M.shellslash_safe(string.sub(vim.loop.cwd(), 1, 1) .. ':' .. M.nt_sep()) or M.kernel_sep() end
M.concat_paths = function(...) return table.concat({ ... }, M.nvim_sep()) end

function M.open(uri)
  if uri == nil then
    return vim.notify('Open nil URI', vim.log.levels.INFO)
  end
  local cmd
  if M.is_windows() then
    cmd = { 'explorer', uri }
    cmd = M.to_nt(table.concat(cmd, ' '))
  else
    if vim.fn.executable('xdg-open') == 1 then
      cmd = { 'xdg-open', uri }
    end
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
  if path:sub(-1) == M.nvim_sep() then
    return path
  end
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
  return name ~= '' and name or '[No Name]'
end

M.name = function()
  local path = M.get_current_buffer_name()
  local i = M.rfind(path, M.nvim_sep())
  return i and string.sub(path, -i + 1, -1) or path
end

M.get_name_without_ext = function()
  local name = M.name()
  local i = M.rfind(name, '.')
  return i and string.sub(name, 1, i) or name
end

M.get_contain_directory = function()
  local path = M.get_current_buffer_name()
  local i = M.rfind(path, M.nvim_sep())
  return i and string.sub(path, 1, #path - i + 1) or nil
end

return M
