-- enhanced-php-indent.nvim - MINIMAL VERSION
local M = {}

M.config = {}

-- MINIMAL indent function - focus only on switch/case
function _G.EnhancedPhpIndent()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
  local sw = vim.fn.shiftwidth()

  local line_clean = vim.trim(line)
  local prev_clean = vim.trim(prev_line)

  -- DEBUG: Print what we're working with
  if line_clean:find("^case%s") or line_clean:find("^default%s*:") then
    print("DEBUG: Processing case/default: " .. line_clean)
    print("DEBUG: Previous line: " .. prev_clean)
    print("DEBUG: Previous indent: " .. prev_indent)
  end

  -- ULTRA SIMPLE: If this is a case/default, just add sw to previous indent
  if line_clean:find("^case%s.+:") or line_clean:find("^default%s*:") then
    -- Look for switch in last few lines
    local search_lnum = lnum - 1
    local found_switch = false
    local switch_indent = prev_indent

    -- Simple search - just look back 10 lines max
    while search_lnum > 0 and search_lnum > (lnum - 10) do
      local search_line = vim.fn.getline(search_lnum)
      local search_clean = vim.trim(search_line)

      if search_clean:find("switch%s*%(") then
        switch_indent = vim.fn.indent(search_lnum)
        found_switch = true
        print("DEBUG: Found switch at line " .. search_lnum .. ", indent: " .. switch_indent)
        break
      end

      search_lnum = search_lnum - 1
    end

    if found_switch then
      local case_indent = switch_indent + sw
      print("DEBUG: Setting case indent to: " .. case_indent)
      return case_indent
    else
      print("DEBUG: No switch found, using prev_indent + sw")
      return prev_indent + sw
    end
  end

  -- Content after case
  if prev_clean:find("^case%s.+:") or prev_clean:find("^default%s*:") then
    return prev_indent + sw
  end

  -- Break statements
  if line_clean:find("^break%s*;") then
    return prev_indent
  end

  -- Basic rules
  if line_clean:find("^%]") or line_clean:find("^[%}%)]") then
    return math.max(prev_indent - sw, 0)
  end

  if prev_clean:find("{%s*$") or prev_clean:find("%[%s*$") or prev_clean:find("%(%s*$") then
    return prev_indent + sw
  end

  if prev_clean:find("^if%s*%(") or prev_clean:find("^while%s*%(") or 
     prev_clean:find("^for%s*%(") or prev_clean:find("^function%s") then
    return prev_indent + sw
  end

  return prev_indent
end

function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)
  require('enhanced-php-indent.indent').setup()
end

return M
