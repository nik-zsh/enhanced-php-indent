-- Multi-language indentation support for enhanced-php-indent.nvim
-- Handles HTML, JavaScript, and CSS within PHP files
local M = {}

-- Context detection: determines what language we're currently in
local function detect_context(lnum)
	local search_lnum = lnum
	local context = "php" -- default
	local max_search = 50

	while search_lnum > 0 and search_lnum > (lnum - max_search) do
		local line = vim.fn.getline(search_lnum)

		-- PHP context markers
		if line:find("<%?php") or line:find("<%?=") or line:find("<%?%s") then
			context = "php"
			break
		end

		if line:find("%?>") then
			context = "html"
			-- Continue searching for more specific contexts
		end

		-- JavaScript context (script tags on separate lines)
		if line:match("<script[^>]*>%s*$") then
			context = "javascript"
			break
		end

		if line:find("</script>") then
			context = "html"
			-- Continue searching
		end

		-- CSS context (style tags on separate lines)
		if line:match("<style[^>]*>%s*$") then
			context = "css"
			break
		end

		if line:find("</style>") then
			context = "html"
			-- Continue searching
		end

		search_lnum = search_lnum - 1
	end

	return context
end

-- HTML indentation logic
local function indent_html(lnum, line_clean, prev_indent, sw, base_indent)
	local html_block_tags = {
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
		"ul",
		"ol",
		"li",
		"table",
		"thead",
		"tbody",
		"tr",
		"td",
		"th",
		"fieldset",
		"blockquote",
		"figure",
		"figcaption",
	}

	-- Handle closing tags
	local closing_tag = line_clean:match("^</([%w%-]+)")
	if closing_tag then
		return math.max(prev_indent - sw, base_indent)
	end

	-- Handle self-closing tags (no indent change)
	if line_clean:match("^<[^>]+/>") then
		return prev_indent
	end

	-- Handle content after opening tags
	local prev_lnum = vim.fn.prevnonblank(lnum - 1)
	if prev_lnum > 0 then
		local prev_line = vim.trim(vim.fn.getline(prev_lnum))
		local opening_tag = prev_line:match("<([%w%-]+)[^>]*>%s*$")

		if opening_tag then
			-- Check if it's a block-level tag that should indent
			for _, tag in ipairs(html_block_tags) do
				if opening_tag:lower() == tag then
					return vim.fn.indent(prev_lnum) + sw
				end
			end
		end
	end

	return prev_indent
end

-- JavaScript indentation logic
local function indent_javascript(lnum, line_clean, prev_clean, prev_indent, sw, base_indent)
	-- Handle closing braces
	if line_clean:match("^}") then
		return math.max(prev_indent - sw, base_indent)
	end

	-- Handle closing brackets and parentheses
	if line_clean:match("^%]") or line_clean:match("^%)") then
		return math.max(prev_indent - sw, base_indent)
	end

	-- After opening braces, functions, control structures
	if
		prev_clean:match("{%s*$")
		or prev_clean:match("function[^{]*{?%s*$")
		or prev_clean:match("=>%s*{?%s*$") -- arrow functions
		or prev_clean:match("if%s*%([^)]*%)%s*{?%s*$")
		or prev_clean:match("for%s*%([^)]*%)%s*{?%s*$")
		or prev_clean:match("while%s*%([^)]*%)%s*{?%s*$")
		or prev_clean:match("switch%s*%([^)]*%)%s*{?%s*$")
		or prev_clean:match("try%s*{?%s*$")
		or prev_clean:match("catch%s*%([^)]*%)%s*{?%s*$")
	then
		return prev_indent + sw
	end

	-- After array/object literals
	if prev_clean:match("%[%s*$") or prev_clean:match("=%s*{%s*$") then
		return prev_indent + sw
	end

	-- Case statements in switch
	if line_clean:match("^case%s+") or line_clean:match("^default%s*:") then
		return prev_indent
	end

	-- After case statements
	if prev_clean:match("^case%s+.*:") or prev_clean:match("^default%s*:") then
		return prev_indent + sw
	end

	return prev_indent
end

-- CSS indentation logic
local function indent_css(lnum, line_clean, prev_clean, prev_indent, sw, base_indent)
	-- Handle closing braces
	if line_clean:match("^}") then
		return math.max(prev_indent - sw, base_indent)
	end

	-- After selectors and opening braces
	if prev_clean:match("{%s*$") then
		return prev_indent + sw
	end

	-- After CSS selectors (without opening brace yet)
	if prev_clean:match("[%w%.#:%-]+%s*$") and not prev_clean:match(";%s*$") then
		-- Check if next non-blank line has opening brace
		local next_lnum = lnum
		while next_lnum <= vim.fn.line("$") do
			local next_line = vim.trim(vim.fn.getline(next_lnum))
			if next_line ~= "" then
				if next_line:match("^{") then
					return prev_indent
				end
				break
			end
			next_lnum = next_lnum + 1
		end
	end

	-- After at-rules (@media, @keyframes, etc.)
	if prev_clean:match("^@[%w%-]+") and prev_clean:match("{%s*$") then
		return prev_indent + sw
	end

	-- Properties inside rules
	if prev_clean:match(":") and not prev_clean:match("{") then
		return prev_indent
	end

	return prev_indent
end

-- Main function: determine context and apply appropriate indentation
function M.get_indent(lnum, line_clean, prev_clean, prev_indent, sw, base_indent, config)
	local context = detect_context(lnum)

	if config.multi_lang_debug then
		print("Multi-lang: Line " .. lnum .. " context=" .. context .. " line=" .. line_clean)
	end

	-- Apply context-specific indentation
	if context == "html" and config.enable_html_indent then
		return indent_html(lnum, line_clean, prev_indent, sw, base_indent)
	elseif context == "javascript" and config.enable_js_indent then
		return indent_javascript(lnum, line_clean, prev_clean, prev_indent, sw, base_indent)
	elseif context == "css" and config.enable_css_indent then
		return indent_css(lnum, line_clean, prev_clean, prev_indent, sw, base_indent)
	end

	-- Return nil to let PHP indentation handle it
	return nil
end

return M
