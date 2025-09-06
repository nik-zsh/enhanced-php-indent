-- FILE: lua/enhanced-php-indent/setup.lua
-- Simplified Setup for HTML embedding only (no custom indents)
local M = {}

-- Load the original plugin
local original = require('enhanced-php-indent')

-- HTML-only extension defaults
local html_defaults = {
  -- HTML Extension (ONLY)
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

-- Merge HTML defaults with user config
local function merge_config(user_config)
  local final_config = {}

  -- Start with HTML defaults
  for key, value in pairs(html_defaults) do
    final_config[key] = value
  end

  -- Override with user config
  if user_config then
    for key, value in pairs(user_config) do
      final_config[key] = value
    end
  end

  return final_config
end

-- Extended setup function (HTML only)
function M.setup_with_html(opts)
  opts = opts or {}

  -- Merge with HTML defaults
  local final_config = merge_config(opts)

  -- Call original setup FIRST (this is critical)
  original.setup(final_config)

  -- ONLY load HTML extension if explicitly enabled
  if final_config.enable_html_indent then
    local success, html_ext = pcall(require, 'enhanced-php-indent.html')
    if success then
      html_ext.setup(final_config)
    else
      vim.notify("HTML extension failed to load: " .. (html_ext or "unknown error"), vim.log.levels.WARN)
    end
  end
end

-- Standard setup (unchanged) - this ensures backward compatibility
M.setup = original.setup

-- Provide access to original
M.original = original

return M