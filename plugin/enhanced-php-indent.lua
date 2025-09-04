-- Enhanced PHP Indent Plugin Loader
if vim.g.loaded_enhanced_php_indent then
  return
end
vim.g.loaded_enhanced_php_indent = 1

if vim.fn.has("nvim-0.7") ~= 1 then
  vim.notify("enhanced-php-indent requires Neovim >= 0.7", vim.log.levels.ERROR)
  return
end

-- User commands for testing and configuration
vim.api.nvim_create_user_command("PHPIndentStatus", function()
  local config = require("enhanced-php-indent").config
  print("Enhanced PHP Indent Status:")
  print("  Loaded: " .. tostring(vim.b.did_indent == 1))
  print("  IndentExpr: " .. vim.bo.indentexpr) 
  print("  Global function: " .. tostring(_G.EnhancedPhpIndent ~= nil))
  print("  Filetype: " .. vim.bo.filetype)
  print("Configuration:")
  for k, v in pairs(config) do
    print("  " .. k .. ": " .. tostring(v))
  end
end, {})

vim.api.nvim_create_user_command("PHPIndentReload", function()
  package.loaded["enhanced-php-indent"] = nil
  package.loaded["enhanced-php-indent.indent"] = nil
  require("enhanced-php-indent").setup()
  print("Enhanced PHP Indent reloaded")
end, {})

vim.api.nvim_create_user_command("PHPIndentTest", function()
  if vim.bo.filetype ~= "php" then
    print("Not a PHP file")
    return
  end
  print("Testing PHP indentation...")
  vim.cmd("normal! gg=G")
  print("File reindented. Check the results!")
end, {})
