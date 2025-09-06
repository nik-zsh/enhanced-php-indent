-- FILE: lua/enhanced-php-indent/extensions/html/init.lua
-- HTML Extension for enhanced-php-indent.nvim
local M = {}

-- HTML configuration defaults
M.config = {
  enable_html_indent = false,
  html_indent_tags = {
    'html', 'head', 'body', 'div', 'section', 'article',
    'header', 'footer', 'nav', 'main', 'aside', 'form',
    'ul', 'ol', 'li', 'table', 'thead', 'tbody', 'tr', 'td', 'th',
    'fieldset', 'script', 'style', 'noscript', 'blockquote'
  },
  html_inline_tags = {
    'span', 'a', 'strong', 'em', 'b', 'i', 'u', 'code', 'kbd',
    'img', 'br', 'hr', 'input', 'meta', 'link', 'small', 'sub', 'sup'
  },
  html_self_closing_tags = {
    'br', 'hr', 'img', 'input', 'meta', 'link', 'area', 'base', 'wbr'
  },
  php_html_context_detection = true,
  html_preserve_php_indent = true,
  html_debug = false,
}

-- Load HTML utilities
local utils = require('enhanced-php-indent.extensions.html.utils')
local parser = require('enhanced-php-indent.extensions.html.parser')

-- Main HTML indent function
function M.get_html_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, config)
  -- Skip if HTML indentation is disabled
  if not config.enable_html_indent then
    return nil
  end

  -- Only process when in HTML context
  local context = utils.get_context_type(lnum)
  if context ~= 'html' then
    return nil
  end

  if config.html_debug then
    print("HTML Extension: Processing line " .. lnum .. " in HTML context")
  end

  -- Handle HTML closing tags
  local tag_name, tag_type = parser.parse_html_tag(line_clean)
  if tag_name and tag_type == 'closing' then
    local opening_lnum = parser.find_html_opening_tag(lnum, tag_name)
    if opening_lnum then
      return vim.fn.indent(opening_lnum) + base_indent
    else
      return math.max(prev_indent - sw, base_indent)
    end
  end

  -- Handle self-closing tags
  if tag_name and tag_type == 'self_closing' then
    return prev_indent
  end

  -- Handle content after HTML opening tags
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  if prev_lnum > 0 then
    local prev_line = vim.fn.getline(prev_lnum)
    local prev_line_clean = vim.trim(prev_line)
    local prev_tag_name, prev_tag_type = parser.parse_html_tag(prev_line_clean)

    if prev_tag_name and prev_tag_type == 'opening' then
      if utils.should_indent_html_tag(prev_tag_name, config) and not utils.is_inline_html_tag(prev_tag_name, config) then
        return vim.fn.indent(prev_lnum) + sw
      end
    end
  end

  -- Handle PHP tags within HTML context
  if line_clean:find('^<%?') then
    if config.html_preserve_php_indent then
      return prev_indent
    else
      return base_indent
    end
  end

  -- Default: maintain previous indentation in HTML context
  return prev_indent
end

-- Setup HTML extension
function M.setup(config)
  -- Merge HTML config
  for key, value in pairs(M.config) do
    if config[key] == nil then
      config[key] = value
    end
  end

  if config.html_debug then
    print("HTML Extension loaded with config:", vim.inspect(M.config))
  end
end

return M