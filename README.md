# enhanced-php-indent.nvim

[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-green.svg)](https://neovim.io)
[![PHP](https://img.shields.io/badge/PHP-7.4+-purple.svg)](https://php.net)

A comprehensive PHP indentation plugin for Neovim that provides enhanced PHP indentation with optional **HTML, CSS, and JavaScript** support for mixed-language development.

## ✨ Features

### 🚀 Enhanced PHP Indentation
- **Smart Array Handling**: Proper bracket alignment and blank line indentation
- **Switch/Case Optimization**: Improved switch statement indentation with vintage mode support
- **Method Chaining**: Perfect for Laravel Eloquent and fluent interfaces  
- **Function Parameters**: Configurable indentation for function calls and declarations
- **Real-time Processing**: Automatic fixes on `InsertLeave` events
- **PSR-12 Compliant**: Full support for modern PHP coding standards

### 🌐 Frontend Language Support (Optional)
- **HTML Tags**: Proper indentation for block-level elements, closing tag alignment
- **CSS Styles**: Complete CSS indentation in `<style>` tags with at-rule support
- **JavaScript**: Full JS indentation in `<script>` tags including switch/case statements
- **Context Detection**: Automatically switches between PHP, HTML, CSS, and JavaScript
- **Laravel Blade Compatibility**: Works with `.blade.php` files when configured properly

### ⚡ Performance & Reliability
- **Non-Breaking**: Original PHP functionality remains unchanged
- **Opt-in Extensions**: Frontend features are completely optional
- **Efficient Processing**: Minimal performance impact when extensions are disabled
- **Error Handling**: Graceful fallbacks and comprehensive debug modes

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (Recommended)

#### Standard PHP-Only Setup
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

#### Advanced Setup with Frontend Languages
```lua
{
  "nik-zsh/enhanced-php-indent.nvim",
  ft = { "php", "blade" }, -- Include blade for Laravel projects
  config = function()
    require("enhanced-php-indent.advanced").advanced_setup({
      -- PHP indentation options
      indent_function_call_parameters = true,
      enable_real_time_indent = true,
      smart_array_indent = true,

      -- Frontend language support
      enable_html_indent = true,
      enable_css_indent = true,
      enable_js_indent = true,

      -- Debug mode (set to true for troubleshooting)
      frontend_debug = false,
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
    -- Standard setup
    require("enhanced-php-indent").setup()

    -- OR advanced setup with frontend support
    require("enhanced-php-indent.advanced").advanced_setup({
      enable_html_indent = true,
      enable_css_indent = true,
      enable_js_indent = true,
    })
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nik-zsh/enhanced-php-indent.nvim'
```

Then add to your `init.lua`:
```lua
-- Standard PHP setup
require("enhanced-php-indent").setup()

-- OR advanced setup with frontend languages
require("enhanced-php-indent.advanced").advanced_setup({
  enable_html_indent = true,
  enable_css_indent = true,
  enable_js_indent = true,
})
```

## ⚙️ Configuration

### Setup Methods

#### Standard Setup - PHP Only
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

#### Advanced Setup - PHP + Frontend Languages
```lua
require("enhanced-php-indent.advanced").advanced_setup({
  -- All PHP options from standard setup work here PLUS:

  -- Frontend language support
  enable_html_indent = false,     -- Enable HTML tag indentation
  enable_css_indent = false,      -- Enable CSS indentation in <style> tags
  enable_js_indent = false,       -- Enable JavaScript indentation in <script> tags

  -- HTML-specific options
  html_indent_tags = {
    'html', 'head', 'body', 'div', 'section', 'article', 'header', 'footer',
    'nav', 'main', 'aside', 'form', 'fieldset', 'legend', 'label',
    'ul', 'ol', 'li', 'dl', 'dt', 'dd',
    'table', 'caption', 'thead', 'tbody', 'tfoot', 'tr', 'th', 'td',
    'blockquote', 'figure', 'figcaption', 'pre', 'address',
    'details', 'summary', 'dialog'
  },
  html_self_closing_tags = {
    'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input',
    'link', 'meta', 'param', 'source', 'track', 'wbr'
  },
  html_inline_tags = {
    'a', 'abbr', 'b', 'cite', 'code', 'em', 'i', 'kbd', 'mark',
    'q', 'samp', 'small', 'span', 'strong', 'sub', 'sup', 'time', 'var'
  },

  -- CSS-specific options
  css_indent_rules = true,        -- Indent CSS rules and properties
  css_indent_at_rules = true,     -- Indent @media, @keyframes, etc.

  -- JavaScript-specific options
  js_indent_switch_case = true,   -- Indent switch case statements
  js_indent_objects = true,       -- Indent object literals
  js_indent_arrays = true,        -- Indent array literals
  js_indent_functions = true,     -- Indent function bodies

  -- Debug options
  frontend_debug = false,         -- Debug frontend language processing
})
```

## 🎯 Configuration Presets

### PSR-12 Compliant
```lua
require("enhanced-php-indent").setup({
  indent_function_call_parameters = true,
  indent_function_declaration_parameters = true,
  braces_at_code_level = false,
  autoformat_comment = true,
  enable_real_time_indent = true,
})
```

### Laravel Development
```lua
require("enhanced-php-indent.advanced").advanced_setup({
  -- Laravel-style PHP
  braces_at_code_level = true,
  no_arrow_matching = false,
  indent_function_call_parameters = true,

  -- Frontend for Blade templates
  enable_html_indent = true,
  enable_css_indent = true,
  enable_js_indent = true,
})
```

### WordPress Theme Development
```lua
require("enhanced-php-indent.advanced").advanced_setup({
  -- WordPress-style PHP
  vintage_case_default_indent = true,
  default_indenting = 4,
  braces_at_code_level = false,

  -- Frontend for theme templates
  enable_html_indent = true,
  enable_css_indent = true,
  enable_js_indent = true,
})
```

### Performance-Focused (Large Files)
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
            ->orderBy('created_at', 'desc')
            ->get();

        $config = [
            'pagination' => [
                'per_page' => 15,
                'links' => [

                    // Blank lines get proper indentation
                ],
            ],
        ];  // Bracket aligns with $config

        switch ($request->get('format')) {
            case 'json':
                return response()->json($users);
                break;

            case 'xml':
                return response()->xml($users);
                break;

            default:
                return view('users.index', compact('users'));
                break;
        }
    }
}
```

### Mixed PHP + HTML Templates
```php
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title><?= htmlspecialchars($title) ?></title>
        <style>
            body {
                margin: 0;
                padding: 0;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 20px;
            }

            @media (max-width: 768px) {
                .container {
                    padding: 10px;
                }

                .navigation {
                    display: none;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <header class="main-header">
                <h1><?= $title ?></h1>
                <?php if ($user->isAuthenticated()): ?>
                    <nav class="navigation">
                        <ul>
                            <?php foreach ($menuItems as $item): ?>
                                <li>
                                    <a href="<?= $item['url'] ?>"><?= $item['title'] ?></a>
                                </li>
                            <?php endforeach; ?>
                        </ul>
                    </nav>
                <?php endif; ?>
            </header>

            <main class="content">
                <?php if (!empty($posts)): ?>
                    <section class="posts">
                        <?php foreach ($posts as $post): ?>
                            <article class="post">
                                <h2><?= htmlspecialchars($post->title) ?></h2>
                                <div class="post-content">
                                    <?= nl2br(htmlspecialchars($post->content)) ?>
                                </div>
                            </article>
                        <?php endforeach; ?>
                    </section>
                <?php else: ?>
                    <div class="no-content">
                        <p>No posts available.</p>
                    </div>
                <?php endif; ?>
            </main>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const posts = <?= json_encode($posts) ?>;

                function initializePosts() {
                    posts.forEach(function(post, index) {
                        const element = document.querySelector(`[data-post="${post.id}"]`);

                        if (element) {
                            element.addEventListener('click', function(e) {
                                switch (e.target.tagName.toLowerCase()) {
                                    case 'button':
                                        handleButtonClick(post.id);
                                        break;

                                    case 'a':
                                        // Let default link behavior work
                                        break;

                                    default:
                                        highlightPost(post.id);
                                        break;
                                }
                            });
                        }
                    });
                }

                function handleButtonClick(postId) {
                    const config = {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        body: JSON.stringify({
                            action: 'like',
                            post_id: postId
                        })
                    };

                    fetch('/api/posts/like', config)
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                updateLikeCount(postId, data.likes);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                        });
                }

                initializePosts();
            });
        </script>
    </body>
</html>
```

### Laravel Blade Templates
```blade
@extends('layouts.app')

@section('title', 'User Dashboard')

@section('content')
    <div class="dashboard">
        <div class="row">
            <div class="col-md-8">
                @if($user->hasNotifications())
                    <div class="notifications">
                        @foreach($user->notifications as $notification)
                            <div class="notification notification--{{ $notification->type }}">
                                <h4>{{ $notification->title }}</h4>
                                <p>{{ $notification->message }}</p>
                                <small>{{ $notification->created_at->diffForHumans() }}</small>
                            </div>
                        @endforeach
                    </div>
                @endif

                <div class="user-posts">
                    @forelse($posts as $post)
                        <article class="post-card">
                            <header class="post-header">
                                <h2>{{ $post->title }}</h2>
                                @can('edit', $post)
                                    <a href="{{ route('posts.edit', $post) }}" class="btn btn-sm">Edit</a>
                                @endcan
                            </header>
                            <div class="post-body">
                                {{ Str::limit($post->content, 200) }}
                            </div>
                        </article>
                    @empty
                        <div class="no-posts">
                            <h3>No posts yet</h3>
                            <p>Start writing your first post!</p>
                            <a href="{{ route('posts.create') }}" class="btn btn-primary">Create Post</a>
                        </div>
                    @endforelse
                </div>
            </div>

            <div class="col-md-4">
                <div class="sidebar">
                    @include('partials.user-stats')
                    @include('partials.recent-activity')
                </div>
            </div>
        </div>
    </div>
@endsection

@push('styles')
    <style>
        .dashboard {
            padding: 2rem 0;
        }

        .post-card {
            background: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
    </style>
@endpush

@push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const postCards = document.querySelectorAll('.post-card');

            postCards.forEach(function(card) {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-2px)';
                    this.style.boxShadow = '0 4px 8px rgba(0,0,0,0.15)';
                });

                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0)';
                    this.style.boxShadow = '0 2px 4px rgba(0,0,0,0.1)';
                });
            });
        });
    </script>
@endpush
```

## 🌐 Laravel Blade Support

### Blade File Compatibility
The plugin works with Laravel Blade templates (`.blade.php` files) with proper configuration:

#### Method 1: Filetype Configuration (Recommended)
```lua
-- In your Neovim configuration
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.blade.php",
  callback = function()
    vim.bo.filetype = "php"  -- Treat blade files as PHP
  end,
})

-- Then use advanced setup
require("enhanced-php-indent.advanced").advanced_setup({
  enable_html_indent = true,
  enable_css_indent = true,
  enable_js_indent = true,
})
```

#### Method 2: Plugin Configuration
```lua
{
  "nik-zsh/enhanced-php-indent.nvim",
  ft = { "php", "blade" },  -- Include both filetypes
  config = function()
    require("enhanced-php-indent.advanced").advanced_setup({
      enable_html_indent = true,
      enable_css_indent = true,
      enable_js_indent = true,
    })
  end,
}
```

### Blade-Specific Considerations
- **Blade directives** (`@if`, `@foreach`, etc.) are treated as PHP code
- **HTML within Blade** gets proper HTML indentation
- **Embedded CSS/JS** in Blade templates work with `<style>`/`<script>` tags
- **Mixed content** (PHP + HTML + CSS + JS) is handled contextually

### Blade Limitations
- Pure Blade syntax highlighting requires a dedicated Blade plugin
- Complex Blade components may need manual indentation adjustments
- Nested Blade directives work best with consistent formatting

## 🛠️ Available Commands

- `:PHPIndentStatus` - Show plugin status and configuration
- `:PHPIndentTest` - Test indentation on current file (`gg=G`)
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
    require("enhanced-php-indent.advanced").advanced_setup(vim.tbl_extend("force", config, {
      braces_at_code_level = true,
      no_arrow_matching = false,
      enable_html_indent = true,
      enable_css_indent = true,
      enable_js_indent = true,
    }))
    return
  end

  -- WordPress projects  
  if cwd:match("wordpress") or vim.fn.filereadable("wp-config.php") == 1 then
    require("enhanced-php-indent.advanced").advanced_setup(vim.tbl_extend("force", config, {
      vintage_case_default_indent = true,
      default_indenting = 4,
      enable_html_indent = true,
      enable_css_indent = true,
      enable_js_indent = true,
    }))
    return
  end

  -- Generic web projects
  if vim.fn.isdirectory("public") == 1 or vim.fn.isdirectory("templates") == 1 then
    require("enhanced-php-indent.advanced").advanced_setup(vim.tbl_extend("force", config, {
      enable_html_indent = true,
      enable_css_indent = true,
      enable_js_indent = true,
    }))
    return
  end

  -- Default: PHP-only setup
  require("enhanced-php-indent").setup(config)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "php", "blade" },
  callback = setup_php_indent_auto,
  once = true,
})
```

### Conditional Frontend Support
```lua
local function conditional_setup()
  local filename = vim.fn.expand("%:t")

  -- Enable frontend support for template files
  if filename:match("%.template%.php$") or 
     filename:match("%.view%.php$") or
     filename:match("%.blade%.php$") or
     filename:match("%.twig%.php$") then

    require("enhanced-php-indent.advanced").advanced_setup({
      indent_function_call_parameters = true,
      enable_html_indent = true,
      enable_css_indent = true,
      enable_js_indent = true,
      frontend_debug = true,  -- Debug template files
    })
  else
    -- Standard PHP for regular files
    require("enhanced-php-indent").setup({
      indent_function_call_parameters = true,
      enable_real_time_indent = true,
    })
  end
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.php",
  callback = conditional_setup,
})
```

## 🚨 Troubleshooting

### Plugin Not Loading
1. **Check Neovim version**: `:version` (requires 0.7+)
2. **Verify filetype**: `:set filetype?` should show `php` or `blade`
3. **Check plugin status**: `:PHPIndentStatus`
4. **Review messages**: `:messages` for error details

### PHP Indentation Issues
1. **Test with standard setup**: Use `require("enhanced-php-indent").setup()`
2. **Disable other plugins**: Treesitter indent, other PHP plugins
3. **Check configuration**: Ensure proper option syntax
4. **Test minimal config**: Start with `nvim --clean`

### Frontend Languages Not Working
1. **Verify advanced setup**: Must use `advanced_setup()` not `setup()`
2. **Enable languages**: Set `enable_html_indent = true`, etc.
3. **Check context detection**: Enable `frontend_debug = true`
4. **Verify file content**: Ensure `<script>`/`<style>` tags are on separate lines
5. **Check filetype**: Must be `php` for context detection to work

### Blade Template Issues
1. **Set filetype to php**: `vim.bo.filetype = "php"` for `.blade.php` files
2. **Use advanced setup**: Blade needs frontend language support
3. **Check Blade directives**: Should be treated as PHP code
4. **Enable debug mode**: Use `frontend_debug = true` to trace processing

### Context Detection Problems
1. **Tags on separate lines**: `<script>` and `</script>` should be on their own lines
2. **Proper tag closing**: Ensure all tags are properly opened and closed
3. **PHP tag placement**: Check `<?php ... ?>` tag positioning
4. **Enable debugging**: Set `frontend_debug = true` and check `:messages`

### Performance Issues
1. **Disable real-time**: Set `enable_real_time_indent = false`
2. **Use standard setup**: Avoid advanced features for large files
3. **Limit frontend support**: Enable only needed languages
4. **Check file size**: Very large files may need optimization

## 📊 Configuration Reference

### Complete Options Table

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| **PHP Core Options** | | | |
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
| **Frontend Language Options** | | | |
| `enable_html_indent` | boolean | false | Enable HTML indentation support |
| `enable_css_indent` | boolean | false | Enable CSS indentation support |
| `enable_js_indent` | boolean | false | Enable JavaScript indentation support |
| `html_indent_tags` | table | [comprehensive list] | HTML tags that indent their content |
| `html_self_closing_tags` | table | [standard list] | HTML self-closing tags |
| `html_inline_tags` | table | [standard list] | HTML inline tags |
| `css_indent_rules` | boolean | true | Indent CSS rules and properties |
| `css_indent_at_rules` | boolean | true | Indent CSS at-rules (@media, etc.) |
| `js_indent_switch_case` | boolean | true | Indent JavaScript switch/case |
| `js_indent_objects` | boolean | true | Indent JavaScript object literals |
| `js_indent_arrays` | boolean | true | Indent JavaScript arrays |
| `js_indent_functions` | boolean | true | Indent JavaScript function bodies |
| `frontend_debug` | boolean | false | Debug frontend language processing |

## 📈 Performance Benchmarks

| Configuration | File Type | Size | Processing Time | Memory Usage |
|---------------|-----------|------|-----------------|--------------|
| Standard PHP | `.php` | 1000 lines | ~2ms | ~1MB |
| Advanced (All) | Mixed | 1000 lines | ~4ms | ~1.5MB |
| Advanced (HTML only) | Mixed | 1000 lines | ~3ms | ~1.2MB |
| Blade Templates | `.blade.php` | 1000 lines | ~3.5ms | ~1.3MB |

*Benchmarks on Intel i7-9750H, 16GB RAM, NVMe SSD*

## 🤝 Contributing

We welcome contributions! Areas of focus:

- **Template Engine Support**: Twig, Smarty improvements
- **Performance Optimizations**: Faster context detection
- **Language Extensions**: Enhanced CSS/JS feature support
- **Testing**: Comprehensive test coverage
- **Documentation**: More examples and use cases

### Development Setup
```bash
git clone https://github.com/nik-zsh/enhanced-php-indent.nvim.git
cd enhanced-php-indent.nvim

# Test your changes
nvim test-files/mixed-language-test.php
```

## 📜 License

This project is released into the public domain under [The Unlicense](http://unlicense.org/).

## 🔗 Related Projects

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Advanced syntax highlighting
- [conform.nvim](https://github.com/stevearc/conform.nvim) - Code formatting
- [mason.nvim](https://github.com/williamboman/mason.nvim) - LSP server management
- [blade.nvim](https://github.com/EmranMR/tree-sitter-blade) - Laravel Blade syntax highlighting

---

**Enhanced PHP indentation with comprehensive frontend language support for modern web development** ❤️
