-- Simple HTML indentation that actually works (FIXED)
local M = {}

-- Simple function to check if a tag should indent its content
local function should_indent(tag_name)
	if not tag_name then
		return false
	end

	-- Convert to lowercase
	tag_name = tag_name:lower()

	-- Block-level tags that indent content
	local block_tags = {
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
		"ul",
		"ol",
		"li",
		"table",
		"thead",
		"tbody",
		"tfoot",
		"tr",
		"th",
		"td",
		"blockquote",
		"figure",
		"details",
	}

	for _, block_tag in ipairs(block_tags) do
		if tag_name == block_tag then
			return true
		end
	end

	return false
end

-- Parse HTML tag from line
local function get_tag_info(line)
	if not line or line == "" then
		return nil, nil
	end

	-- Skip PHP code
	if line:find("<%?") or line:find("%?>") then
		return nil, nil
	end

	-- Closing tag: </div>
	local closing = line:match("^%s*</%s*([%w%-]+)")
	if closing then
		return closing:lower(), "close"
	end

	-- Self-closing: <br />
	local self_closing = line:match("^%s*<%s*([%w%-]+)[^>]*/%s*>")
	if self_closing then
		return self_closing:lower(), "self"
	end

	-- Opening tag: <div>
	local opening = line:match("^%s*<%s*([%w%-]+)")
	if opening then
		return opening:lower(), "open"
	end

	return nil, nil
end

-- Find the line with matching opening tag
local function find_opening_tag_line(lnum, close_tag_name)
	local count = 1
	local search_line = lnum - 1

	while search_line > 0 and count > 0 and (lnum - search_line) < 50 do
		local line = vim.fn.getline(search_line)
		if line then
			local tag_name, tag_type = get_tag_info(vim.trim(line))

			if tag_name == close_tag_name then
				if tag_type == "close" then
					count = count + 1
				elseif tag_type == "open" then
					count = count - 1
					if count == 0 then
						return search_line
					end
				end
			end
		end
		search_line = search_line - 1
	end

	return nil
end

-- Main HTML indentation function
function M.get_indent(lnum, config)
	local line = vim.fn.getline(lnum)
	if not line then
		return nil
	end

	local line_clean = vim.trim(line)
	local prev_lnum = vim.fn.prevnonblank(lnum - 1)
	local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
	local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
	local sw = vim.fn.shiftwidth()

	if config.html_debug then
		print("    HTML SIMPLE: Line " .. lnum .. " = '" .. line_clean .. "'")
		print("    HTML SIMPLE: prev_indent=" .. prev_indent .. " shiftwidth=" .. sw)
	end

	-- Handle empty lines
	if line_clean == "" then
		if config.html_debug then
			print("    HTML SIMPLE: Empty line, return " .. prev_indent)
		end
		return prev_indent
	end

	-- Don't process PHP code
	if line_clean:find("<%?") or line_clean:find("%?>") then
		if config.html_debug then
			print("    HTML SIMPLE: PHP code, return nil")
		end
		return nil
	end

	-- Get tag information
	local tag_name, tag_type = get_tag_info(line_clean)

	if tag_name then
		if config.html_debug then
			print("    HTML SIMPLE: Found " .. tag_type .. " tag: " .. tag_name)
		end

		-- Handle closing tags
		if tag_type == "close" then
			if should_indent(tag_name) then
				local opening_line = find_opening_tag_line(lnum, tag_name)
				if opening_line then
					local result = vim.fn.indent(opening_line)
					if config.html_debug then
						print(
							"    HTML SIMPLE: Closing "
								.. tag_name
								.. " aligns with line "
								.. opening_line
								.. " = "
								.. result
						)
					end
					return result
				else
					local result = math.max(prev_indent - sw, 0)
					if config.html_debug then
						print("    HTML SIMPLE: Closing " .. tag_name .. " dedent = " .. result)
					end
					return result
				end
			else
				if config.html_debug then
					print("    HTML SIMPLE: Inline closing " .. tag_name .. " = " .. prev_indent)
				end
				return prev_indent
			end

			-- Handle self-closing tags
		elseif tag_type == "self" then
			if config.html_debug then
				print("    HTML SIMPLE: Self-closing " .. tag_name .. " = " .. prev_indent)
			end
			return prev_indent

			-- Handle opening tags
		elseif tag_type == "open" then
			if config.html_debug then
				print("    HTML SIMPLE: Opening " .. tag_name .. " = " .. prev_indent)
			end
			return prev_indent
		end
	end

	-- Check if we should indent because previous line was opening block tag
	if prev_line and prev_line ~= "" then
		local prev_tag_name, prev_tag_type = get_tag_info(vim.trim(prev_line))

		if prev_tag_name and prev_tag_type == "open" and should_indent(prev_tag_name) then
			local result = prev_indent + sw
			if config.html_debug then
				print("    HTML SIMPLE: Content after " .. prev_tag_name .. " = " .. result)
			end
			return result
		end
	end

	-- Handle DOCTYPE
	if line_clean:find("^%s*<!DOCTYPE") then
		if config.html_debug then
			print("    HTML SIMPLE: DOCTYPE = 0")
		end
		return 0
	end

	-- Default case
	if config.html_debug then
		print("    HTML SIMPLE: Default case = " .. prev_indent)
	end
	return prev_indent
end

return M
