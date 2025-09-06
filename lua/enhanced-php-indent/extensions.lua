-- FILE: lua/enhanced-php-indent/extensions.lua
-- Main Extensions Coordinator for enhanced-php-indent.nvim
local M = {}

-- Load extension modules (safely)
local function safe_require(module_name)
  local success, module = pcall(require, module_name)
  if success then
    return module
  else
    return nil
  end
end

-- Load extensions
local html_ext = safe_require('enhanced-php-indent.extensions.html')
local custom_ext = safe_require('enhanced-php-indent.extensions.custom')

-- Enhanced indent function that includes extensions
function M.create_extended_indent_function(original_config)
  return function()
    local lnum = vim.v.lnum
    local line = vim.fn.getline(lnum)
    local prev_lnum = vim.fn.prevnonblank(lnum - 1)
    local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
    local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
    local sw = vim.fn.shiftwidth()

    local line_clean = vim.trim(line)
    local prev_clean = vim.trim(prev_line)
    local base_indent = original_config.default_indenting or 0

    -- Priority system
    local priority = original_config.custom_indent_priority or 'plugin'

    -- Try custom indent first if priority is 'custom'
    if priority == 'custom' and custom_ext then
      local custom_php_result = custom_ext.get_custom_php_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, original_config)
      if custom_php_result then return custom_php_result end

      local custom_html_result = custom_ext.get_custom_html_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, original_config)
      if custom_html_result then return custom_html_result end
    end

    -- Try HTML indentation
    if html_ext then
      local html_result = html_ext.get_html_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, original_config)
      if html_result then return html_result end
    end

    -- Try custom indent as fallback if priority is 'mixed'
    if priority == 'mixed' and custom_ext then
      local custom_php_result = custom_ext.get_custom_php_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, original_config)
      if custom_php_result then return custom_php_result end

      local custom_html_result = custom_ext.get_custom_html_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, original_config)
      if custom_html_result then return custom_html_result end
    end

    -- Fallback to original PHP indentation
    return _G.EnhancedPhpIndentOriginal()
  end
end

-- Setup all extensions
function M.setup(config)
  -- Setup HTML extension
  if html_ext then
    html_ext.setup(config)
  end

  -- Setup custom extension  
  if custom_ext then
    custom_ext.setup(config)
  end

  -- Replace the global indent function with extended version if extensions are enabled
  if config.enable_html_indent or config.enable_custom_indent then
    -- Store original function
    if not _G.EnhancedPhpIndentOriginal then
      _G.EnhancedPhpIndentOriginal = _G.EnhancedPhpIndent
    end

    -- Replace with extended function
    _G.EnhancedPhpIndent = M.create_extended_indent_function(config)
  end
end

return M