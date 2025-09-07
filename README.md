# enhanced-php-indent.nvim

[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-green.svg)](https://neovim.io)
[![PHP](https://img.shields.io/badge/PHP-7.4+-purple.svg)](https://php.net)

A comprehensive PHP indentation plugin for Neovim with optional HTML support for mixed PHP/HTML development.

## ✨ Features

### 🚀 Enhanced PHP Indentation

- **Smart Array Handling**: Proper bracket alignment and blank line indentation
- **Switch/Case Optimization**: Improved switch statement indentation with vintage mode support
- **Method Chaining**: Perfect for Laravel Eloquent and fluent interfaces
- **Function Parameters**: Configurable indentation for function calls and declarations
- **Real-time Processing**: Automatic fixes on `InsertLeave` events
- **PSR-12 Compliant**: Full support for modern PHP coding standards

### 🌐 HTML Support (Optional)

- **Mixed PHP/HTML files**: Proper indentation switching between PHP and HTML
- **Block-level tags**: Correct indentation for div, section, header, etc.
- **Self-closing tags**: Proper handling of br, img, input, etc.
- **Tag matching**: Accurate opening/closing tag alignment
- **PHP preservation**: Maintains PHP indentation within HTML context

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (Recommended)

#### PHP-Only Setup

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

#### PHP + HTML Setup

```lua
{
  "nik-zsh/enhanced-php-indent.nvim",
  ft = "php",
  config = function()
    require("enhanced-php-indent.setup").setup_with_html({
      indent_function_call_parameters = true,
      enable_real_time_indent = true,
      enable_html_indent = true,
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
    -- PHP-only
    require("enhanced-php-indent").setup()

    -- OR PHP + HTML
    require("enhanced-php-indent.setup").setup_with_html()
  end,
}
```

## ⚙️ Configuration

### PHP-Only Setup

```lua
require("enhanced-php-indent").setup({
  -- Core PHP indentation options
  default_indenting = 0,
  braces_at_code_level = false,
  indent_function_call_parameters = false,
  indent_function_declaration_parameters = false,
  autoformat_comment = true,
  outdent_sl_comments = 0,
  outdent_php_escape = true,
  remove_cr_when_unix = false,
  no_arrow_matching = false,
  vintage_case_default_indent = false,
  enable_real_time_indent = true,
  smart_array_indent = true,
})
```

### PHP + HTML Setup

```lua
require("enhanced-php-indent.setup").setup_with_html({
  -- All PHP options above PLUS:

  -- HTML-specific options
  enable_html_indent = true,
  html_debug = false,

  html_indent_tags = {
    'html', 'head', 'body', 'div', 'section', 'article', 'header', 'footer',
    'nav', 'main', 'aside', 'form', 'fieldset', 'legend', 'label',
    'ul', 'ol', 'li', 'dl', 'dt', 'dd',
    'table', 'caption', 'thead', 'tbody', 'tfoot', 'tr', 'th', 'td',
    'blockquote', 'figure', 'figcaption', 'pre', 'address'
  },
  html_self_closing_tags = {
    'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input',
    'link', 'meta', 'param', 'source', 'track', 'wbr'
  },
  html_inline_tags = {
    'a', 'abbr', 'b', 'cite', 'code', 'em', 'i', 'kbd', 'mark',
    'q', 'samp', 'small', 'span', 'strong', 'sub', 'sup', 'time', 'var'
  },
})
```

## 🎯 Configuration Presets

### Laravel Development (PHP + HTML)

```lua
require("enhanced-php-indent.setup").setup_with_html({
  -- Laravel-style PHP
  braces_at_code_level = true,
  no_arrow_matching = false,
  indent_function_call_parameters = true,

  -- HTML for Blade templates
  enable_html_indent = true,
})
```

### WordPress Theme Development

```lua
require("enhanced-php-indent.setup").setup_with_html({
  -- WordPress-style PHP
  vintage_case_default_indent = true,
  default_indenting = 4,
  braces_at_code_level = false,

  -- HTML for theme templates
  enable_html_indent = true,
})
```

### Performance-Focused (PHP-only)

```lua
require("enhanced-php-indent").setup({
  indent_function_call_parameters = true,
  enable_real_time_indent = false,  -- Disable for performance
  smart_array_indent = false,       -- Disable for performance
})
```

## 🎭 Usage Examples

### Pure PHP Development

```php
<?php
class UserController
{
    public function index()
    {
        $users = User::where('active', true)
            ->whereHas('profile', function($query) {
                $query->where('verified', true);
            })
            ->get();

        switch ($request->get('format')) {
            case 'json':
                return response()->json($users);
                break;

            default:
                return view('users.index');
                break;
        }
    }
}
```

### Mixed PHP + HTML Development

```php
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title><?= htmlspecialchars($title) ?></title>
    </head>
    <body>
        <div class="container">
            <header>
                <h1><?= $title ?></h1>
            </header>

            <main>
                <section class="content">
                    <?php if (!empty($posts)): ?>
                        <div class="posts">
                            <?php foreach ($posts as $post): ?>
                                <article class="post">
                                    <h2><?= $post->title ?></h2>
                                    <p><?= $post->content ?></p>
                                </article>
                            <?php endforeach; ?>
                        </div>
                    <?php else: ?>
                        <div class="no-posts">
                            <p>No posts available.</p>
                        </div>
                    <?php endif; ?>
                </section>
            </main>
        </div>
    </body>
</html>
```

## 🔧 Advanced Usage

### Debug Mode

```lua
require("enhanced-php-indent.setup").setup_with_html({
  html_debug = true,  -- Enable to see context detection in :messages
})
```

### Custom HTML Tags

```lua
require("enhanced-php-indent.setup").setup_with_html({
  html_indent_tags = {
    'div', 'section', 'article',  -- Only these tags will indent
  },
})
```

## 📊 Configuration Reference

### PHP Options

| Option                                   | Type    | Default | Description                            |
| ---------------------------------------- | ------- | ------- | -------------------------------------- |
| `default_indenting`                      | number  | 0       | Extra base indentation level           |
| `braces_at_code_level`                   | boolean | false   | Place braces at same level as code     |
| `indent_function_call_parameters`        | boolean | false   | Indent function call parameters        |
| `indent_function_declaration_parameters` | boolean | false   | Indent function declaration parameters |
| `no_arrow_matching`                      | boolean | false   | Disable -> method chaining indent      |
| `enable_real_time_indent`                | boolean | true    | Enable real-time indentation features  |
| `smart_array_indent`                     | boolean | true    | Enhanced array handling                |

### HTML Options (setup_with_html only)

| Option                   | Type    | Default              | Description                   |
| ------------------------ | ------- | -------------------- | ----------------------------- |
| `enable_html_indent`     | boolean | true                 | Enable HTML tag indentation   |
| `html_debug`             | boolean | false                | Debug HTML context detection  |
| `html_indent_tags`       | table   | [comprehensive list] | HTML tags that indent content |
| `html_self_closing_tags` | table   | [standard list]      | Self-closing HTML tags        |
| `html_inline_tags`       | table   | [standard list]      | Inline HTML tags              |

## 🤝 Contributing

We welcome contributions! Areas of focus:

- **Performance Optimizations**: Faster indentation processing
- **HTML Edge Cases**: Complex HTML structures
- **Template Support**: Better Blade/Twig compatibility
- **Testing**: Comprehensive test coverage

## 📜 License

This project is released into the public domain under [The Unlicense](http://unlicense.org/).

---

**Enhanced PHP indentation with optional HTML support for modern web development** ❤️
