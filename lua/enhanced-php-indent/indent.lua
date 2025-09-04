local M = {}

-- Real-time case/break fixing with autocmds
local function setup_realtime_fixes()
  local config = require('enhanced-php-indent').config
  if not config.enable_real_time_indent then
    return
  end

  local group = vim.api.nvim_create_augroup("EnhancedPHPRealtime", { clear = false })

  -- Fix indentation on specific triggers
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    buffer = 0,
    callback = function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local line = vim.fn.getline(row)
      local line_clean = vim.trim(line)

      -- Auto-fix case/default/break indentation
      if line_clean:find("^case%s.+:") or line_clean:find("^default%s*:") or line_clean:find("^break%s*;") then
        vim.schedule(function()
          vim.cmd("normal! ==")  -- Reindent current line
        end)
      end
    end,
  })

  -- Fix when typing colon after case
  vim.api.nvim_create_autocmd("InsertCharPre", {
    group = group,
    buffer = 0,
    callback = function()
      if vim.v.char == ":" then
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local line = vim.fn.getline(row)
        local line_clean = vim.trim(line)

        if line_clean:find("^case%s") then
          vim.schedule(function()
            vim.cmd("normal! ==")
          end)
        end
      end
    end,
  })
end

local function setup_php_buffer()
  -- Enhanced indentkeys for better responsiveness
  vim.bo.indentexpr = "v:lua.EnhancedPhpIndent()"
  vim.bo.indentkeys = "0{,0},0),0],:,o,O,e,0=break,0=case,0=default,*=;"
  vim.bo.smartindent = false
  vim.bo.cindent = false
  vim.b.did_indent = 1

  -- Setup real-time fixes
  setup_realtime_fixes()

  print("Enhanced PHP Indent with Case/Break support loaded")
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = setup_php_buffer,
    group = vim.api.nvim_create_augroup("EnhancedPHPIndent", { clear = true }),
  })
end

return M
