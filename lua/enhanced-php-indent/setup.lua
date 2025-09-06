-- FILE: lua/enhanced-php-indent/setup.lua
-- Extended Setup for enhanced-php-indent.nvim
local M = {}

-- Load the original plugin
local original = require('enhanced-php-indent')

-- Extension configuration defaults
local extension_defaults = {
  -- HTML Extension
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

  -- Custom Extension
  enable_custom_indent = false,
  custom_php_indent_file = nil,
  custom_html_indent_file = nil,
  custom_indent_priority = 'plugin',
  custom_indent_debug = false,

  -- Extension Control
  disable_extensions = false,
}

-- Merge extension defaults with user config
local function merge_config(user_config)
  local final_config = {}

  -- Start with extension defaults
  for key, value in pairs(extension_defaults) do
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

-- Extended setup function
function M.setup_with_extensions(opts)
  opts = opts or {}

  -- Merge with extension defaults
  local final_config = merge_config(opts)

  -- Call original setup first
  original.setup(final_config)

  -- Load extensions if not disabled
  if not final_config.disable_extensions then
    local success, extensions = pcall(require, 'enhanced-php-indent.extensions')
    if success then
      extensions.setup(final_config)
    end
  end
end

-- Standard setup (unchanged)
M.setup = original.setup

-- Provide access to original
M.original = original

return M