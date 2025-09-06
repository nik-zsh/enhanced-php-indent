-- FILE: lua/enhanced-php-indent/html.lua
-- Simplified HTML Extension - standalone, no interference with PHP
local M = {}

-- HTML configuration
M.config = {
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

-- Detect current context (PHP or HTML)
local function get_context_type(lnum)
  local search_lnum = lnum
  local in_php = false
  local max_search = 30  -- Reduced search for performance

  while search_lnum > 0 and search_lnum > (lnum - max_search) do
    local line = vim.fn.getline(search_lnum)

    -- Check for PHP opening tags
    if line:find('<%?php') or line:find('<%?=') or line:find('<%?%s') then
      in_php = true
      break
    end

    -- Check for PHP closing tags
    if line:find('%?>') then
      in_php = false
      break
    end

    search_lnum = search_lnum - 1
  end

  return in_php and 'php' or 'html'
end

-- Parse HTML tag from line
local function parse_html_tag(line_clean)
  -- Opening tag: <div>, <body class="test">
  local opening_tag = line_clean:match('^<([%w%-]+)')
  if opening_tag then
    return opening_tag:lower(), 'opening'
  end

  -- Closing tag: </div>, </body>
  local closing_tag = line_clean:match('^</([%w%-]+)')
  if closing_tag then
    return closing_tag:lower(), 'closing'
  end

  -- Self-closing: <br/>, <img src="..."/>
  local self_closing = line_clean:match('^<([%w%-]+).*/%s*>')
  if self_closing then
    return self_closing:lower(), 'self_closing'
  end

  return nil, nil
end

-- Check if tag should indent its content
local function should_indent_html_tag(tag_name, config)
  for _, indent_tag in ipairs(config.html_indent_tags) do
    if tag_name == indent_tag:lower() then
      return true
    end
  end
  return false
end

-- Check if tag is inline
local function is_inline_html_tag(tag_name, config)
  for _, inline_tag in ipairs(config.html_inline_tags) do
    if tag_name == inline_tag:lower() then
      return true
    end
  end
  return false
end

-- Find matching HTML opening tag
local function find_html_opening_tag(lnum, closing_tag)
  local search_lnum = lnum - 1
  local tag_count = 1
  local max_search = 50  -- Limit search scope

  while search_lnum > 0 and tag_count > 0 and (lnum - search_lnum) < max_search do
    local line = vim.fn.getline(search_lnum)
    local line_clean = vim.trim(line)

    -- Skip PHP blocks when looking for HTML tags
    if get_context_type(search_lnum) == 'php' then
      search_lnum = search_lnum - 1
      goto continue
    end

    local tag_name, tag_type = parse_html_tag(line_clean)

    if tag_name and tag_name == closing_tag then
      if tag_type == 'closing' then
        tag_count = tag_count + 1
      elseif tag_type == 'opening' then
        tag_count = tag_count - 1
        if tag_count == 0 then
          return search_lnum
        end
      end
    end

    ::continue::
    search_lnum = search_lnum - 1
  end

  return nil
end

-- HTML indent function - CONSERVATIVE approach
local function get_html_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, config)
  -- Skip if HTML indentation is disabled
  if not config.enable_html_indent then
    return nil
  end

  -- Only process when in HTML context
  local context = get_context_type(lnum)
  if context ~= 'html' then
    return nil  -- Let PHP handle it
  end

  if config.html_debug then
    print("HTML: Processing line " .. lnum .. " in HTML context: " .. line_clean)
  end

  -- Handle HTML closing tags
  local tag_name, tag_type = parse_html_tag(line_clean)
  if tag_name and tag_type == 'closing' then
    local opening_lnum = find_html_opening_tag(lnum, tag_name)
    if opening_lnum then
      return vim.fn.indent(opening_lnum) + base_indent
    else
      return math.max(prev_indent - sw, base_indent)
    end
  end

  -- Handle self-closing tags
  if tag_name and tag_type == 'self_closing' then
    return prev_indent
  end

  -- Handle content after HTML opening tags
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  if prev_lnum > 0 then
    local prev_line = vim.fn.getline(prev_lnum)
    local prev_line_clean = vim.trim(prev_line)
    local prev_tag_name, prev_tag_type = parse_html_tag(prev_line_clean)

    if prev_tag_name and prev_tag_type == 'opening' then
      if should_indent_html_tag(prev_tag_name, config) and not is_inline_html_tag(prev_tag_name, config) then
        return vim.fn.indent(prev_lnum) + sw
      end
    end
  end

  -- Handle PHP tags within HTML context
  if line_clean:find('^<%?') then
    if config.html_preserve_php_indent then
      return prev_indent
    else
      return base_indent
    end
  end

  -- Default: maintain previous indentation in HTML context
  return prev_indent
end

-- CONSERVATIVE integration - minimal modification to original behavior
function M.setup(config)
  -- Merge HTML config
  for key, value in pairs(M.config) do
    if config[key] == nil then
      config[key] = value
    end
  end

  if config.html_debug then
    print("HTML Extension loaded")
  end

  -- ONLY modify global function if HTML is explicitly enabled
  if config.enable_html_indent then
    -- Store original function if not already stored
    if not _G.EnhancedPhpIndentOriginal then
      _G.EnhancedPhpIndentOriginal = _G.EnhancedPhpIndent
    end

    -- Create wrapper function that tries HTML first, then falls back to original PHP
    _G.EnhancedPhpIndent = function()
      local lnum = vim.v.lnum
      local line = vim.fn.getline(lnum)
      local prev_lnum = vim.fn.prevnonblank(lnum - 1)
      local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
      local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
      local sw = vim.fn.shiftwidth()

      local line_clean = vim.trim(line)
      local prev_clean = vim.trim(prev_line)
      local base_indent = config.default_indenting or 0

      -- Try HTML indentation first
      local html_result = get_html_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, config)
      if html_result then
        return html_result
      end

      -- Fallback to ORIGINAL PHP indentation
      return _G.EnhancedPhpIndentOriginal()
    end

    if config.html_debug then
      print("HTML Extension: Wrapped original indent function")
    end
  end
end

return M