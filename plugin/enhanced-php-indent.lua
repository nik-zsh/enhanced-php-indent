-- Enhanced PHP Indent Plugin Auto-loader
if vim.g.loaded_enhanced_php_indent then
  return
end
vim.g.loaded_enhanced_php_indent = 1

-- Check Neovim version
if vim.fn.has("nvim-0.7") ~= 1 then
  vim.notify("enhanced-php-indent requires Neovim >= 0.7", vim.log.levels.ERROR)
  return
end

-- Commands for manual testing
vim.api.nvim_create_user_command("EnhancedPhpIndentSetup", function()
  require("enhanced-php-indent").setup({
    indent_function_call_parameters = true,
    enable_real_time_indent = true,
  })
  print("Enhanced PHP Indent setup complete!")
end, {})

vim.api.nvim_create_user_command("EnhancedPhpIndentStatus", function()
  local config = require("enhanced-php-indent").config
  print("Enhanced PHP Indent Status:")
  print("  Loaded: " .. (vim.b.did_indent and "Yes" or "No"))
  print("  IndentExpr: " .. vim.bo.indentexpr)
  print("  Config: " .. vim.inspect(config))
end, {})
