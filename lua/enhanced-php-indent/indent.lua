-- Enhanced PHP Indent Core Module
-- Provides the actual indentation functionality

local M = {}

-- Store configuration
M.config = {}

-- PHP syntax patterns
local patterns = {
  endline = [[\s*\%(//.*\|#\[\@!.*\|/\*.*\*/\s*\)\=$]],
  PHP_validVariable = [[[a-zA-Z_-ÿ][a-zA-Z0-9_-ÿ]*]],
  blockstart = [[\%(\%(\%(}\s*\)\=else\%(\s\+\)\=\)\=if\>\|\%(}\s*\)\?else\>\|do\>\|while\>\|switch\>\|case\>\|default\>\|for\%(each\)\=\>\|declare\>\|class\>\|trait\>\|interface\>\|abstract\>\|final\>\|try\>\|\%(}\s*\)\=catch\>\|\%(}\s*\)\=finally\>\)]],
  functionDecl = [[\<function\>\%(\s\+&\=]] .. [[[a-zA-Z_-ÿ][a-zA-Z0-9_-ÿ]*]] .. [[\)\=\s*(.*).*]],
  terminated = [[\%(\%(;\%(\s*\%(?>\|}\)\)\=\|<<<\s*[''"]\=\w*[''"]\=$\|^\s*}\|^\s*]] .. [[[a-zA-Z_-ÿ][a-zA-Z0-9_-ÿ]*]] .. [[::\).*]],
}

-- Enhanced PHP indent function
function M.get_php_indent()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local trimmed = line:gsub("^%s+", "")

  -- Get shift width
  local sw = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or 4

  -- Get previous non-blank line
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0

  -- Handle blank line inside empty array brackets (ENHANCED FEATURE)
  if trimmed == "" and prev_lnum > 0 and prev_line:match("%[%s*$") then
    local next_lnum = lnum + 1
    local next_line = vim.fn.getline(next_lnum)
    while next_line:match("^%s*$") and next_lnum < vim.fn.line("$") do
      next_lnum = next_lnum + 1
      next_line = vim.fn.getline(next_lnum)
    end
    if next_line:match("^%s*%]") then
      return prev_indent + 2 * sw  -- Double indent for empty arrays
    end
  end

  -- Align closing bracket ']' with opening bracket '['
  if trimmed:match("^%]%s*$") and prev_lnum > 0 and prev_line:match("%[%s*$") then
    return prev_indent
  end

  -- Dedent closing braces/brackets/parens
  if trimmed:match("^[%]%)}]") then
    return math.max(vim.fn.indent(lnum - 1) - sw, 0)
  end

  -- Switch statement handling (ENHANCED)
  if prev_lnum > 0 and prev_line:match("^%s*switch%s*%(.*%)%s*{%s*$") then
    return prev_indent + sw
  end

  -- Case/default labels (ENHANCED)
  if trimmed:match("^case%s+.+:") or trimmed:match("^default%s*:") then
    local switch_lnum = vim.fn.search("{", "bnW") 
    local base_indent = switch_lnum > 0 and vim.fn.indent(switch_lnum) or 0
    if not M.config.vintage_case_default_indent then
      return base_indent + sw
    else
      return base_indent
    end
  end

  -- Indent statements inside case
  if prev_line:match("^%s*case%s+.+:") or prev_line:match("^%s*default%s*:") then
    return prev_indent + sw
  end

  -- Function parameter indentation
  if M.config.indent_function_call_parameters or M.config.indent_function_declaration_parameters then
    if prev_line:match("%(") and not prev_line:match("%)") then
      return prev_indent + sw
    end
  end

  -- Indent after opening braces/brackets/parens
  if prev_line:match("{%s*$") or prev_line:match("%[%s*$") or prev_line:match("%(%s*$") then
    return prev_indent + sw
  end

  -- Handle control structures  
  if prev_line:match("^%s*if%s*%(") or prev_line:match("^%s*while%s*%(") or
     prev_line:match("^%s*for%s*%(") or prev_line:match("^%s*foreach%s*%(") or
     prev_line:match("^%s*function%s+") or prev_line:match("^%s*class%s+") then
    return prev_indent + sw
  end

  -- Handle terminated statements
  if prev_line:match(";%s*$") then
    return prev_indent
  end

  -- Arrow method chaining (unless disabled)
  if not M.config.no_arrow_matching and prev_line:match("->") then
    if trimmed:match("^->") then
      return prev_indent
    end
  end

  -- Handle PHP tags
  if M.config.outdent_php_escape then
    if trimmed:match("^%?>") or trimmed:match("^<%?php") or trimmed:match("^<%?") then
      return 0
    end
  end

  -- Default: keep previous indentation
  return prev_indent
end

-- Set up PHP file indentation
local function setup_php_indent()
  -- Remove CR characters if needed
  if vim.bo.fileformat == "unix" and M.config.remove_cr_when_unix then
    vim.cmd("silent! %s/\r$//g")
  end

  -- Set indent options
  vim.bo.smartindent = false
  vim.bo.autoindent = false
  vim.bo.cindent = false
  vim.bo.lisp = false
  vim.bo.indentexpr = "v:lua.require('enhanced-php-indent.indent').get_php_indent()"
  vim.bo.indentkeys = "0{,0},0),0],:,!^F,o,O,e,*,=?>,=,=*/"

  -- Set up comment formatting if enabled
  if M.config.autoformat_comment then
    vim.bo.formatoptions = vim.bo.formatoptions .. "qrowcb"
  end

  -- Mark as loaded
  vim.b.did_indent = 1
end

-- Real-time auto-indenting (ENHANCED FEATURE)
local function setup_auto_indent()
  if not M.config.enable_real_time_indent then
    return
  end

  local group = vim.api.nvim_create_augroup("EnhancedPHPIndent", { clear = true })

  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChangedI" }, {
    group = group,
    pattern = "*.php",
    callback = function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local line = vim.api.nvim_get_current_line()
      local prev_line = vim.fn.getline(row - 1)

      -- Auto-indent closing brackets for empty arrays
      if line:match("^%s*$") and prev_line:match("%[%s*$") then
        local next_line = vim.fn.getline(row + 1)
        if next_line:match("^%s*%]") then
          vim.api.nvim_command((row + 1) .. "normal! ==")
        end
      end
    end,
  })
end

-- Main setup function
function M.setup(config)
  M.config = config or {}

  -- Set up for PHP files only
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
      setup_php_indent()
      setup_auto_indent()
    end,
    group = vim.api.nvim_create_augroup("EnhancedPHPIndentFileType", { clear = true }),
  })
end

return M
