-- CSS indentation for enhanced-php-indent.nvim (ROBUST)
local M = {}

-- Check if line is a CSS selector
local function is_selector(line_clean)
  if line_clean == "" then return false end

  if line_clean:match('^[%w%.#:%-%[%]%s,>+~*]+%s*{?%s*$') and 
     not line_clean:match(';%s*$') and
     not line_clean:match('^%s*}') and
     not line_clean:match('^[%w%-]+%s*:') then
    return true
  end
  return false
end

-- Check if line is a CSS property
local function is_property(line_clean)
  if line_clean == "" then return false end
  return line_clean:match('^[%w%-]+%s*:%s*') ~= nil
end

-- Check if line is an at-rule
local function is_at_rule(line_clean)
  if line_clean == "" then return false end
  return line_clean:match('^@[%w%-]+') ~= nil
end

-- Find matching opening brace
local function find_opening_brace(lnum)
  local search_lnum = lnum - 1
  local brace_count = 1
  local max_search = 100

  while search_lnum > 0 and brace_count > 0 and (lnum - search_lnum) < max_search do
    local line = vim.fn.getline(search_lnum)
    if not line then break end

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

-- Main CSS indentation function with debugging
function M.get_indent(lnum, config)
  local line = vim.fn.getline(lnum)
  if not line then return nil end

  local line_clean = vim.trim(line)
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
  local prev_line_clean = vim.trim(prev_line)
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
  local sw = vim.fn.shiftwidth()
  local base_indent = config.default_indenting or 0

  if config.frontend_debug then
    print("    CSS processing line: '" .. line_clean .. "'")
  end

  -- Handle empty lines
  if line_clean == "" then
    -- Check if we're inside a CSS rule block
    local search_lnum = prev_lnum
    local brace_count = 0

    while search_lnum > 0 and search_lnum > (lnum - 20) do
      local search_line = vim.fn.getline(search_lnum)
      if search_line then
        local search_clean = vim.trim(search_line)
        for char in search_clean:gmatch('.') do
          if char == '}' then brace_count = brace_count - 1
          elseif char == '{' then brace_count = brace_count + 1
          end
        end

        if brace_count > 0 then
          return prev_indent + sw + base_indent
        elseif search_clean:match('{%s*$') then
          return vim.fn.indent(search_lnum) + sw + base_indent
        end
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

  -- Handle properties inside rules
  if is_property(line_clean) then
    if config.frontend_debug then
      print("    CSS property detected: " .. line_clean)
    end

    local search_lnum = prev_lnum
    local search_limit = math.max(1, lnum - 50)

    while search_lnum >= search_limit do
      local search_line = vim.fn.getline(search_lnum)
      if search_line then
        local search_clean = vim.trim(search_line)

        if search_clean:match('{%s*$') then
          return vim.fn.indent(search_lnum) + sw + base_indent
        end

        if is_selector(search_clean) or is_at_rule(search_clean) then
          return vim.fn.indent(search_lnum) + sw + base_indent
        end
      end

      search_lnum = search_lnum - 1
    end

    return prev_indent + sw + base_indent
  end

  -- Handle content after opening braces
  if prev_line_clean:match('{%s*$') then
    if config.frontend_debug then
      print("    CSS content after opening brace")
    end
    return prev_indent + sw + base_indent
  end

  -- Handle selectors
  if is_selector(line_clean) then
    if config.frontend_debug then
      print("    CSS selector detected: " .. line_clean)
    end

    -- Check if we're inside a nested rule
    local search_lnum = prev_lnum
    local brace_count = 0
    local search_limit = math.max(1, lnum - 50)

    while search_lnum >= search_limit do
      local search_line = vim.fn.getline(search_lnum)
      if search_line then
        local search_clean = vim.trim(search_line)
        for char in search_clean:gmatch('.') do
          if char == '}' then brace_count = brace_count - 1
          elseif char == '{' then brace_count = brace_count + 1
          end
        end

        if brace_count > 0 then
          return prev_indent + sw + base_indent
        end
      end

      search_lnum = search_lnum - 1
    end

    return base_indent
  end

  -- Handle at-rules
  if is_at_rule(line_clean) then
    if config.frontend_debug then
      print("    CSS at-rule detected: " .. line_clean)
    end
    return base_indent
  end

  -- Default: maintain previous indentation
  return prev_indent
end

return M
