-- enhanced-php-indent.nvim - Content-Aware Language Detection (SYNTAX FIXED)
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

-- FIXED: Language detection patterns with proper Lua syntax
local function has_php_patterns(line)
  if not line then return false end

  -- PHP variable: $variable
  if line:find('%$[%w_]+') then return true end

  -- PHP arrow operator: ->
  if line:find('%-[>]') then return true end

  -- PHP tags
  if line:find('<%?php') or line:find('<%?=') then return true end

  -- PHP keywords
  local php_keywords = {'function', 'class', 'public', 'private', 'protected', 'namespace', 'use', 'array'}
  for _, keyword in ipairs(php_keywords) do
    if line:find('%f[%a]' .. keyword .. '%f[%A]') then return true end
  end

  return false
end

local function has_javascript_patterns(line)
  if not line then return false end

  -- JavaScript variable declarations
  if line:find('%f[%a]let%s+[%w_]') or 
     line:find('%f[%a]const%s+[%w_]') or 
     line:find('%f[%a]var%s+[%w_]') then 
    return true 
  end

  -- JavaScript-specific objects
  if line:find('console%.') or 
     line:find('document%.') or 
     line:find('window%.') then 
    return true 
  end

  -- JavaScript keywords
  local js_keywords = {'function', 'if', 'for', 'while', 'switch', 'case', 'default', 'return'}
  for _, keyword in ipairs(js_keywords) do
    if line:find('%f[%a]' .. keyword .. '%f[%A]') then return true end
  end

  return false
end

local function has_css_patterns(line)
  if not line then return false end

  -- CSS properties: property: value;
  if line:find('^%s*[%w%-]+%s*:%s*[^;]+;?') then return true end

  -- CSS selectors ending with {
  if line:find('^%s*[%w%.#:%-%[%]%s,>+~*]+%s*{%s*$') then return true end

  -- CSS at-rules
  if line:find('^%s*@[%w%-]+') then return true end

  return false
end

local function has_html_patterns(line)
  if not line then return false end

  -- HTML tags
  if line:find('<%/?[%w%-]+[^>]*>') then return true end

  -- DOCTYPE
  if line:find('<!DOCTYPE') then return true end

  -- HTML attributes
  if line:find('[%w%-]+%s*=%s*["'][^"']*["']') then return true end

  return false
end

-- FIXED: Content-aware language detection with proper scoring
local function analyze_content_for_language(start_lnum, scan_lines)
  local scores = {php = 0, javascript = 0, css = 0, html = 0}
  local total_lines = vim.fn.line('$')
  local end_lnum = math.min(total_lines, start_lnum + scan_lines - 1)

  for lnum = start_lnum, end_lnum do
    local line = vim.fn.getline(lnum)
    if not line then break end

    local line_clean = vim.trim(line)
    if line_clean == "" then
      -- Skip empty lines
    else
      -- Score each language based on patterns
      if has_php_patterns(line_clean) then
        scores.php = scores.php + 2
      end

      if has_javascript_patterns(line_clean) then
        scores.javascript = scores.javascript + 2
      end

      if has_css_patterns(line_clean) then
        scores.css = scores.css + 2
      end

      if has_html_patterns(line_clean) then
        scores.html = scores.html + 1
      end
    end
  end

  return scores
end

-- FIXED: Language detection with proper context checking
local function detect_language_content_aware(lnum)
  local line = vim.fn.getline(lnum)
  if not line then return 'html' end

  -- First check for explicit context markers within 5 lines
  local context_search = 5
  local total_lines = vim.fn.line('$')

  for i = math.max(1, lnum - context_search), math.min(total_lines, lnum + 3) do
    local check_line = vim.fn.getline(i)
    if check_line then
      -- PHP context markers
      if check_line:find('<%?php') or check_line:find('<%?=') then
        -- Look for closing PHP tag
        for j = i, math.min(total_lines, i + 20) do
          local php_line = vim.fn.getline(j)
          if php_line and php_line:find('%?>') then
            if lnum >= i and lnum <= j then return 'php' end
            break
          end
        end
        if lnum >= i then return 'php' end -- Unclosed PHP
      end

      -- Script context markers  
      if check_line:find('<script[^>]*>%s*$') then
        for j = i + 1, math.min(total_lines, i + 50) do
          local script_line = vim.fn.getline(j)
          if script_line and script_line:find('</script>') then
            if lnum > i and lnum < j then return 'javascript' end
            break
          end
        end
      end

      -- Style context markers
      if check_line:find('<style[^>]*>%s*$') then
        for j = i + 1, math.min(total_lines, i + 50) do
          local style_line = vim.fn.getline(j)
          if style_line and style_line:find('</style>') then
            if lnum > i and lnum < j then return 'css' end
            break
          end
        end
      end
    end
  end

  -- Content-aware analysis with limited scan
  local scan_start = math.max(1, lnum - 5)
  local scores = analyze_content_for_language(scan_start, 10)

  -- Find highest scoring language
  local max_score = 0
  local detected_language = 'html'

  for lang, score in pairs(scores) do
    if score > max_score then
      max_score = score
      detected_language = lang
    end
  end

  -- Fallback to HTML if no clear winner
  if max_score == 0 then
    detected_language = 'html'
  end

  return detected_language
end

-- Cache for performance
local context_cache = {}
local last_lnum = -1

-- Enhanced indent function with content-aware detection
local function enhanced_indent_content_aware()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)

  if not line then return _G.EnhancedPhpIndentOriginal() end

  local line_clean = vim.trim(line)

  -- Clear cache if user jumped to different line
  if math.abs(lnum - last_lnum) > 1 then
    context_cache = {}
  end
  last_lnum = lnum

  -- Use cached context if available
  local context
  if context_cache[lnum] then
    context = context_cache[lnum]
  else
    context = detect_language_content_aware(lnum)
    context_cache[lnum] = context
  end

  if M.config.frontend_debug then
    print("ContentAware: Line " .. lnum .. " language=" .. context .. " content=" .. line_clean)
  end

  -- Apply context-specific indentation
  if context == 'html' and M.config.enable_html_indent then
    local result = html_indent.get_indent(lnum, M.config)
    if result ~= nil then 
      if M.config.frontend_debug then print("  HTML result: " .. result) end
      return result 
    end
  elseif context == 'css' and M.config.enable_css_indent then
    local result = css_indent.get_indent(lnum, M.config)
    if result ~= nil then 
      if M.config.frontend_debug then print("  CSS result: " .. result) end
      return result 
    end
  elseif context == 'javascript' and M.config.enable_js_indent then
    local result = js_indent.get_indent(lnum, M.config)
    if result ~= nil then 
      if M.config.frontend_debug then print("  JS result: " .. result) end
      return result 
    end
  end

  -- Fallback to original PHP indentation
  if M.config.frontend_debug then print("  Using PHP fallback") end
  return _G.EnhancedPhpIndentOriginal()
end

-- Advanced setup function
function M.advanced_setup(opts)
  opts = opts or {}
  local final_config = vim.tbl_deep_extend("force", frontend_defaults, opts)
  M.config = final_config

  original.setup(final_config)

  if final_config.enable_html_indent or final_config.enable_css_indent or final_config.enable_js_indent then
    if not _G.EnhancedPhpIndentOriginal then
      _G.EnhancedPhpIndentOriginal = _G.EnhancedPhpIndent
    end

    _G.EnhancedPhpIndent = enhanced_indent_content_aware

    if final_config.frontend_debug then
      print("Content-Aware Frontend enabled:")
      print("  HTML: " .. tostring(final_config.enable_html_indent))
      print("  CSS: " .. tostring(final_config.enable_css_indent))
      print("  JavaScript: " .. tostring(final_config.enable_js_indent))
    end
  end
end

M.setup = original.setup
M.original = original

return M
