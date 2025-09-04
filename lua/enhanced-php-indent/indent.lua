-- Enhanced PHP Indent Setup Module
local M = {}

-- Set up PHP indentation for current buffer
local function setup_php_buffer()
  local config = require('enhanced-php-indent').config

  -- Remove CR if needed
  if vim.bo.fileformat == "unix" and config.remove_cr_when_unix then
    vim.cmd("silent! %s/\r$//g")
  end

  -- Set indent options (CRITICAL: Correct indentexpr syntax)
  vim.bo.smartindent = false
  vim.bo.autoindent = false
  vim.bo.cindent = false 
  vim.bo.lisp = false
  vim.bo.indentexpr = "v:lua.EnhancedPhpIndent()"  -- FIXED: Proper global function call
  vim.bo.indentkeys = "0{,0},0),0],:,!^F,o,O,e,*,=?>,=,=*/"

  -- Comment formatting
  if config.autoformat_comment then
    vim.bo.formatoptions = vim.bo.formatoptions .. "qrowcb"
  end

  -- Mark buffer as indented
  vim.b.did_indent = 1
end

-- Real-time auto-indent (ENHANCED FEATURE)
local function setup_auto_indent()
  local config = require('enhanced-php-indent').config
  if not config.enable_real_time_indent then
    return
  end

  local group = vim.api.nvim_create_augroup("EnhancedPHPRealTime", { clear = false })

  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChangedI" }, {
    group = group,
    buffer = 0,  -- Current buffer only
    callback = function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local line = vim.fn.getline(row)
      local prev_line = vim.fn.getline(row - 1)

      -- Auto-indent empty array closing brackets
      if vim.fn.match(line, '^\s*$') >= 0 and vim.fn.match(prev_line, '\[\s*$') >= 0 then
        local next_line = vim.fn.getline(row + 1)
        if vim.fn.match(next_line, '^\s*\]') >= 0 then
          vim.cmd("normal! " .. (row + 1) .. "G==")
        end
      end
    end,
  })
end

-- Main setup function
function M.setup()
  -- Only setup for PHP files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
      setup_php_buffer()
      setup_auto_indent()
    end,
    group = vim.api.nvim_create_augroup("EnhancedPHPIndentSetup", { clear = true }),
  })
end

return M
