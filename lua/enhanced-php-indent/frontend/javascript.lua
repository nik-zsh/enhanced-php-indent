-- JavaScript indentation (CLEAN SYNTAX)
local M = {}

local function is_function_declaration(line_clean)
  return (line_clean:find('^%s*function%s+') or
          line_clean:find('^%s*[%w_$]+%s*:%s*function') or
          line_clean:find('^%s*[%w_$]+%s*=%s*function') or
          line_clean:find('=>%s*{?%s*$'))
end

local function is_control_structure(line_clean)
  return (line_clean:find('^%s*if%s*%(') or
          line_clean:find('^%s*else%s*if%s*%(') or
          line_clean:find('^%s*else%s*{?%s*$') or
          line_clean:find('^%s*for%s*%(') or
          line_clean:find('^%s*while%s*%(') or
          line_clean:find('^%s*do%s*{?%s*$') or
          line_clean:find('^%s*switch%s*%(') or
          line_clean:find('^%s*try%s*{?%s*$') or
          line_clean:find('^%s*catch%s*%(') or
          line_clean:find('^%s*finally%s*{?%s*$'))
end

local function is_case_statement(line_clean)
  return (line_clean:find('^%s*case%s+') or line_clean:find('^%s*default%s*:'))
end

-- Find switch statement
local function find_switch_statement(lnum)
  for i = lnum - 1, math.max(1, lnum - 20), -1 do
    local line = vim.fn.getline(i)
    if line then
      local line_clean = vim.trim(line)
      if line_clean:find('switch%s*%(') then
        return i
      end
    end
  end
  return nil
end

function M.get_indent(lnum, config)
  local line = vim.fn.getline(lnum)
  if not line then 
    return nil 
  end

  local line_clean = vim.trim(line)
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
  local prev_line_clean = vim.trim(prev_line)
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
  local sw = vim.fn.shiftwidth()
  local base_indent = config.default_indenting or 0

  if config.frontend_debug then
    print("    JS: line='" .. line_clean .. "' prev='" .. prev_line_clean .. "'")
  end

  -- Handle empty lines
  if line_clean == "" then
    return prev_indent
  end

  -- Handle closing braces
  if line_clean:find('^%s*}') then
    -- Find matching opening brace
    local search_lnum = lnum - 1
    local brace_count = 1

    for i = search_lnum, math.max(1, search_lnum - 30), -1 do
      local search_line = vim.fn.getline(i)
      if search_line then
        for char in search_line:gmatch('.') do
          if char == '}' then 
            brace_count = brace_count + 1
          elseif char == '{' then 
            brace_count = brace_count - 1
            if brace_count == 0 then
              return vim.fn.indent(i) + base_indent
            end
          end
        end
      end
    end

    return math.max(prev_indent - sw, base_indent)
  end

  -- Handle case and default statements
  if config.js_indent_switch_case and is_case_statement(line_clean) then
    local switch_lnum = find_switch_statement(lnum)
    if switch_lnum then
      return vim.fn.indent(switch_lnum) + sw + base_indent
    else
      return prev_indent
    end
  end

  -- Handle break statements
  if line_clean:find('^%s*break%s*;') or line_clean:find('^%s*return%s') then
    for i = lnum - 1, math.max(1, lnum - 15), -1 do
      local search_line = vim.fn.getline(i)
      if search_line then
        local search_clean = vim.trim(search_line)
        if is_case_statement(search_clean) then
          return vim.fn.indent(i) + sw + base_indent
        end
      end
    end
    return prev_indent
  end

  -- Handle content after case/default
  if is_case_statement(prev_line_clean) then
    return prev_indent + sw + base_indent
  end

  -- Handle content after opening braces
  if prev_line_clean:find('{%s*$') then
    return prev_indent + sw + base_indent
  end

  -- Handle control structures
  if is_control_structure(prev_line_clean) and not prev_line_clean:find('{%s*$') then
    return prev_indent + sw + base_indent
  end

  -- Handle function declarations
  if config.js_indent_functions and is_function_declaration(prev_line_clean) then
    if not prev_line_clean:find('{%s*$') then
      return prev_indent + sw + base_indent
    end
  end

  -- Handle object literals and arrays
  if prev_line_clean:find('[%[{]%s*$') then
    return prev_indent + sw + base_indent
  end

  return prev_indent
end

return M
