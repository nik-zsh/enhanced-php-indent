<!-- FILE: docs/extensions/CUSTOM-INDENT.md -->
# Custom Indent Guide

## Overview

The custom indent system allows you to define your own indentation rules for PHP and HTML code. Perfect for project-specific requirements, coding standards, or framework-specific patterns.

## Creating Custom Indent Files

### File Structure
Custom indent files must return a table with a `get_indent` function:

```lua
local M = {}

function M.get_indent(context)
  -- Your custom logic here
  -- Return number for custom indent, or nil to let plugin handle
end

-- Optional setup function
function M.setup(config)
  -- Initialize your custom rules
end

return M
```

### Context Object
The `context` parameter contains:
- `lnum` - Current line number
- `line` - Current line content (trimmed)
- `prev_line` - Previous line content (trimmed)  
- `prev_indent` - Previous line indentation level
- `shiftwidth` - Vim's shiftwidth setting
- `base_indent` - Plugin's base indentation
- `config` - Full plugin configuration

## Examples

### Laravel-Specific Rules
```lua
-- ~/.config/nvim/laravel-indent.lua
local M = {}

function M.get_indent(context)
  local line = context.line
  local prev_indent = context.prev_indent
  local sw = context.shiftwidth

  -- Blade directives at column 0
  if line:find('^@') then
    return 0
  end

  -- Laravel array syntax
  if context.prev_line:find('%[%s*$') and line:find("^['"]") then
    return prev_indent + sw + 4
  end

  return nil
end

return M
```

## Configuration

```lua
require("enhanced-php-indent.setup").setup_with_extensions({
  enable_custom_indent = true,
  custom_php_indent_file = "~/.config/nvim/my-php-indent.lua",
  custom_html_indent_file = "~/.config/nvim/my-html-indent.lua",
  custom_indent_priority = 'mixed',  -- 'plugin'|'custom'|'mixed'
  custom_indent_debug = true,        -- Show loading messages
})
```

### Priority Modes
- **'plugin'**: Plugin rules first, then custom as fallback
- **'custom'**: Custom rules first, then plugin as fallback  
- **'mixed'**: Try both, custom as final fallback

## Best Practices

### Return Values
- Return `number` for custom indentation
- Return `nil` to let plugin handle the line
- Never return negative numbers

### Error Handling
- Wrap complex logic in `pcall()` if needed
- Use `context.config.custom_indent_debug` for conditional logging
- Handle edge cases gracefully

## Troubleshooting

### File Not Loading
- Check file path exists: `vim.fn.filereadable(path)`
- Enable debug: `custom_indent_debug = true`
- Check `:messages` for error details

### Rules Not Applied
- Verify function returns number, not nil
- Check priority setting matches expectation
- Use debug prints to trace execution
