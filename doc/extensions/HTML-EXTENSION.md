<!-- FILE: docs/extensions/HTML-EXTENSION.md -->
# HTML Extension Guide

## Overview

The HTML extension provides context-aware indentation for mixed PHP/HTML files. It automatically detects when you're writing HTML vs PHP code and applies appropriate indentation rules.

## Features

### Context Detection
- Automatically detects PHP (`<?php ... ?>`) vs HTML contexts
- Maintains separate indentation rules for each context
- Seamless transitions between PHP and HTML

### HTML Tag Support
- **Block-level tags**: `<div>`, `<section>`, `<article>` indent their content
- **Inline tags**: `<span>`, `<a>`, `<strong>` don't affect indentation
- **Self-closing tags**: `<br/>`, `<img/>` maintain current indentation
- **Closing tags**: `</div>` aligns with opening `<div>`

### Mixed Content Handling
- PHP embedded in HTML maintains HTML context indentation
- HTML within PHP strings is ignored
- Laravel Blade directives work seamlessly
- WordPress template functions are supported

## Configuration

```lua
require("enhanced-php-indent.setup").setup_with_extensions({
  enable_html_indent = true,                    -- Enable HTML support
  html_indent_tags = {                          -- Block-level tags
    'html', 'head', 'body', 'div', 'section', 'article',
    'header', 'footer', 'nav', 'main', 'aside', 'form'
  },
  html_inline_tags = {                          -- Inline tags
    'span', 'a', 'strong', 'em', 'code', 'img'
  },
  php_html_context_detection = true,           -- Auto-detect contexts
  html_preserve_php_indent = true,             -- Keep PHP indent in HTML
  html_debug = false,                          -- Debug HTML processing
})
```

## Examples

### Basic HTML + PHP
```php
<!DOCTYPE html>
<html>
    <head>
        <title><?= $title ?></title>
    </head>
    <body>
        <div class="container">
            <?php foreach ($items as $item): ?>
                <div class="item">
                    <h3><?= $item->title ?></h3>
                </div>
            <?php endforeach; ?>
        </div>
    </body>
</html>
```

### Laravel Blade Templates
```blade
@extends('layout')

@section('content')
    <div class="posts">
        @foreach($posts as $post)
            <article class="post">
                <h2>{{ $post->title }}</h2>
                @if($post->featured)
                    <span class="badge">Featured</span>
                @endif
            </article>
        @endforeach
    </div>
@endsection
```

## Troubleshooting

### HTML Not Indenting
- Ensure `enable_html_indent = true`
- Check you're outside PHP blocks (`<?php ... ?>`)
- Verify tags are in the `html_indent_tags` list

### Mixed Content Issues
- Enable debug: `html_debug = true`
- Check `:messages` for context detection info
- Verify PHP tags are properly closed
