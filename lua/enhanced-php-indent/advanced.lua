-- enhanced-php-indent.nvim - Advanced Setup with Frontend Language Support (FIXED)
-- Adds HTML, CSS, and JavaScript indentation to PHP files
local M = {}

-- Load the original plugin
local original = require('enhanced-php-indent')

-- Frontend language configuration
local frontend_defaults = {
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
    'a', 'abbr', 'acronym', 'b', 'bdi', 'bdo', 'big', 'button', 'cite', 'code',
    'dfn', 'em', 'i', 'kbd', 'mark', 'q', 'rp', 'rt', 'ruby', 's', 'samp',
    'small', 'span', 'strong', 'sub', 'sup', 'time', 'tt', 'u', 'var'
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
}

-- Load frontend language modules
local html_indent = require('enhanced-php-indent.frontend.html')
local css_indent = require('enhanced-php-indent.frontend.css')
local js_indent = require('enhanced-php-indent.frontend.javascript')

-- IMPROVED: Document parser for accurate context detection
local DocumentParser = {}

function DocumentParser.parse_document()
  local total_lines = vim.fn.line('$')
  local regions = {}
  local i = 1

  while i <= total_lines do
    local line = vim.fn.getline(i)
    local line_clean = vim.trim(line)

    -- PHP regions
    local php_start = line:find('<%?php') or line:find('<%?=') or line:find('<%?%s')
    if php_start then
      local php_end_line = i
      local found_end = false

      -- Look for PHP closing tag
      while php_end_line <= total_lines and not found_end do
        local check_line = vim.fn.getline(php_end_line)
        if check_line:find('%?>') then
          found_end = true
        else
          php_end_line = php_end_line + 1
        end
      end

      table.insert(regions, {
        type = 'php',
        start_line = i,
        end_line = found_end and php_end_line or total_lines
      })

      i = found_end and php_end_line + 1 or total_lines + 1
      goto continue
    end

    -- Script regions
    if line_clean:match('<script[^>]*>%s*$') then
      local script_end_line = i + 1
      local found_end = false

      while script_end_line <= total_lines and not found_end do
        local check_line = vim.trim(vim.fn.getline(script_end_line))
        if check_line:find('</script>') then
          found_end = true
        else
          script_end_line = script_end_line + 1
        end
      end

      if found_end then
        table.insert(regions, {
          type = 'javascript',
          start_line = i + 1,
          end_line = script_end_line - 1
        })
        i = script_end_line + 1
      else
        i = i + 1
      end
      goto continue
    end

    -- Style regions
    if line_clean:match('<style[^>]*>%s*$') then
      local style_end_line = i + 1
      local found_end = false

      while style_end_line <= total_lines and not found_end do
        local check_line = vim.trim(vim.fn.getline(style_end_line))
        if check_line:find('</style>') then
          found_end = true
        else
          style_end_line = style_end_line + 1
        end
      end

      if found_end then
        table.insert(regions, {
          type = 'css',
          start_line = i + 1,
          end_line = style_end_line - 1
        })
        i = style_end_line + 1
      else
        i = i + 1
      end
      goto continue
    end

    ::continue::
    i = i + 1
  end

  return regions
end

function DocumentParser.get_context_for_line(lnum)
  local regions = DocumentParser.parse_document()

  -- Check if line is within any special region
  for _, region in ipairs(regions) do
    if lnum >= region.start_line and lnum <= region.end_line then
      return region.type
    end
  end

  -- Default to HTML context
  return 'html'
end

-- Enhanced indent function with improved frontend support
local function enhanced_indent_with_frontend()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local line_clean = vim.trim(line)

  -- Use improved context detection
  local context = DocumentParser.get_context_for_line(lnum)

  if M.config.frontend_debug then
    print("Frontend: Line " .. lnum .. " context=" .. context .. " line=" .. line_clean)
  end

  -- Apply context-specific indentation
  if context == 'html' and M.config.enable_html_indent then
    local result = html_indent.get_indent(lnum, M.config)
    if result then return result end
  elseif context == 'css' and M.config.enable_css_indent then
    local result = css_indent.get_indent(lnum, M.config)
    if result then return result end
  elseif context == 'javascript' and M.config.enable_js_indent then
    local result = js_indent.get_indent(lnum, M.config)
    if result then return result end
  end

  -- Fallback to original PHP indentation
  return _G.EnhancedPhpIndentOriginal()
end

-- Advanced setup function
function M.advanced_setup(opts)
  opts = opts or {}

  -- Merge with frontend defaults
  local final_config = vim.tbl_deep_extend("force", frontend_defaults, opts)

  -- Store the configuration
  M.config = final_config

  -- Call original setup first
  original.setup(final_config)

  -- Only replace indent function if frontend languages are enabled
  if final_config.enable_html_indent or final_config.enable_css_indent or final_config.enable_js_indent then
    -- Store original function
    if not _G.EnhancedPhpIndentOriginal then
      _G.EnhancedPhpIndentOriginal = _G.EnhancedPhpIndent
    end

    -- Replace with enhanced function
    _G.EnhancedPhpIndent = enhanced_indent_with_frontend

    if final_config.frontend_debug then
      -- FIXED: Show proper boolean values instead of table reference
      print("Frontend indentation enabled for:")
      print("  HTML: " .. tostring(final_config.enable_html_indent))
      print("  CSS: " .. tostring(final_config.enable_css_indent))
      print("  JavaScript: " .. tostring(final_config.enable_js_indent))
    end
  end
end

-- Standard setup (unchanged)
M.setup = original.setup

-- Provide access to original
M.original = original

return M
