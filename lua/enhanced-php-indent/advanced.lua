-- enhanced-php-indent.nvim - Advanced Setup with Frontend Language Support
-- Adds HTML, CSS, and JavaScript indentation to PHP files
local M = {}

-- Load the original plugin
local original = require("enhanced-php-indent")

-- Frontend language configuration
local frontend_defaults = {
	-- Frontend language support
	enable_html_indent = false, -- Enable HTML tag indentation
	enable_css_indent = false, -- Enable CSS indentation in <style> tags
	enable_js_indent = false, -- Enable JavaScript indentation in <script> tags

	-- HTML-specific options
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
		"details",
		"summary",
		"dialog",
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
		"acronym",
		"b",
		"bdi",
		"bdo",
		"big",
		"button",
		"cite",
		"code",
		"dfn",
		"em",
		"i",
		"kbd",
		"mark",
		"q",
		"rp",
		"rt",
		"ruby",
		"s",
		"samp",
		"small",
		"span",
		"strong",
		"sub",
		"sup",
		"time",
		"tt",
		"u",
		"var",
	},

	-- CSS-specific options
	css_indent_rules = true, -- Indent CSS rules and properties
	css_indent_at_rules = true, -- Indent @media, @keyframes, etc.

	-- JavaScript-specific options
	js_indent_switch_case = true, -- Indent switch case statements
	js_indent_objects = true, -- Indent object literals
	js_indent_arrays = true, -- Indent array literals
	js_indent_functions = true, -- Indent function bodies

	-- Debug options
	frontend_debug = false, -- Debug frontend language processing
}

-- Load frontend language modules
local html_indent = require("enhanced-php-indent.frontend.html")
local css_indent = require("enhanced-php-indent.frontend.css")
local js_indent = require("enhanced-php-indent.frontend.javascript")

-- Context detection
local function detect_context(lnum)
	local search_lnum = lnum
	local context = "php"
	local max_search = 100

	while search_lnum > 0 and search_lnum > (lnum - max_search) do
		local line = vim.fn.getline(search_lnum)

		-- PHP context
		if line:find("<%?php") or line:find("<%?=") or line:find("<%?%s") then
			context = "php"
			break
		end

		if line:find("%?>") then
			context = "html"
		end

		-- JavaScript context
		if line:match("<script[^>]*>%s*$") then
			context = "javascript"
			break
		end

		if line:find("</script>") then
			context = "html"
		end

		-- CSS context
		if line:match("<style[^>]*>%s*$") then
			context = "css"
			break
		end

		if line:find("</style>") then
			context = "html"
		end

		search_lnum = search_lnum - 1
	end

	return context
end

-- Enhanced indent function with frontend support
local function enhanced_indent_with_frontend()
	local lnum = vim.v.lnum
	local line = vim.fn.getline(lnum)
	local line_clean = vim.trim(line)

	-- Detect current context
	local context = detect_context(lnum)

	if M.config.frontend_debug then
		print("Frontend: Line " .. lnum .. " context=" .. context .. " line=" .. line_clean)
	end

	-- Apply context-specific indentation
	if context == "html" and M.config.enable_html_indent then
		local result = html_indent.get_indent(lnum, M.config)
		if result then
			return result
		end
	elseif context == "css" and M.config.enable_css_indent then
		local result = css_indent.get_indent(lnum, M.config)
		if result then
			return result
		end
	elseif context == "javascript" and M.config.enable_js_indent then
		local result = js_indent.get_indent(lnum, M.config)
		if result then
			return result
		end
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
			print("Frontend indentation enabled for:", {
				html = final_config.enable_html_indent,
				css = final_config.enable_css_indent,
				js = final_config.enable_js_indent,
			})
		end
	end
end

-- Standard setup (unchanged)
M.setup = original.setup

-- Provide access to original
M.original = original

return M
