-- FILE: lua/enhanced-php-indent/extensions/custom/init.lua
-- Custom Indent Extension for enhanced-php-indent.nvim
local M = {}

-- Custom indent configuration
M.config = {
  enable_custom_indent = false,
  custom_php_indent_file = nil,
  custom_html_indent_file = nil,
  custom_indent_priority = 'plugin',
  custom_indent_debug = false,
}

-- Loaded custom indent modules
local custom_php_indent = nil
local custom_html_indent = nil

-- Load custom indent utilities
local loader = require('enhanced-php-indent.extensions.custom.loader')

-- Get custom PHP indentation
function M.get_custom_php_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, config)
  if not custom_php_indent then
    return nil
  end

  local success, indent = pcall(custom_php_indent.get_indent, {
    lnum = lnum,
    line = line_clean,
    prev_line = prev_clean,
    prev_indent = prev_indent,
    shiftwidth = sw,
    base_indent = base_indent,
    config = config
  })

  if success and type(indent) == 'number' then
    if config.custom_indent_debug then
      print("Custom PHP indent returned:", indent, "for line:", line_clean)
    end
    return indent
  end

  return nil
end

-- Get custom HTML indentation
function M.get_custom_html_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, config)
  if not custom_html_indent then
    return nil
  end

  local success, indent = pcall(custom_html_indent.get_indent, {
    lnum = lnum,
    line = line_clean,
    prev_line = prev_clean,
    prev_indent = prev_indent,
    shiftwidth = sw,
    base_indent = base_indent,
    config = config
  })

  if success and type(indent) == 'number' then
    if config.custom_indent_debug then
      print("Custom HTML indent returned:", indent, "for line:", line_clean)
    end
    return indent
  end

  return nil
end

-- Setup custom indent extension
function M.setup(config)
  -- Merge custom config
  for key, value in pairs(M.config) do
    if config[key] == nil then
      config[key] = value
    end
  end

  -- Load custom indent files if enabled
  if config.enable_custom_indent then
    custom_php_indent = loader.load_custom_indent_file(config.custom_php_indent_file, 'PHP', config.custom_indent_debug)
    custom_html_indent = loader.load_custom_indent_file(config.custom_html_indent_file, 'HTML', config.custom_indent_debug)
  end
end

return M