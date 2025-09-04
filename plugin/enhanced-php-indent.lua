if vim.g.loaded_enhanced_php_indent then
  return
end
vim.g.loaded_enhanced_php_indent = 1

vim.api.nvim_create_user_command("PHPIndentTest", function()
  local status = {
    loaded = vim.b.did_indent == 1,
    indentexpr = vim.bo.indentexpr,
    global_func = _G.EnhancedPhpIndent ~= nil,
    filetype = vim.bo.filetype
  }
  print("Enhanced PHP Indent Status:")
  for k, v in pairs(status) do
    print("  " .. k .. ": " .. tostring(v))
  end
end, {})
