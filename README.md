# enhanced-php-indent.nvim

[![License: Unlicense](https://img.shields.io/badge/License-Unlicense-blue.svg)](https://unlicense.org/)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-green.svg)](https://neovim.io)

A comprehensive PHP indentation plugin for Neovim that combines the robustness of the official `php.vim` indent script with modern enhancements and real-time features.

## ✨ Features

### 🚀 Enhanced Indentation
- **Smart Array Handling**: Proper bracket alignment and blank line indentation
- **Switch/Case Optimization**: Improved switch statement indentation with vintage mode support  
- **Method Chaining**: Perfect for Laravel Eloquent and fluent interfaces
- **Function Parameters**: Configurable indentation for calls and declarations

### ⚡ Real-time Features  
- **Auto-indentation**: Automatic fixes on `InsertLeave` events
- **Live Bracket Matching**: Real-time alignment of closing brackets
- **Performance Optimized**: Efficient algorithms for large files

### 🛠️ Highly Configurable
- **12+ Options**: Flexible configuration for different coding standards
- **PSR-12 Compliant**: Full support for modern PHP standards
- **Laravel Optimized**: Enhanced for Laravel development patterns
- **Legacy Support**: Vintage mode for older codebases

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (Recommended)

```lua
{
  "nik-zsh/enhanced-php-indent.nvim",
  ft = "php",
  config = function()
    require("enhanced-php-indent").setup({
      indent_function_call_parameters = true,
      enable_real_time_indent = true,
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "nik-zsh/enhanced-php-indent.nvim",
  ft = "php", 
  config = function()
    require("enhanced-php-indent").setup()
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nik-zsh/enhanced-php-indent.nvim'
```

Then add to your `init.lua`:
```lua
require("enhanced-php-indent").setup()
```

## ⚙️ Configuration

### Default Configuration

```lua
require("enhanced-php-indent").setup({
  -- Basic indentation settings
  default_indenting = 0,                      -- Extra base indentation (default: 0)
  braces_at_code_level = false,               -- Put braces at same level as code

  -- Function parameter handling
  indent_function_call_parameters = false,    -- Indent function call parameters
  indent_function_declaration_parameters = false, -- Indent function declaration parameters

  -- Comment and formatting
  autoformat_comment = true,                  -- Auto-format comments
  outdent_sl_comments = 0,                    -- Outdent single-line comments

  -- PHP-specific features
  outdent_php_escape = true,                  -- Outdent <?php and ?> tags
  remove_cr_when_unix = false,                -- Remove CR characters on Unix

  -- Advanced indentation
  no_arrow_matching = false,                  -- Disable -> method chaining indentation
  vintage_case_default_indent = false,        -- Use old-style case/default indentation

  -- Enhanced features
  enable_real_time_indent = true,             -- Enable auto-indentation on insert
  smart_array_indent = true,                  -- Enhanced array handling
})
```

### Configuration Presets

#### PSR-12 Compliant (Recommended)
```lua
require("enhanced-php-indent").setup({
  indent_function_call_parameters = true,
  indent_function_declaration_parameters = true,
  braces_at_code_level = false,
  autoformat_comment = true,
  enable_real_time_indent = true,
})
```

#### Laravel Development
```lua  
require("enhanced-php-indent").setup({
  braces_at_code_level = true,           -- Laravel style braces
  indent_function_call_parameters = true,
  no_arrow_matching = false,             -- Enable method chaining
  enable_real_time_indent = true,
})
```

#### WordPress/Legacy Projects
```lua
require("enhanced-php-indent").setup({
  vintage_case_default_indent = true,    -- Old-style case indentation
  braces_at_code_level = false,
  enable_real_time_indent = false,       -- Less aggressive
  default_indenting = 4,                 -- Extra base indentation
})
```

## 🎯 Usage Examples

### Array Indentation
```php  
<?php
$config = [
    'database' => [
        'host' => 'localhost',
        'nested' => [

            // This blank line gets properly double-indented automatically
        ],
    ],
    'cache' => 'redis',
];  // Bracket aligns with $config line
```

### Switch Statements
```php
<?php
switch ($status) {
    case 'pending':
        processOrder($order);
        sendNotification($user);
        break;

    case 'completed':
        finalizeOrder($order);
        updateInventory($order->items);
        break;

    default:
        logError('Unknown status: ' . $status);
        handleError();
        break;
}
```

### Method Chaining (Laravel Style)
```php
<?php
$users = User::where('active', true)
    ->whereHas('profile', function($query) {
        $query->where('verified', true);
    })
    ->orderBy('created_at', 'desc')
    ->limit(10)
    ->get();
```

### Function Parameters
```php
<?php
function createUser(
    string $name,
    string $email,
    array $options = [],
    bool $sendWelcomeEmail = true
): User {
    return new User($name, $email, $options);
}

$user = createUser(
    'John Doe',
    'john@example.com',
    ['role' => 'admin'],
    true
);
```

## 🚀 Available Commands

- `:PHPIndentStatus` - Show plugin status, configuration, and debug info
- `:PHPIndentTest` - Test indentation on current file (equivalent to `gg=G`)
- `:PHPIndentReload` - Reload plugin configuration

## 🔧 Advanced Usage

### Project-Specific Configuration
```lua
-- Different settings based on project
local function setup_php_indent_for_project()
  local cwd = vim.fn.getcwd()

  if cwd:match("laravel") then
    require("enhanced-php-indent").setup({
      braces_at_code_level = true,
      no_arrow_matching = false,
    })
  elseif cwd:match("wordpress") then
    require("enhanced-php-indent").setup({
      vintage_case_default_indent = true,
      default_indenting = 4,
    })
  else
    require("enhanced-php-indent").setup({
      indent_function_call_parameters = true,
      indent_function_declaration_parameters = true,
    })
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = setup_php_indent_for_project,
  once = true,
})
```

### Disable Auto-setup
```lua
-- Prevent automatic setup
vim.g.enhanced_php_indent_disable_auto_setup = true

-- Then manually setup when needed
require("enhanced-php-indent").setup({
  -- your configuration
})
```

### Integration with Formatters
```lua
-- Setup the indent plugin
require("enhanced-php-indent").setup({
  indent_function_call_parameters = true,
  enable_real_time_indent = true,
})

-- Auto-format on save (requires conform.nvim or similar)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.php",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
```

## 🚨 Troubleshooting

### Plugin Not Loading
1. Check Neovim version: `:version` (requires 0.7+)
2. Verify PHP filetype: `:set filetype?` should show `php`
3. Check if plugin is installed: `:lua print(require('enhanced-php-indent').version or 'loaded')`

### Indentation Not Working
1. Check current indent expression: `:set indentexpr?`
2. Verify global function exists: `:lua print(_G.EnhancedPhpIndent)`
3. Test with: `gg=G` to reindent entire file
4. Check plugin status: `:PHPIndentStatus`

### Real-time Features Too Aggressive
```lua
require("enhanced-php-indent").setup({
  enable_real_time_indent = false,
})
```

### Conflicts with Other Plugins
- Check loaded plugins: `:scriptnames`
- Disable conflicting plugins or ensure this loads last
- Use `after/` directory for plugin files if needed

## 📊 Configuration Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `default_indenting` | number | 0 | Extra base indentation level |
| `braces_at_code_level` | boolean | false | Braces at same level as code |
| `indent_function_call_parameters` | boolean | false | Indent function call parameters |
| `indent_function_declaration_parameters` | boolean | false | Indent function declaration parameters |
| `autoformat_comment` | boolean | true | Auto-format comments |
| `outdent_sl_comments` | number | 0 | Outdent single-line comments |
| `outdent_php_escape` | boolean | true | Outdent <?php and ?> tags |
| `remove_cr_when_unix` | boolean | false | Remove CR characters on Unix |
| `no_arrow_matching` | boolean | false | Disable -> method chaining indent |
| `vintage_case_default_indent` | boolean | false | Old-style case/default indent |
| `enable_real_time_indent` | boolean | true | Enable real-time features |
| `smart_array_indent` | boolean | true | Enhanced array handling |

## 📈 Comparison

| Metric | Original php-indent.lua | Official php.lua | Enhanced Combined |
|--------|-------------------------|------------------|-------------------|
| Language | Lua | VimScript | Modern Lua |
| File Size | 2.4 KB | 26.4 KB | 9.9 KB |
| Features | 7 | 20+ | 25+ |
| Config Options | 0 | 11 | 12+ |
| Real-time | ✓ | ✗ | ✓ |
| Plugin Structure | ✗ | ✗ | ✓ |
| Setup Function | ✗ | ✗ | ✓ |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Test with various PHP code samples
4. Ensure PSR compliance where applicable
5. Submit a pull request

### Development Setup
```bash
git clone https://github.com/nik-zsh/enhanced-php-indent.nvim.git
cd enhanced-php-indent.nvim

# Test with the provided test files
nvim test-files/test-comprehensive.php
```

## 📄 License

UNLICENSE License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Based on the official PHP indent script by John Wellesz
- Inspired by modern Neovim plugin development practices
- Enhanced with features from php-indent.lua implementations
- Community feedback and contributions

## 🔗 Related Projects

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Syntax highlighting
- [conform.nvim](https://github.com/stevearc/conform.nvim) - Formatting integration
- [mason.nvim](https://github.com/williamboman/mason.nvim) - PHP tooling installation

---

**Made with ❤️ for the PHP and Neovim community**
