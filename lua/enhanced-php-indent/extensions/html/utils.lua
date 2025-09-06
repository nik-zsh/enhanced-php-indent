-- FILE: lua/enhanced-php-indent/extensions/html/utils.lua
-- HTML Utilities for enhanced-php-indent.nvim
local M = {}

-- Detect current context (PHP or HTML)
function M.get_context_type(lnum)
  local search_lnum = lnum
  local in_php = false
  local max_search = 50

  -- Look backwards for PHP tags
  while search_lnum > 0 and search_lnum > (lnum - max_search) do
    local line = vim.fn.getline(search_lnum)

    -- Check for PHP opening tags
    if line:find('<%?php') or line:find('<%?=') or line:find('<%?%s') then
      in_php = true
      break
    end

    -- Check for PHP closing tags
    if line:find('%?>') then
      in_php = false
      break
    end

    search_lnum = search_lnum - 1
  end

  return in_php and 'php' or 'html'
end

-- Check if tag should indent its content
function M.should_indent_html_tag(tag_name, config)
  for _, indent_tag in ipairs(config.html_indent_tags) do
    if tag_name == indent_tag:lower() then
      return true
    end
  end
  return false
end

-- Check if tag is inline (doesn't affect indentation)
function M.is_inline_html_tag(tag_name, config)
  for _, inline_tag in ipairs(config.html_inline_tags) do
    if tag_name == inline_tag:lower() then
      return true
    end
  end
  return false
end

-- Check if tag is self-closing
function M.is_self_closing_tag(tag_name, config)
  for _, self_closing_tag in ipairs(config.html_self_closing_tags) do
    if tag_name == self_closing_tag:lower() then
      return true
    end
  end
  return false
end

return M