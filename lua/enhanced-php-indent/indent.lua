local M = {}

local function setup_php_buffer()
  local config = require('enhanced-php-indent').config

  -- Remove CR if needed (Unix systems)
  if vim.bo.fileformat == "unix" and config.remove_cr_when_unix then
    vim.cmd('silent! %s/\r$//g')
  end

  -- Set indent options
  vim.bo.indentexpr = "v:lua.EnhancedPhpIndent()"
  vim.bo.indentkeys = "0{,0},0),0],:,o,O,e"
  vim.bo.smartindent = false
  vim.bo.cindent = false
  vim.bo.autoindent = false

  -- Comment formatting
  if config.autoformat_comment then
    vim.bo.formatoptions = vim.bo.formatoptions .. "qrowcb"
  end

  vim.b.did_indent = 1
  print("Enhanced PHP Indent (Comprehensive) loaded for: " .. vim.fn.expand('%:t'))
end

-- Optional real-time fixes (minimal to avoid conflicts)
local function setup_minimal_realtime()
  local config = require('enhanced-php-indent').config
  if not config.enable_real_time_indent then
    return
  end

  local group = vim.api.nvim_create_augroup("EnhancedPHPRealtime", { clear = false })

  -- Only fix obvious issues on InsertLeave
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    buffer = 0,
    callback = function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local line = vim.fn.getline(row)
      local line_clean = vim.trim(line)

      -- Fix closing brackets if obviously wrong
      if line_clean:find("^[%]%}%)]") and vim.fn.indent(row) == 0 then
        vim.schedule(function()
          vim.cmd("normal! ==")
        end)
      end
    end,
  })
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
      setup_php_buffer()
      setup_minimal_realtime()
    end,
    group = vim.api.nvim_create_augroup("EnhancedPHPIndent", { clear = true }),
  })
end

return M
