-- enhanced-php-indent.nvim - Ultra Simple Version
local M = {}

M.config = {
  indent_function_call_parameters = false,
  enable_real_time_indent = true,
}

-- Ultra simple indent function - no complex regex
function _G.EnhancedPhpIndent()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)  
  local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
  local sw = vim.fn.shiftwidth()

  -- Simple string operations (no regex needed)
  local line_clean = vim.trim(line)
  local prev_clean = vim.trim(prev_line)

  -- Empty line in array brackets - ENHANCED FEATURE
  if line_clean == "" then
    if prev_clean:find("%[%s*$") then
      -- Check next line for closing bracket
      local next_line = vim.fn.getline(lnum + 1)  
      if vim.trim(next_line):find("^%]") then
        return prev_indent + 2 * sw  -- Double indent empty arrays
      end
    end
  end

  -- Closing brackets align with opening
  if line_clean:find("^%]") and prev_clean:find("%[%s*$") then
    return prev_indent
  end

  -- Dedent closing braces/brackets/parens
  if line_clean:find("^[%]}%)]") then
    return math.max(prev_indent - sw, 0)
  end

  -- Indent after opening braces/brackets/parens
  if prev_clean:find("{%s*$") or prev_clean:find("%[%s*$") or prev_clean:find("%(%s*$") then
    return prev_indent + sw
  end

  -- Case statements
  if line_clean:find("^case%s") or line_clean:find("^default%s*:") then
    return prev_indent
  end

  -- Indent after case
  if prev_clean:find("^case%s") or prev_clean:find("^default%s*:") then
    return prev_indent + sw
  end

  -- Basic control structures  
  if prev_clean:find("^if%s*%(") or prev_clean:find("^while%s*%(") or 
     prev_clean:find("^for%s*%(") or prev_clean:find("^function%s") then
    return prev_indent + sw
  end

  -- Method chaining
  if prev_clean:find("->") and line_clean:find("^%->") then
    return prev_indent
  end

  -- PHP tags  
  if line_clean:find("^<%?") or line_clean:find("^%?>") then
    return 0
  end

  return prev_indent
end

function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)
  require('enhanced-php-indent.indent').setup()
end

return M
