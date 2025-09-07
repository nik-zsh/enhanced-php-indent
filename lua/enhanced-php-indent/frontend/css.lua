-- CSS indentation with fixed syntax
local M = {}

local function is_selector(line_clean)
  if line_clean == "" then return false end

  -- CSS selector pattern: ends with { or looks like selector
  return (line_clean:find('^%s*[%w%.#:%-%[%]%s,>+~*]+%s*{?%s*$') and 
          not line_clean:find(';%s*$') and
          not line_clean:find('^%s*}') and
          not line_clean:find('^%s*[%w%-]+%s*:'))
end

local function is_property(line_clean)
  if line_clean == "" then return false end
  return line_clean:find('^%s*[%w%-]+%s*:%s*') ~= nil
end

local function is_at_rule(line_clean)
  if line_clean == "" then return false end
  return line_clean:find('^%s*@[%w%-]+') ~= nil
end

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
    print("    CSS: '" .. line_clean .. "' prev: '" .. prev_line_clean .. "'")
  end

  -- Handle empty lines
  if line_clean == "" then
    -- If previous line was a closing brace, maintain its indentation
    if prev_line_clean:find('^%s*}') then
      return prev_indent
    end

    -- Check if we're inside a rule block
    local search_lnum = prev_lnum
    local brace_count = 0

    for i = search_lnum, math.max(1, search_lnum - 10), -1 do
      local search_line = vim.fn.getline(i)
      if search_line then
        local search_clean = vim.trim(search_line)
        for char in search_clean:gmatch('.') do
          if char == '}' then 
            brace_count = brace_count - 1
          elseif char == '{' then 
            brace_count = brace_count + 1
          end
        end

        if brace_count > 0 then
          return prev_indent
        elseif search_clean:find('{%s*$') then
          return vim.fn.indent(i) + sw + base_indent
        end
      end
    end

    return prev_indent
  end

  -- Handle closing braces
  if line_clean:find('^%s*}') then
    -- Find matching opening brace
    local search_lnum = lnum - 1
    local brace_count = 1

    for i = search_lnum, math.max(1, search_lnum - 20), -1 do
      local search_line = vim.fn.getline(i)
      if search_line then
        local search_clean = vim.trim(search_line)
        for char in search_clean:gmatch('.') do
          if char == '}' then 
            brace_count = brace_count + 1
          elseif char == '{' then 
            brace_count = brace_count - 1
          end
        end

        if brace_count == 0 then
          return vim.fn.indent(i) + base_indent
        end
      end
    end

    return math.max(prev_indent - sw, base_indent)
  end

  -- FIXED: Don't indent after closing braces
  if prev_line_clean:find('^%s*}') then
    if is_selector(line_clean) or is_at_rule(line_clean) then
      return base_indent
    end
    return prev_indent
  end

  -- Handle properties
  if is_property(line_clean) then
    -- Find containing selector
    local search_lnum = prev_lnum

    for i = search_lnum, math.max(1, search_lnum - 10), -1 do
      local search_line = vim.fn.getline(i)
      if search_line then
        local search_clean = vim.trim(search_line)

        if search_clean:find('{%s*$') then
          return vim.fn.indent(i) + sw + base_indent
        end

        if is_selector(search_clean) or is_at_rule(search_clean) then
          return vim.fn.indent(i) + sw + base_indent
        end
      end
    end

    return prev_indent + sw + base_indent
  end

  -- Handle content after opening braces
  if prev_line_clean:find('{%s*$') then
    return prev_indent + sw + base_indent
  end

  -- Handle selectors
  if is_selector(line_clean) then
    -- Check for nesting
    local search_lnum = prev_lnum
    local brace_count = 0

    for i = search_lnum, math.max(1, search_lnum - 10), -1 do
      local search_line = vim.fn.getline(i)
      if search_line then
        local search_clean = vim.trim(search_line)
        for char in search_clean:gmatch('.') do
          if char == '}' then 
            brace_count = brace_count - 1
          elseif char == '{' then 
            brace_count = brace_count + 1
          end
        end

        if brace_count > 0 then
          return prev_indent
        end
      end
    end

    return base_indent
  end

  -- Handle at-rules
  if is_at_rule(line_clean) then
    return base_indent
  end

  return prev_indent
end

return M
