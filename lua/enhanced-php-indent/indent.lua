local M = {}

local function setup_php_buffer()
  vim.bo.indentexpr = "v:lua.EnhancedPhpIndent()"
  vim.bo.indentkeys = "0{,0},0),0],:,o,O,e"
  vim.bo.smartindent = false
  vim.bo.cindent = false
  vim.b.did_indent = 1

  print("MINIMAL PHP Indent loaded")
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = setup_php_buffer,
    group = vim.api.nvim_create_augroup("MinimalPHPIndent", { clear = true }),
  })
end

return M
