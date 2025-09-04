-- enhanced-php-indent.nvim - Enhanced Case/Break Handling
local M = {}

M.config = {
  indent_function_call_parameters = false,
  enable_real_time_indent = true,
  vintage_case_default_indent = false,
}

-- Helper function to find switch statement and its indent level
local function find_switch_indent(lnum)
  local search_lnum = lnum - 1
  local brace_count = 0

  while search_lnum > 0 do
    local line = vim.fn.getline(search_lnum)
    local line_clean = vim.trim(line)

    -- Count braces to stay in same block level
    local open_braces = select(2, line_clean:gsub("{", ""))
    local close_braces = select(2, line_clean:gsub("}", ""))
    brace_count = brace_count + close_braces - open_braces

    -- Found switch at our block level
    if brace_count == 0 and line_clean:find("switch%s*%(") then
      return vim.fn.indent(search_lnum)
    end

    -- Stop if we go too far up in block structure
    if brace_count > 0 then
      break
    end

    search_lnum = search_lnum - 1
  end

  return nil
end

-- Helper function to find the most recent case/default statement
local function find_recent_case_indent(lnum)
  local search_lnum = lnum - 1

  while search_lnum > 0 do
    local line = vim.fn.getline(search_lnum)
    local line_clean = vim.trim(line)

    -- Found case or default
    if line_clean:find("^case%s.+:") or line_clean:find("^default%s*:") then
      return vim.fn.indent(search_lnum)
    end

    -- Stop if we hit switch or closing brace
    if line_clean:find("switch%s*%(") or line_clean:find("^}") then
      break
    end

    search_lnum = search_lnum - 1
  end

  return nil
end

-- Enhanced indent function with proper case/break handling
function _G.EnhancedPhpIndent()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
  local sw = vim.fn.shiftwidth()

  local line_clean = vim.trim(line)
  local prev_clean = vim.trim(prev_line)

  -- Empty line in array brackets - ENHANCED FEATURE  
  if line_clean == "" then
    if prev_clean:find("%[%s*$") then
      local next_line = vim.fn.getline(lnum + 1)
      if vim.trim(next_line):find("^%]") then
        return prev_indent + 2 * sw
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

  -- ENHANCED SWITCH/CASE/BREAK HANDLING

  -- Case and default statements
  if line_clean:find("^case%s.+:") or line_clean:find("^default%s*:") then
    local switch_indent = find_switch_indent(lnum)
    if switch_indent then
      if M.config.vintage_case_default_indent then
        return switch_indent  -- Vintage: case at switch level
      else
        return switch_indent + sw  -- Modern: case indented from switch
      end
    end
    return prev_indent  -- Fallback
  end

  -- Break statements - align with case content
  if line_clean:find("^break%s*;") then
    local case_indent = find_recent_case_indent(lnum)
    if case_indent then
      return case_indent + sw  -- Break aligns with case content
    end
  end

  -- Statements immediately after case/default
  if prev_clean:find("^case%s.+:") or prev_clean:find("^default%s*:") then
    return prev_indent + sw
  end

  -- Other statements inside switch block
  local switch_indent = find_switch_indent(lnum)
  if switch_indent then
    local case_indent = find_recent_case_indent(lnum)
    if case_indent then
      -- We're inside a case block
      if not line_clean:find("^case%s") and not line_clean:find("^default%s*:") and not line_clean:find("^}") then
        return case_indent + sw
      end
    end
  end

  -- Indent after opening braces/brackets/parens
  if prev_clean:find("{%s*$") or prev_clean:find("%[%s*$") or prev_clean:find("%(%s*$") then
    return prev_indent + sw
  end

  -- Basic control structures
  if prev_clean:find("^if%s*%(") or prev_clean:find("^while%s*%(") or 
     prev_clean:find("^for%s*%(") or prev_clean:find("^function%s") or
     prev_clean:find("^class%s") then
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
