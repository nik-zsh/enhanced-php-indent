-- HTML indentation (CLEAN SYNTAX)
local M = {}

local function is_block_tag(tag_name, config)
  if not tag_name then 
    return false 
  end
  for _, block_tag in ipairs(config.html_indent_tags) do
    if tag_name:lower() == block_tag:lower() then 
      return true 
    end
  end
  return false
end

local function is_self_closing_tag(tag_name, config)
  if not tag_name then 
    return false 
  end
  for _, self_closing in ipairs(config.html_self_closing_tags) do
    if tag_name:lower() == self_closing:lower() then 
      return true 
    end
  end
  return false
end

local function is_inline_tag(tag_name, config)
  if not tag_name then 
    return false 
  end
  for _, inline_tag in ipairs(config.html_inline_tags) do
    if tag_name:lower() == inline_tag:lower() then 
      return true 
    end
  end
  return false
end

local function parse_tag(line_clean)
  if not line_clean or line_clean == "" then 
    return nil, nil 
  end

  -- Closing tag
  local closing_tag = line_clean:match('^%s*</%s*([%w%-]+)')
  if closing_tag then 
    return closing_tag, 'closing' 
  end

  -- Self-closing tag
  local self_closing = line_clean:match('^%s*<%s*([%w%-]+)[^>]*/%s*>')
  if self_closing then 
    return self_closing, 'self_closing' 
  end

  -- Opening tag
  local opening_tag = line_clean:match('^%s*<%s*([%w%-]+)')
  if opening_tag then 
    return opening_tag, 'opening' 
  end

  return nil, nil
end

function M.get_indent(lnum, config)
  local line = vim.fn.getline(lnum)
  if not line then 
    return nil 
  end

  local line_clean = vim.trim(line)
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
  local sw = vim.fn.shiftwidth()
  local base_indent = config.default_indenting or 0

  if config.frontend_debug then
    print("    HTML: line='" .. line_clean .. "'")
  end

  -- Handle empty lines
  if line_clean == "" then 
    return prev_indent 
  end

  -- Handle PHP code
  if line_clean:find('^%s*<%?') or line_clean:find('^%s*%?>') then
    return prev_indent
  end

  local tag_name, tag_type = parse_tag(line_clean)

  -- Handle closing tags
  if tag_name and tag_type == 'closing' then
    if is_block_tag(tag_name, config) then
      -- Find matching opening tag
      local search_lnum = lnum - 1
      local tag_count = 1

      for i = search_lnum, math.max(1, search_lnum - 30), -1 do
        local search_line = vim.fn.getline(i)
        if search_line then
          local search_clean = vim.trim(search_line)
          if search_clean ~= "" and not search_clean:find('^%s*<%?') then
            local search_tag, search_type = parse_tag(search_clean)
            if search_tag and search_tag:lower() == tag_name:lower() then
              if search_type == 'closing' then
                tag_count = tag_count + 1
              elseif search_type == 'opening' then
                tag_count = tag_count - 1
                if tag_count == 0 then
                  return vim.fn.indent(i) + base_indent
                end
              end
            end
          end
        end
      end

      return math.max(prev_indent - sw, base_indent)
    else
      return prev_indent
    end
  end

  -- Handle self-closing tags
  if tag_name and tag_type == 'self_closing' then
    return prev_indent
  end

  -- Handle content after opening tags
  if prev_lnum > 0 then
    local prev_line = vim.fn.getline(prev_lnum)
    if prev_line then
      local prev_line_clean = vim.trim(prev_line)
      local prev_tag_name, prev_tag_type = parse_tag(prev_line_clean)

      if prev_tag_name and prev_tag_type == 'opening' then
        if is_block_tag(prev_tag_name, config) and not is_inline_tag(prev_tag_name, config) then
          return vim.fn.indent(prev_lnum) + sw + base_indent
        end
      end
    end
  end

  -- Handle DOCTYPE
  if line_clean:find('^%s*<!DOCTYPE') then
    return base_indent
  end

  return prev_indent
end

return M
