-- enhanced-php-indent.nvim - COMPREHENSIVE VERSION
-- Based on official php.vim with enhancements
local M = {}

-- Full configuration options (from official php.vim)
M.config = {
 -- Basic indentation
 default_indenting = 0, -- Extra base indentation
 braces_at_code_level = false, -- Braces at same level as code

 -- Function parameters
 indent_function_call_parameters = false, -- Indent function call parameters 
 indent_function_declaration_parameters = false, -- Indent function declaration parameters

 -- Comment and formatting
 autoformat_comment = true, -- Auto-format comments
 outdent_sl_comments = 0, -- Outdent single-line comments

 -- PHP-specific
 outdent_php_escape = true, -- Outdent php and ? tags
 remove_cr_when_unix = false, -- Remove CR characters on Unix

 -- Advanced
 no_arrow_matching = false, -- Disable -> method chaining indent
 vintage_case_default_indent = false, -- Old-style case/default indent

 -- Enhanced features
 enable_real_time_indent = true, -- Real-time indentation fixes
 smart_array_indent = true, -- Enhanced array handling
}

-- Helper: Find matching opening bracket/brace/paren
local function find_matching_open(lnum, close_char)
 local open_char = ({[']'] = '[', ['}'] = '{', [')'] = '('})[close_char]
 if not open_char then return nil end

 local search_lnum = lnum - 1
 local bracket_count = 1

 while search_lnum > 0 and bracket_count > 0 do
 local line = vim.fn.getline(search_lnum)

 -- Count brackets in this line
 for char in line:gmatch('.') do
 if char == close_char then
 bracket_count = bracket_count + 1
 elseif char == open_char then
 bracket_count = bracket_count - 1
 if bracket_count == 0 then
 return search_lnum
 end
 end
 end

 search_lnum = search_lnum - 1
 end

 return nil
end

-- Helper: Check if inside function parameters
local function inside_function_params(lnum)
 local search_lnum = lnum - 1
 local paren_count = 0

 while search_lnum > 0 and search_lnum > (lnum - 20) do
 local line = vim.fn.getline(search_lnum)
 local line_clean = vim.trim(line)

 -- Count parentheses
 for char in line:gmatch('.') do
 if char == ')' then paren_count = paren_count + 1
 elseif char == '(' then paren_count = paren_count - 1 end
 end

 -- Found function declaration
 if paren_count == -1 and line_clean:find('function%s+') then
 return true, vim.fn.indent(search_lnum)
 end

 search_lnum = search_lnum - 1
 end

 return false, nil
end

-- Helper: Simple switch detection
local function find_switch_indent(lnum)
 local search_lnum = lnum - 1

 while search_lnum > 0 and search_lnum > (lnum - 15) do
 local line = vim.fn.getline(search_lnum)
 local line_clean = vim.trim(line)

 if line_clean:find("switch%s*%(") then
 return vim.fn.indent(search_lnum)
 end

 search_lnum = search_lnum - 1
 end

 return nil
end

-- ORIGINAL PHP indent function (no HTML/CSS/JS)
function _G.EnhancedPhpIndent()
 local lnum = vim.v.lnum
 local line = vim.fn.getline(lnum)
 local prev_lnum = vim.fn.prevnonblank(lnum - 1)
 local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
 local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
 local sw = vim.fn.shiftwidth()

 local line_clean = vim.trim(line)
 local prev_clean = vim.trim(prev_line)

 -- Apply default extra indenting
 local base_indent = M.config.default_indenting

 -- PHP tags outdenting
 if M.config.outdent_php_escape then
 if line_clean:find("^<%?") or line_clean:find("^%?>") then
 return 0
 end
 end

 -- Closing brackets alignment
 if line_clean:find("^%]") or line_clean:find("^%}") or line_clean:find("^%)") then
 local close_char = line_clean:sub(1,1)
 local open_lnum = find_matching_open(lnum, close_char)

 if open_lnum then
 return vim.fn.indent(open_lnum) + base_indent
 else
 return math.max(prev_indent - sw, base_indent)
 end
 end

 -- Smart array handling
 if M.config.smart_array_indent then
 if line_clean == "" and prev_clean:find("%[%s*$") then
 local next_lnum = lnum + 1
 local next_line = vim.fn.getline(next_lnum)
 local next_clean = vim.trim(next_line)

 if next_clean:find("^%]") then
 return prev_indent + sw + base_indent
 end
 end
 end

 -- Switch/case handling
 if line_clean:find("^case%s.+:") or line_clean:find("^default%s*:") then
 local switch_indent = find_switch_indent(lnum)
 if switch_indent then
 if M.config.vintage_case_default_indent then
 return switch_indent + base_indent
 else
 return switch_indent + sw + base_indent
 end
 else
 return prev_indent + sw + base_indent
 end
 end

 -- Content after case/default 
 if prev_clean:find("^case%s.+:") or prev_clean:find("^default%s*:") then
 return prev_indent + sw
 end

 -- Break statements
 if line_clean:find("^break%s*;") then
 return prev_indent
 end

 -- Function parameter indentation
 if M.config.indent_function_call_parameters or M.config.indent_function_declaration_parameters then
 local in_params, func_indent = inside_function_params(lnum)
 if in_params and func_indent then
 return func_indent + sw + base_indent
 end
 end

 -- Opening braces/brackets/parens
 if prev_clean:find("{%s*$") or prev_clean:find("%[%s*$") or prev_clean:find("%(%s*$") then
 if M.config.braces_at_code_level and prev_clean:find("{%s*$") then
 return prev_indent + base_indent
 else
 return prev_indent + sw + base_indent
 end
 end

 -- Control structures
 if prev_clean:find("^if%s*%(") or prev_clean:find("^while%s*%(") or 
 prev_clean:find("^for%s*%(") or prev_clean:find("^foreach%s*%(") or
 prev_clean:find("^function%s") or prev_clean:find("^class%s") or
 prev_clean:find("^interface%s") or prev_clean:find("^trait%s") then
 return prev_indent + sw + base_indent
 end

 -- Method chaining
 if not M.config.no_arrow_matching then
 if prev_clean:find("->") and line_clean:find("^%->") then
 return prev_indent
 end
 end

 -- Try/catch blocks
 if prev_clean:find("^try%s*{") or prev_clean:find("^catch%s*%(") or prev_clean:find("^finally%s*{") then
 return prev_indent + sw + base_indent
 end

 -- Default: maintain previous indentation
 return prev_indent
end

function M.setup(opts)
 opts = opts or {}
 M.config = vim.tbl_deep_extend("force", M.config, opts)
 require('enhanced-php-indent.indent').setup()
end

return M
