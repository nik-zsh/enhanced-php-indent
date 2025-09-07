-- enhanced-php-indent setup with HTML support
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

-- Simple context detection (PHP vs HTML)
local function detect_context(lnum)
    local line = vim.fn.getline(lnum)
    if not line then
        return "html"
    end

    -- Check current line first
    if line:find("<%?php") or line:find("<%?=") then
        return "php"
    end

    -- Search backwards for context
    for i = lnum - 1, math.max(1, lnum - 10), -1 do
        local check_line = vim.fn.getline(i)
        if check_line then
            -- PHP opening tag
            if check_line:find("<%?php") or check_line:find("<%?=") then
                -- Look for closing tag
                for j = i, lnum do
                    local php_line = vim.fn.getline(j)
                    if php_line and php_line:find("%?>") then
                        if lnum > j then
                            return "html" -- After PHP closing tag
                        else
                            return "php" -- Inside PHP block
                        end
                    end
                end
                return "php" -- PHP not closed, assume PHP context
            end

            -- PHP closing tag
            if check_line:find("%?>") then
                return "html" -- After PHP closing tag
            end
        end
    end

    return "html" -- Default to HTML
end

-- Enhanced indent function with HTML support
local function enhanced_indent_with_html()
    local lnum = vim.v.lnum
    local context = detect_context(lnum)

    if M.config.html_debug then
        local line = vim.fn.getline(lnum)
        print("Enhanced: Line " .. lnum .. " context=" .. context .. " line=" .. vim.trim(line))
    end

    -- Use HTML indentation for HTML context
    if context == "html" and M.config.enable_html_indent then
        local result = html_indent.get_indent(lnum, M.config)
        if result ~= nil then
            if M.config.html_debug then
                print("  HTML result: " .. result)
            end
            return result
        end
    end

    -- Fallback to PHP indentation
    if M.config.html_debug then
        print("  Using PHP indentation")
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
    end
end

-- Standard setup (unchanged)
M.setup = original.setup

-- Provide access to original
M.original = original

return M
