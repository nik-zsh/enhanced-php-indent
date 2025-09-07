-- JavaScript indentation for enhanced-php-indent.nvim
local M = {}

-- Check for function declarations
local function is_function_declaration(line_clean)
	return line_clean:match("^function%s+")
		or line_clean:match("^[%w_$]+%s*:%s*function")
		or line_clean:match("^[%w_$%.%[%]]+%s*=%s*function")
		or line_clean:match("=>%s*{?%s*$") -- Arrow functions
end

-- Check for control structures
local function is_control_structure(line_clean)
	return line_clean:match("^if%s*%(")
		or line_clean:match("^else%s*if%s*%(")
		or line_clean:match("^else%s*{?%s*$")
		or line_clean:match("^for%s*%(")
		or line_clean:match("^while%s*%(")
		or line_clean:match("^do%s*{?%s*$")
		or line_clean:match("^switch%s*%(")
		or line_clean:match("^try%s*{?%s*$")
		or line_clean:match("^catch%s*%(")
		or line_clean:match("^finally%s*{?%s*$")
end

-- Check for case/default statements
local function is_case_statement(line_clean)
	return line_clean:match("^case%s+") or line_clean:match("^default%s*:")
end

-- Find matching opening brace/bracket/paren
local function find_matching_open(lnum, close_char)
	local open_char = ({ ["}"] = "{", ["]"] = "[", [")"] = "(" })[close_char]
	if not open_char then
		return nil
	end

	local search_lnum = lnum - 1
	local count = 1
	local max_search = 200

	while search_lnum > 0 and count > 0 and (lnum - search_lnum) < max_search do
		local line = vim.fn.getline(search_lnum)

		for char in line:gmatch(".") do
			if char == close_char then
				count = count + 1
			elseif char == open_char then
				count = count - 1
				if count == 0 then
					return search_lnum
				end
			end
		end

		search_lnum = search_lnum - 1
	end

	return nil
end

-- Find switch statement for case indentation
local function find_switch_statement(lnum)
	local search_lnum = lnum - 1
	local brace_count = 0

	while search_lnum > 0 and search_lnum > (lnum - 100) do
		local line = vim.fn.getline(search_lnum)
		local line_clean = vim.trim(line)

		-- Count braces to stay in current scope
		for char in line:gmatch(".") do
			if char == "}" then
				brace_count = brace_count - 1
			elseif char == "{" then
				brace_count = brace_count + 1
			end
		end

		if brace_count == 1 and line_clean:match("switch%s*%(") then
			return search_lnum
		end

		search_lnum = search_lnum - 1
	end

	return nil
end

-- Main JavaScript indentation function
function M.get_indent(lnum, config)
	local line = vim.fn.getline(lnum)
	local line_clean = vim.trim(line)
	local prev_lnum = vim.fn.prevnonblank(lnum - 1)
	local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
	local prev_line_clean = vim.trim(prev_line)
	local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
	local sw = vim.fn.shiftwidth()
	local base_indent = config.default_indenting or 0

	-- Handle empty lines
	if line_clean == "" then
		return prev_indent
	end

	-- Handle closing braces, brackets, parentheses
	if line_clean:match("^[%}%]%)]") then
		local close_char = line_clean:sub(1, 1)
		local opening_lnum = find_matching_open(lnum, close_char)

		if opening_lnum then
			return vim.fn.indent(opening_lnum) + base_indent
		else
			return math.max(prev_indent - sw, base_indent)
		end
	end

	-- Handle case and default statements in switch
	if config.js_indent_switch_case and is_case_statement(line_clean) then
		local switch_lnum = find_switch_statement(lnum)
		if switch_lnum then
			return vim.fn.indent(switch_lnum) + sw + base_indent
		else
			return prev_indent
		end
	end

	-- Handle break statements in switch
	if line_clean:match("^break%s*;") then
		-- Check if we're in a case statement
		local search_lnum = prev_lnum
		while search_lnum > 0 and search_lnum > (lnum - 20) do
			local search_line = vim.trim(vim.fn.getline(search_lnum))
			if is_case_statement(search_line) then
				return vim.fn.indent(search_lnum) + sw + base_indent
			end
			search_lnum = search_lnum - 1
		end
		return prev_indent
	end

	-- Handle content after case/default
	if is_case_statement(prev_line_clean) then
		return prev_indent + sw + base_indent
	end

	-- Handle content after opening braces
	if prev_line_clean:match("{%s*$") then
		return prev_indent + sw + base_indent
	end

	-- Handle content after control structures without braces
	if is_control_structure(prev_line_clean) and not prev_line_clean:match("{%s*$") then
		return prev_indent + sw + base_indent
	end

	-- Handle function declarations
	if config.js_indent_functions and is_function_declaration(prev_line_clean) then
		if not prev_line_clean:match("{%s*$") then
			return prev_indent + sw + base_indent
		end
	end

	-- Handle object literals and arrays
	if prev_line_clean:match("[%[{]%s*$") then
		if config.js_indent_objects or config.js_indent_arrays then
			return prev_indent + sw + base_indent
		end
	end

	-- Handle continued expressions
	if
		prev_line_clean:match("[,+%-*/%%=&|<>!]%s*$")
		or prev_line_clean:match("&&%s*$")
		or prev_line_clean:match("||%s*$")
		or prev_line_clean:match("%?%s*$")
		or prev_line_clean:match(":%s*$")
	then
		return prev_indent + sw + base_indent
	end

	-- Handle method chaining
	if line_clean:match("^%.") then
		return prev_indent + sw + base_indent
	end

	-- Handle ternary operator
	if prev_line_clean:match("%?") and line_clean:match("^:") then
		return prev_indent
	end

	-- Handle else statements
	if line_clean:match("^else%s") then
		-- Find matching if statement
		local search_lnum = prev_lnum
		while search_lnum > 0 and search_lnum > (lnum - 20) do
			local search_line = vim.trim(vim.fn.getline(search_lnum))
			if search_line:match("^if%s*%(") then
				return vim.fn.indent(search_lnum) + base_indent
			end
			search_lnum = search_lnum - 1
		end
	end

	-- Default: maintain previous indentation
	return prev_indent
end

return M
