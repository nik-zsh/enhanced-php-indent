-- CSS indentation for enhanced-php-indent.nvim (IMPROVED - better brace handling)
local M = {}

-- Check if line is a CSS selector
local function is_selector(line_clean)
  -- More accurate selector detection
  if line_clean:match('^[%w%.#:%-%[%]%s,>+~*]+%s*{?%s*$') and 
     not line_clean:match(';%s*$') and
     not line_clean:match('^%s*}') and
     not line_clean:match('^[%w%-]+%s*:') then -- Not a property
    return true
  end
  return false
end

-- Check if line is a CSS property
local function is_property(line_clean)
  return line_clean:match('^[%w%-]+%s*:%s*') ~= nil
end

-- Check if line is an at-rule (@media, @keyframes, etc.)
local function is_at_rule(line_clean)
  return line_clean:match('^@[%w%-]+') ~= nil
end

-- Find matching opening brace
local function find_opening_brace(lnum)
  local search_lnum = lnum - 1
  local brace_count = 1
  local max_search = 100

  while search_lnum > 0 and brace_count > 0 and (lnum - search_lnum) < max_search do
    local line = vim.fn.getline(search_lnum)
    local line_clean = vim.trim(line)

    if line_clean ~= "" then
      for char in line_clean:gmatch('.') do
        if char == '}' then
          brace_count = brace_count + 1
        elseif char == '{' then
          brace_count = brace_count - 1
          if brace_count == 0 then
            return search_lnum
          end
        end
      end
    end

    search_lnum = search_lnum - 1
  end

  return nil
end

-- IMPROVED: Main CSS indentation function with better brace handling
function M.get_indent(lnum, config)
  local line = vim.fn.getline(lnum)
  local line_clean = vim.trim(line)
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
  local prev_line_clean = vim.trim(prev_line)
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
  local sw = vim.fn.shiftwidth()
  local base_indent = config.default_indenting or 0

  -- Handle empty lines - IMPROVED: inherit from context
  if line_clean == "" then
    -- Check if we're inside a CSS rule block
    local search_lnum = prev_lnum
    local brace_count = 0

    while search_lnum > 0 and search_lnum > (lnum - 20) do
      local search_line = vim.trim(vim.fn.getline(search_lnum))
      for char in search_line:gmatch('.') do
        if char == '}' then brace_count = brace_count - 1
        elseif char == '{' then brace_count = brace_count + 1
        end
      end

      if brace_count > 0 then
        -- We're inside a rule, maintain the indentation of properties
        return prev_indent
      elseif search_line:match('{%s*$') then
        -- Previous line opened a block, indent for properties
        return vim.fn.indent(search_lnum) + sw + base_indent
      end

      search_lnum = search_lnum - 1
    end

    return prev_indent
  end

  -- Handle closing braces
  if line_clean:match('^}') then
    local opening_lnum = find_opening_brace(lnum)
    if opening_lnum then
      return vim.fn.indent(opening_lnum) + base_indent
    else
      return math.max(prev_indent - sw, base_indent)
    end
  end

  -- IMPROVED: Handle properties inside rules with better detection
  if is_property(line_clean) then
    -- Look backwards to find the containing selector
    local search_lnum = prev_lnum
    local search_limit = math.max(1, lnum - 50)

    while search_lnum >= search_limit do
      local search_line = vim.trim(vim.fn.getline(search_lnum))

      -- Found opening brace - indent from it
      if search_line:match('{%s*$') then
        return vim.fn.indent(search_lnum) + sw + base_indent
      end

      -- Found selector - indent from it
      if is_selector(search_line) or is_at_rule(search_line) then
        return vim.fn.indent(search_lnum) + sw + base_indent
      end

      search_lnum = search_lnum - 1
    end

    -- Fallback
    return prev_indent + sw + base_indent
  end

  -- IMPROVED: Handle content after opening braces
  if prev_line_clean:match('{%s*$') then
    return prev_indent + sw + base_indent
  end

  -- Handle selectors (including the line that will have opening brace)
  if is_selector(line_clean) then
    -- Check if we're inside a nested rule
    local search_lnum = prev_lnum
    local brace_count = 0
    local search_limit = math.max(1, lnum - 50)

    while search_lnum >= search_limit do
      local search_line = vim.trim(vim.fn.getline(search_lnum))
      for char in search_line:gmatch('.') do
        if char == '}' then brace_count = brace_count - 1
        elseif char == '{' then brace_count = brace_count + 1
        end
      end

      if brace_count > 0 then
        -- Inside a rule block - this is a nested selector
        return prev_indent + sw + base_indent
      end

      search_lnum = search_lnum - 1
    end

    -- Top-level selector
    return base_indent
  end

  -- Handle at-rules
  if is_at_rule(line_clean) and config.css_indent_at_rules then
    return base_indent
  end

  -- Handle selectors after at-rules
  if is_at_rule(prev_line_clean) and config.css_indent_at_rules then
    if not prev_line_clean:match('{%s*$') then
      return prev_indent + sw + base_indent
    end
  end

  -- Handle multi-line selectors
  if is_selector(line_clean) and is_selector(prev_line_clean) then
    return prev_indent
  end

  -- Handle vendor prefixes (align with previous property)
  if line_clean:match('^%-[%w%-]+%-') and is_property(prev_line_clean) then
    return prev_indent
  end

  -- Default: maintain previous indentation
  return prev_indent
end

return M
