-- enhanced-php-indent.nvim - Advanced Setup with Robust Context Detection (FIXED)
local M = {}

-- Load the original plugin
local original = require('enhanced-php-indent')

-- Frontend language configuration
local frontend_defaults = {
  enable_html_indent = false,
  enable_css_indent = false,
  enable_js_indent = false,

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

  css_indent_rules = true,
  css_indent_at_rules = true,

  js_indent_switch_case = true,
  js_indent_objects = true,
  js_indent_arrays = true,
  js_indent_functions = true,

  frontend_debug = false,
}

-- Load frontend language modules
local html_indent = require('enhanced-php-indent.frontend.html')
local css_indent = require('enhanced-php-indent.frontend.css')
local js_indent = require('enhanced-php-indent.frontend.javascript')

-- ROBUST: Simple and reliable context detection
local function detect_context(lnum)
  local max_search = 100
  local context = 'html'  -- Default context

  -- Search backwards for context markers
  for i = lnum, math.max(1, lnum - max_search), -1 do
    local line = vim.fn.getline(i)

    if not line then break end  -- Safety check

    -- PHP context (highest priority - overrides everything)
    if line:find('<%?php') or line:find('<%?=') or line:find('<%?%s') then
      -- Look forward for PHP closing tag
      for j = i, math.min(vim.fn.line('$'), i + 50) do
        local php_line = vim.fn.getline(j)
        if php_line and php_line:find('%?>') then
          -- Check if current line is within this PHP block
          if lnum >= i and lnum <= j then
            return 'php'
          end
          break
        elseif j == math.min(vim.fn.line('$'), i + 50) then
          -- PHP not closed, assume rest of file is PHP
          if lnum >= i then
            return 'php'
          end
        end
      end
    end

    -- JavaScript context  
    if line:match('<script[^>]*>%s*$') then
      -- Look forward for script closing tag
      for j = i + 1, math.min(vim.fn.line('$'), i + 200) do
        local js_line = vim.fn.getline(j)
        if js_line and js_line:find('</script>') then
          -- Check if current line is within this script block
          if lnum > i and lnum < j then
            return 'javascript'
          end
          break
        end
      end
    end

    -- CSS context
    if line:match('<style[^>]*>%s*$') then
      -- Look forward for style closing tag
      for j = i + 1, math.min(vim.fn.line('$'), i + 200) do
        local css_line = vim.fn.getline(j)
        if css_line and css_line:find('</style>') then
          -- Check if current line is within this style block
          if lnum > i and lnum < j then
            return 'css'
          end
          break
        end
      end
    end
  end

  return context
end

-- Enhanced indent function with robust frontend support
local function enhanced_indent_with_frontend()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)

  -- Safety check
  if not line then
    return _G.EnhancedPhpIndentOriginal()
  end

  local line_clean = vim.trim(line)

  -- Use robust context detection
  local context = detect_context(lnum)

  if M.config.frontend_debug then
    print("Frontend: Line " .. lnum .. " context=" .. context .. " line=" .. line_clean)
  end

  -- Apply context-specific indentation
  if context == 'html' and M.config.enable_html_indent then
    local result = html_indent.get_indent(lnum, M.config)
    if result ~= nil then 
      if M.config.frontend_debug then
        print("  HTML indent result: " .. tostring(result))
      end
      return result 
    end
  elseif context == 'css' and M.config.enable_css_indent then
    local result = css_indent.get_indent(lnum, M.config)
    if result ~= nil then 
      if M.config.frontend_debug then
        print("  CSS indent result: " .. tostring(result))
      end
      return result 
    end
  elseif context == 'javascript' and M.config.enable_js_indent then
    local result = js_indent.get_indent(lnum, M.config)
    if result ~= nil then 
      if M.config.frontend_debug then
        print("  JS indent result: " .. tostring(result))
      end
      return result 
    end
  end

  -- Fallback to original PHP indentation
  if M.config.frontend_debug then
    print("  Using original PHP indentation")
  end
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
      print("Frontend indentation enabled:")
      print("  HTML: " .. tostring(final_config.enable_html_indent))
      print("  CSS: " .. tostring(final_config.enable_css_indent))
      print("  JavaScript: " .. tostring(final_config.enable_js_indent))
      print("Enhanced PHP Indent (Advanced) loaded for: " .. vim.fn.expand('%:t'))
    end
  end
end

-- Standard setup (unchanged)
M.setup = original.setup

-- Provide access to original
M.original = original

return M
