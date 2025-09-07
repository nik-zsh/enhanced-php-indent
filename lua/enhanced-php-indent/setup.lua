-- enhanced-php-indent setup with HTML support (FIXED CONTEXT DETECTION)
local M = {}

-- Load the original plugin and HTML module
local original = require("enhanced-php-indent")
local html_indent = require("enhanced-php-indent.html")

-- HTML-specific configuration
local html_defaults = {
    -- HTML tag configuration
    html_indent_tags = {
        "html",
        "head",
        "body",
        "div",
        "section",
        "article",
        "header",
        "footer",
        "nav",
        "main",
        "aside",
        "form",
        "fieldset",
        "legend",
        "label",
        "ul",
        "ol",
        "li",
        "dl",
        "dt",
        "dd",
        "table",
        "caption",
        "thead",
        "tbody",
        "tfoot",
        "tr",
        "th",
        "td",
        "blockquote",
        "figure",
        "figcaption",
        "pre",
        "address",
    },
    html_self_closing_tags = {
        "area",
        "base",
        "br",
        "col",
        "embed",
        "hr",
        "img",
        "input",
        "link",
        "meta",
        "param",
        "source",
        "track",
        "wbr",
    },
    html_inline_tags = {
        "a",
        "abbr",
        "b",
        "cite",
        "code",
        "em",
        "i",
        "kbd",
        "mark",
        "q",
        "samp",
        "small",
        "span",
        "strong",
        "sub",
        "sup",
        "time",
        "var",
    },

    -- HTML indentation options
    enable_html_indent = true,
    html_debug = false,
}

-- FIXED: Simple and reliable context detection
local function detect_context(lnum)
    local line = vim.fn.getline(lnum)
    if not line then
        return "html"
    end

    local line_clean = vim.trim(line)

    -- RULE 1: If current line has PHP opening tag, it's PHP
    if line_clean:find("<%?php") or line_clean:find("<%?=") or line_clean:find("<%?%s") then
        return "php"
    end

    -- RULE 2: If current line has PHP closing tag, it's PHP (the closing line itself)
    if line_clean:find("%?>") then
        return "php"
    end

    -- RULE 3: Search backwards to find the most recent context marker
    local search_limit = math.max(1, lnum - 30)
    local found_php_open = false
    local found_php_close = false

    for i = lnum - 1, search_limit, -1 do
        local check_line = vim.fn.getline(i)
        if check_line then
            local check_clean = vim.trim(check_line)

            -- Found PHP closing tag first - we're in HTML context
            if not found_php_open and check_clean:find("%?>") then
                found_php_close = true
                break
            end

            -- Found PHP opening tag first - we're in PHP context
            if
                not found_php_close
                and (check_clean:find("<%?php") or check_clean:find("<%?=") or check_clean:find("<%?%s"))
            then
                found_php_open = true
                break
            end
        end
    end

    -- Return context based on what we found
    if found_php_open and not found_php_close then
        return "php"
    else
        return "html"
    end
end

-- Enhanced indent function with FIXED HTML support
local function enhanced_indent_with_html()
    local lnum = vim.v.lnum
    local line = vim.fn.getline(lnum)
    if not line then
        return _G.EnhancedPhpIndentOriginal()
    end

    local context = detect_context(lnum)
    local line_clean = vim.trim(line)

    if M.config.html_debug then
        print("Enhanced: Line " .. lnum .. " context=" .. context .. " content='" .. line_clean .. "'")
    end

    -- FIXED: Apply HTML indentation ONLY for HTML context
    if context == "html" and M.config.enable_html_indent then
        local result = html_indent.get_indent(lnum, M.config)
        if result ~= nil then
            if M.config.html_debug then
                print("  Using HTML indent: " .. result)
            end
            return result
        end
    end

    -- FIXED: Apply PHP indentation for PHP context OR fallback
    if M.config.html_debug then
        print("  Using PHP indent (context=" .. context .. ")")
    end
    return _G.EnhancedPhpIndentOriginal()
end

-- Setup with HTML support
function M.setup_with_html(opts)
    opts = opts or {}

    -- Merge with HTML defaults
    local final_config = vim.tbl_deep_extend("force", html_defaults, opts)
    M.config = final_config

    -- Call original setup first
    original.setup(final_config)

    -- Store original function and replace with enhanced version
    if not _G.EnhancedPhpIndentOriginal then
        _G.EnhancedPhpIndentOriginal = _G.EnhancedPhpIndent
    end

    _G.EnhancedPhpIndent = enhanced_indent_with_html

    if final_config.html_debug then
        print("Enhanced PHP Indent with HTML support loaded")
        print("  HTML indentation: " .. tostring(final_config.enable_html_indent))
    end
end

-- Standard setup (unchanged)
M.setup = original.setup

-- Provide access to original
M.original = original

return M
