local M = {}

local function setup_php_buffer()
  -- SIMPLE setup - no interfering autocmds
  vim.bo.indentexpr = "v:lua.EnhancedPhpIndent()"

  -- FIXED: Simple indentkeys - no aggressive auto-indenting
  vim.bo.indentkeys = "0{,0},0),0],:,o,O,e"

  vim.bo.smartindent = false
  vim.bo.cindent = false
  vim.bo.autoindent = false
  vim.b.did_indent = 1

  print("Enhanced PHP Indent (Simple) loaded for: " .. vim.fn.expand('%:t'))
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = setup_php_buffer,
    group = vim.api.nvim_create_augroup("EnhancedPHPIndent", { clear = true }),
  })
end

return M
