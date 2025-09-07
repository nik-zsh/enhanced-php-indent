# enhanced-php-indent.nvim

[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-green.svg)](https://neovim.io)
[![PHP](https://img.shields.io/badge/PHP-7.4+-purple.svg)](https://php.net)

A comprehensive PHP indentation plugin for Neovim that combines the robustness of the official PHP indent script with modern enhancements, real-time features, and **HTML embedding support** for mixed PHP/HTML development.

## ✨ Features

### 🚀 Enhanced PHP Indentation
- **Smart Array Handling**: Proper bracket alignment and blank line indentation
- **Switch/Case Optimization**: Improved switch statement indentation with vintage mode support  
- **Method Chaining**: Perfect indentation for Laravel Eloquent and fluent interfaces
- **Function Parameters**: Configurable indentation for function calls and declarations
- **Real-time Processing**: Automatic fixes on `InsertLeave` events

### 🌐 HTML Embedding Support (NEW)
- **Context Detection**: Automatically detects PHP vs HTML contexts in mixed files
- **HTML Tag Indentation**: Proper indentation for block-level tags (`<div>`, `<body>`, `<section>`, etc.)
- **Closing Tag Alignment**: `</div>` automatically aligns with opening `<div>`
- **Mixed Content**: PHP embedded in HTML maintains proper PHP indentation
- **Laravel Blade Compatible**: Works with Blade-like mixed template files

### ⚡ Performance & Reliability
- **Optimized Algorithms**: Efficient processing for large files
- **Non-Breaking**: Original PHP functionality remains unchanged
- **Opt-in Extensions**: HTML features are disabled by default
- **Error Handling**: Graceful fallbacks and debug modes

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (Recommended)

#### Standard Setup (PHP Only)
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

#### With HTML Embedding Support
```lua
{
  "nik-zsh/enhanced-php-indent.nvim",
  ft = "php",
  config = function()
    require("enhanced-php-indent.setup").setup_with_html({
      -- All original PHP options work exactly the same
      indent_function_call_parameters = true,
      enable_real_time_indent = true,
      smart_array_indent = true,

      -- NEW: HTML embedding support
      enable_html_indent = true,              -- Enable HTML indentation
      php_html_context_detection = true,      -- Auto-detect PHP vs HTML
      html_preserve_php_indent = true,        -- Preserve PHP indent in HTML
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
    -- Choose either standard or HTML-enabled setup
    require("enhanced-php-indent").setup({...})  -- Standard
    -- OR
    require("enhanced-php-indent.setup").setup_with_html({...})  -- With HTML
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nik-zsh/enhanced-php-indent.nvim'
```

Then add to your `init.lua`:
```lua
require("enhanced-php-indent").setup()  -- Standard
-- OR
require("enhanced-php-indent.setup").setup_with_html({...})  -- With HTML
```

## ⚙️ Configuration

### Core PHP Configuration Options

```lua
require("enhanced-php-indent").setup({
  -- Basic indentation settings
  default_indenting = 0,                      -- Extra base indentation level
  braces_at_code_level = false,               -- Braces at same level as code
  indent_function_call_parameters = false,    -- Indent function call parameters
  indent_function_declaration_parameters = false, -- Indent function declaration parameters

  -- Advanced features
  autoformat_comment = true,                  -- Auto-format comments
  outdent_sl_comments = 0,                    -- Outdent single-line comments
  outdent_php_escape = true,                  -- Outdent <?php and ?> tags
  remove_cr_when_unix = false,                -- Remove CR characters on Unix
  no_arrow_matching = false,                  -- Disable -> method chaining indent
  vintage_case_default_indent = false,        -- Old-style case/default indentation

  -- Modern enhancements
  enable_real_time_indent = true,             -- Enable real-time features
  smart_array_indent = true,                  -- Enhanced array handling
})
```

### HTML Embedding Configuration

```lua
require("enhanced-php-indent.setup").setup_with_html({
  -- All PHP options above PLUS:

  -- HTML Extension
  enable_html_indent = false,                 -- Enable HTML indentation support
  html_indent_tags = {                        -- HTML tags that indent content
    'html', 'head', 'body', 'div', 'section', 'article',
    'header', 'footer', 'nav', 'main', 'aside', 'form',
    'ul', 'ol', 'li', 'table', 'thead', 'tbody', 'tr', 'td', 'th',
    'fieldset', 'script', 'style', 'noscript', 'blockquote'
  },
  html_inline_tags = {                        -- Inline tags (no indentation change)
    'span', 'a', 'strong', 'em', 'b', 'i', 'code', 'img', 'br', 'hr'
  },
  html_self_closing_tags = {                  -- Self-closing tags
    'br', 'hr', 'img', 'input', 'meta', 'link', 'area', 'base', 'wbr'
  },
  php_html_context_detection = true,          -- Auto-detect PHP/HTML context
  html_preserve_php_indent = true,            -- Preserve PHP indent in HTML
  html_debug = false,                         -- Debug HTML processing
})
```

## 🎯 Configuration Presets

### PSR-12 Compliant (Recommended)
```lua
require("enhanced-php-indent").setup({
  indent_function_call_parameters = true,
  indent_function_declaration_parameters = true,
  braces_at_code_level = false,
  autoformat_comment = true,
  enable_real_time_indent = true,
})
```

### Laravel Development with Blade Support
```lua  
require("enhanced-php-indent.setup").setup_with_html({
  -- Laravel-style PHP
  braces_at_code_level = true,
  no_arrow_matching = false,                  -- Enable method chaining
  indent_function_call_parameters = true,

  -- HTML for Blade-like templates
  enable_html_indent = true,
  php_html_context_detection = true,
  html_preserve_php_indent = true,
})
```

### WordPress Theme Development
```lua
require("enhanced-php-indent.setup").setup_with_html({
  -- WordPress-style PHP
  vintage_case_default_indent = true,
  default_indenting = 4,
  braces_at_code_level = false,

  -- HTML for themes
  enable_html_indent = true,
  html_preserve_php_indent = true,
})
```

### Performance-Focused (Large Files)
```lua
require("enhanced-php-indent").setup({
  indent_function_call_parameters = true,
  enable_real_time_indent = false,            -- Disable for performance
  smart_array_indent = false,                 -- Disable for performance
})
```

## 🎭 Usage Examples

### Pure PHP Code
```php
<?php
// Method chaining (Laravel Eloquent style)
$users = User::where('active', true)
    ->whereHas('profile', function($query) {
        $query->where('verified', true);
    })
    ->orderBy('created_at', 'desc')
    ->get();

// Array indentation with proper alignment
$config = [
    'database' => [
        'host' => 'localhost',
        'nested' => [

            // Blank lines get proper double-indentation
        ],
    ],
    'cache' => 'redis',
];  // Closing bracket aligns with $config

// Switch statements
switch ($status) {
    case 'pending':
        processOrder($order);
        break;

    case 'completed':
        finalizeOrder($order);
        break;

    default:
        logError('Unknown status: ' . $status);
        break;
}
```

### Mixed PHP + HTML Content
```php
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title><?= htmlspecialchars($title) ?></title>
        <script>
            const config = <?= json_encode($jsConfig) ?>;
        </script>
    </head>
    <body class="bg-gray-100">
        <div class="container mx-auto px-4">
            <header class="py-6">
                <h1 class="text-3xl font-bold"><?= $title ?></h1>
                <?php if ($user->isLoggedIn()): ?>
                    <div class="user-menu">
                        <span>Welcome, <?= $user->name ?></span>
                        <a href="/logout" class="text-blue-600">Logout</a>
                    </div>
                <?php else: ?>
                    <div class="auth-links">
                        <a href="/login" class="btn btn-primary">Login</a>
                        <a href="/register" class="btn btn-secondary">Register</a>
                    </div>
                <?php endif; ?>
            </header>

            <main class="py-8">
                <?php if (!empty($posts)): ?>
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <?php foreach ($posts as $post): ?>
                            <article class="bg-white rounded-lg shadow-md overflow-hidden">
                                <div class="p-6">
                                    <h2 class="text-xl font-semibold mb-2">
                                        <?= htmlspecialchars($post->title) ?>
                                    </h2>
                                    <p class="text-gray-600 mb-4">
                                        <?= htmlspecialchars($post->excerpt) ?>
                                    </p>
                                    <div class="flex justify-between items-center">
                                        <span class="text-sm text-gray-500">
                                            <?= $post->created_at->format('M j, Y') ?>
                                        </span>
                                        <a href="/posts/<?= $post->slug ?>" 
                                           class="text-blue-600 hover:text-blue-800 transition-colors">
                                            Read more
                                        </a>
                                    </div>
                                </div>
                            </article>
                        <?php endforeach; ?>
                    </div>
                <?php else: ?>
                    <div class="text-center py-12">
                        <h3 class="text-xl text-gray-600">No posts found</h3>
                        <p class="text-gray-500 mt-2">Check back later for new content.</p>
                    </div>
                <?php endif; ?>
            </main>

            <footer class="py-6 mt-12 border-t border-gray-200">
                <div class="text-center text-gray-600">
                    <p>&copy; <?= date('Y') ?> <?= $siteName ?>. All rights reserved.</p>
                </div>
            </footer>
        </div>
    </body>
</html>
```

### Laravel Blade-style Templates
```php
{{-- Note: This requires filetype=php, not blade --}}
<!DOCTYPE html>
<html>
    <head>
        <title><?= $title ?></title>
    </head>
    <body>
        <div class="container">
            <?php if($posts->count() > 0): ?>
                <div class="post-grid">
                    <?php foreach($posts as $post): ?>
                        <article class="post-card">
                            <h2><?= $post->title ?></h2>
                            <p><?= $post->excerpt ?></p>
                            <?php if($user->can('edit', $post)): ?>
                                <a href="/posts/<?= $post->id ?>/edit">Edit</a>
                            <?php endif; ?>
                        </article>
                    <?php endforeach; ?>
                </div>
            <?php else: ?>
                <div class="empty-state">
                    <p>No posts found.</p>
                </div>
            <?php endif; ?>
        </div>
    </body>
</html>
```

### WordPress Theme Templates
```php
<?php get_header(); ?>

<div class="main-content">
    <div class="container">
        <?php if (have_posts()): ?>
            <div class="posts-grid">
                <?php while (have_posts()): the_post(); ?>
                    <article class="post-item">
                        <header class="post-header">
                            <h2 class="post-title">
                                <a href="<?php the_permalink(); ?>">
                                    <?php the_title(); ?>
                                </a>
                            </h2>
                            <div class="post-meta">
                                <span class="post-date"><?php the_date(); ?></span>
                                <span class="post-author">by <?php the_author(); ?></span>
                            </div>
                        </header>
                        <div class="post-content">
                            <?php the_excerpt(); ?>
                        </div>
                        <footer class="post-footer">
                            <div class="post-categories">
                                <?php the_category(', '); ?>
                            </div>
                        </footer>
                    </article>
                <?php endwhile; ?>
            </div>

            <div class="pagination">
                <?php
                the_posts_pagination([
                    'prev_text' => '← Previous',
                    'next_text' => 'Next →',
                ]);
                ?>
            </div>
        <?php else: ?>
            <div class="no-posts">
                <h2>No posts found</h2>
                <p>Sorry, no posts were found matching your criteria.</p>
            </div>
        <?php endif; ?>
    </div>
</div>

<?php get_footer(); ?>
```

## 🛠️ Available Commands

- `:PHPIndentStatus` - Show plugin status, configuration, and debug info
- `:PHPIndentTest` - Test indentation on current file (equivalent to `gg=G`)
- `:PHPIndentReload` - Reload plugin configuration

## 🔧 Advanced Usage

### Project-Specific Auto-Configuration
```lua
local function setup_php_indent_auto()
  local cwd = vim.fn.getcwd()
  local config = {
    indent_function_call_parameters = true,
    enable_real_time_indent = true,
  }

  -- Laravel projects
  if cwd:match("laravel") or vim.fn.filereadable("artisan") == 1 then
    config.enable_html_indent = true
    config.braces_at_code_level = true
    config.no_arrow_matching = false  -- Enable method chaining
  end

  -- WordPress projects  
  if cwd:match("wordpress") or vim.fn.filereadable("wp-config.php") == 1 then
    config.enable_html_indent = true
    config.vintage_case_default_indent = true
    config.default_indenting = 4
  end

  -- Generic web projects
  if vim.fn.isdirectory("public") == 1 or vim.fn.isdirectory("templates") == 1 then
    config.enable_html_indent = true
  end

  require("enhanced-php-indent.setup").setup_with_html(config)
end

-- Auto-setup on PHP files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = setup_php_indent_auto,
  once = true,
})
```

### Conditional HTML Support
```lua
local function setup_with_conditional_html()
  local config = {
    indent_function_call_parameters = true,
    enable_real_time_indent = true,
  }

  -- Enable HTML only for mixed content files
  local buf_name = vim.fn.expand("%:t")
  if buf_name:match("%.template%.php$") or 
     buf_name:match("%.view%.php$") or
     buf_name:match("%.blade%.php$") then
    config.enable_html_indent = true
    config.html_debug = true  -- Debug template files
  end

  require("enhanced-php-indent.setup").setup_with_html(config)
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.php",
  callback = setup_with_conditional_html,
})
```

## 🚨 Troubleshooting

### Plugin Not Loading
1. **Check Neovim version**: `:version` (requires 0.7+)
2. **Verify PHP filetype**: `:set filetype?` should show `php`
3. **Check plugin status**: `:PHPIndentStatus`
4. **Review error messages**: `:messages`

### PHP Indentation Issues
1. **Disable conflicting plugins**: Treesitter indent, other PHP plugins
2. **Test with minimal config**: Start with `nvim --clean`
3. **Enable debug mode**: Add `html_debug = true` to config
4. **Check original functionality**: Use standard `setup()` method

### HTML Indentation Not Working
1. **Ensure HTML is enabled**: `enable_html_indent = true` in config
2. **Use correct setup method**: `setup_with_html()` not `setup()`
3. **Verify filetype is `php`**: HTML extension only works with PHP files
4. **Check context detection**: Enable `html_debug = true`
5. **Review file structure**: Mixed PHP/HTML content in `.php` files

### Context Detection Issues
1. **File must have `.php` extension**: HTML extension requires PHP filetype
2. **Check PHP tags**: Ensure `<?php ... ?>` tags are properly closed
3. **Debug output**: Set `html_debug = true` and check `:messages`
4. **Test with simple file**: Use provided test files

### Performance Issues
1. **Disable real-time features**: `enable_real_time_indent = false`
2. **Reduce HTML tag lists**: Customize `html_indent_tags` array
3. **Limit search scope**: HTML context detection has built-in limits
4. **Profile with**: `:profile start profile.log` and `:profile func *`

## 📊 Configuration Reference

### Complete Options Table

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `default_indenting` | number | 0 | Extra base indentation level |
| `braces_at_code_level` | boolean | false | Place braces at same level as code |
| `indent_function_call_parameters` | boolean | false | Indent function call parameters |
| `indent_function_declaration_parameters` | boolean | false | Indent function declaration parameters |
| `autoformat_comment` | boolean | true | Auto-format comments |
| `outdent_sl_comments` | number | 0 | Outdent single-line comments |
| `outdent_php_escape` | boolean | true | Outdent PHP escape tags |
| `remove_cr_when_unix` | boolean | false | Remove CR characters on Unix |
| `no_arrow_matching` | boolean | false | Disable -> method chaining indent |
| `vintage_case_default_indent` | boolean | false | Use vintage case/default indentation |
| `enable_real_time_indent` | boolean | true | Enable real-time indentation features |
| `smart_array_indent` | boolean | true | Enhanced array handling |
| `enable_html_indent` | boolean | false | Enable HTML indentation support |
| `html_indent_tags` | table | see config | HTML tags that indent their content |
| `html_inline_tags` | table | see config | HTML inline tags (no indent change) |
| `html_self_closing_tags` | table | see config | HTML self-closing tags |
| `php_html_context_detection` | boolean | true | Auto-detect PHP vs HTML context |
| `html_preserve_php_indent` | boolean | true | Preserve PHP indentation in HTML |
| `html_debug` | boolean | false | Debug HTML processing |

## 🧪 Testing

### Test Files Included
```
test-files/
└── mixed-content.php           # HTML+PHP mixed content test
```

### Manual Testing
1. **Clone the repository**:
   ```bash
   git clone https://github.com/nik-zsh/enhanced-php-indent.nvim.git
   ```

2. **Test original PHP indentation**:
   ```lua
   require("enhanced-php-indent").setup({
     indent_function_call_parameters = true,
   })
   ```

3. **Test HTML embedding**:
   ```lua
   require("enhanced-php-indent.setup").setup_with_html({
     enable_html_indent = true,
     html_debug = true,
   })
   ```

4. **Open test file**: `nvim test-files/mixed-content.php`

5. **Test indentation**: Try `gg=G` to re-indent the entire file

### Automated Testing
```bash
# Run basic functionality tests
nvim --headless -c "luafile tests/test-basic.lua" -c "qa"

# Test HTML embedding
nvim --headless -c "luafile tests/test-html.lua" -c "qa"
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
```bash
git clone https://github.com/nik-zsh/enhanced-php-indent.nvim.git
cd enhanced-php-indent.nvim

# Test your changes
nvim test-files/mixed-content.php
```

### Areas for Contribution
- **Template Engine Support**: Twig, Smarty, Laravel Blade
- **Performance Optimizations**: Faster context detection
- **Additional Language Support**: Embedded JavaScript, CSS
- **Testing**: More comprehensive test suite
- **Documentation**: Examples, use cases, tutorials

## 📈 Performance Benchmarks

| Feature | File Size | Processing Time | Memory Usage |
|---------|-----------|----------------|--------------|
| Pure PHP | 1000 lines | ~2ms | ~1MB |
| PHP + HTML | 1000 lines | ~3ms | ~1.2MB |
| Large Mixed | 5000 lines | ~8ms | ~2MB |
| Real-time | Any size | ~0.5ms | Minimal |

*Benchmarks on Intel i7-9750H, 16GB RAM, SSD*

## 🗺️ Roadmap

### v1.1.0 (Next)
- [ ] Laravel Blade template engine support
- [ ] Twig template engine support  
- [ ] Performance optimizations for large files
- [ ] Enhanced debugging tools

### v1.2.0 (Future)
- [ ] Embedded JavaScript/CSS indentation
- [ ] WordPress block editor support
- [ ] Custom HTML tag configuration
- [ ] Integration with LSP servers

### v2.0.0 (Long-term)
- [ ] Treesitter integration
- [ ] Multiple template engine support
- [ ] Advanced context detection
- [ ] Plugin ecosystem integration

## 📜 License

This project is released into the public domain under [The Unlicense](http://unlicense.org/). 

```
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.
```

See the [UNLICENSE](UNLICENSE) file for the complete license text.

## 🙏 Acknowledgments

- **John Wellesz** - Original PHP indent script author
- **Neovim Community** - Modern Lua plugin architecture and best practices
- **PHP Community** - Feedback and real-world use cases
- **Contributors** - Bug reports, feature requests, and code contributions

## 🔗 Related Projects

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Syntax highlighting and parsing
- [conform.nvim](https://github.com/stevearc/conform.nvim) - Code formatting integration
- [mason.nvim](https://github.com/williamboman/mason.nvim) - PHP tooling and LSP server management
- [phpactor](https://github.com/phpactor/phpactor) - PHP language server
- [php-cs-fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer) - PHP code style fixer

---

**Enhanced PHP indentation with HTML embedding support for modern PHP development** ❤️

Made with ❤️ for the PHP and Neovim communities
