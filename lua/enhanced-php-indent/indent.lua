local M = {}

local function setup_php_buffer()
  vim.bo.indentexpr = "v:lua.EnhancedPhpIndent()"
  vim.bo.indentkeys = "0{,0},0),0],:,o,O,e"
  vim.b.did_indent = 1
  print("Enhanced PHP Indent loaded for: " .. vim.api.nvim_buf_get_name(0))
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = setup_php_buffer,
    group = vim.api.nvim_create_augroup("EnhancedPHPIndent", { clear = true }),
  })
end

return M
