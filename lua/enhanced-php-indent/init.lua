-- enhanced-php-indent.nvim - Simple & Reliable
local M = {}

M.config = {
  indent_function_call_parameters = false,
  enable_real_time_indent = true,
  vintage_case_default_indent = false,
}

-- Simple switch detection - just look for "switch" keyword
local function is_in_switch_block(lnum)
  local search_lnum = lnum - 1
  local switch_found = false
  local brace_level = 0

  while search_lnum > 0 and search_lnum > (lnum - 50) do  -- Don't search too far
    local line = vim.fn.getline(search_lnum)
    local line_clean = vim.trim(line)

    -- Count braces to track block level
    for char in line_clean:gmatch(".") do
      if char == "}" then
        brace_level = brace_level + 1
      elseif char == "{" then
        brace_level = brace_level - 1
      end
    end

    -- Found switch at our level
    if brace_level == 0 and line_clean:find("switch%s*%(") then
      switch_found = true
      return vim.fn.indent(search_lnum)
    end

    -- Stop if we've gone up a block level
    if brace_level > 0 then
      break
    end

    search_lnum = search_lnum - 1
  end

  return nil
end

-- SIMPLE indent function
function _G.EnhancedPhpIndent()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
  local sw = vim.fn.shiftwidth()

  local line_clean = vim.trim(line)
  local prev_clean = vim.trim(prev_line)

  -- ENHANCED ARRAY FEATURE (working)
  if line_clean == "" then
    if prev_clean:find("%[%s*$") then
      local next_line = vim.fn.getline(lnum + 1)
      if vim.trim(next_line):find("^%]") then
        return prev_indent + 2 * sw
      end
    end
  end

  if line_clean:find("^%]") and prev_clean:find("%[%s*$") then
    return prev_indent
  end

  -- Dedent closing braces/brackets/parens
  if line_clean:find("^[%]}%)]") then
    return math.max(prev_indent - sw, 0)
  end

  -- SIMPLE SWITCH/CASE LOGIC

  -- Case/default statements: indent from switch
  if line_clean:find("^case%s.+:") or line_clean:find("^default%s*:") then
    local switch_indent = is_in_switch_block(lnum)
    if switch_indent ~= nil then
      -- FIXED: Always indent case from switch
      return switch_indent + sw
    else
      -- Fallback: indent from previous line
      return prev_indent
    end
  end

  -- Break statements: same level as case content
  if line_clean:find("^break%s*;") then
    -- Simple logic: if previous non-blank line is case, indent from it
    if prev_clean:find("^case%s.+:") or prev_clean:find("^default%s*:") then
      return prev_indent + sw
    else
      -- Otherwise, same as previous line
      return prev_indent
    end
  end

  -- Content after case/default
  if prev_clean:find("^case%s.+:") or prev_clean:find("^default%s*:") then
    return prev_indent + sw
  end

  -- Basic indentation rules (working)
  if prev_clean:find("{%s*$") or prev_clean:find("%[%s*$") or prev_clean:find("%(%s*$") then
    return prev_indent + sw
  end

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
