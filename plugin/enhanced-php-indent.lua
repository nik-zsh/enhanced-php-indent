-- Enhanced PHP Indent File for Neovim
-- Combines the robustness of the official php.vim with custom improvements
-- Author: AI Assistant (based on official PHP indent script by John Wellesz)
-- Version: 2.0
-- Last Change: 2025-09-02

-- Check if already loaded
if vim.b.did_indent then
    return
end
vim.b.did_indent = 1

-- Configuration variables with defaults
local config = {
    -- Default indenting level (0 = no extra indentation)
    PHP_default_indenting = vim.g.PHP_default_indenting or 0,

    -- Outdent single-line comments (0 = disabled)
    PHP_outdentSLComments = vim.g.PHP_outdentSLComments or 0,

    -- Put braces at code level instead of indented
    PHP_BracesAtCodeLevel = vim.g.PHP_BracesAtCodeLevel or 0,

    -- Auto-format comments
    PHP_autoformatcomment = vim.g.PHP_autoformatcomment or 1,

    -- Outdent PHP escape sequences
    PHP_outdentphpescape = vim.g.PHP_outdentphpescape or 1,

    -- Disable arrow matching indentation
    PHP_noArrowMatching = vim.g.PHP_noArrowMatching or 0,

    -- Use vintage case/default indentation
    PHP_vintage_case_default_indent = vim.g.PHP_vintage_case_default_indent or 0,

    -- Indent function call parameters
    PHP_IndentFunctionCallParameters = vim.g.PHP_IndentFunctionCallParameters or 0,

    -- Indent function declaration parameters
    PHP_IndentFunctionDeclarationParameters = vim.g.PHP_IndentFunctionDeclarationParameters or 0,

    -- Remove CR characters when on Unix
    PHP_removeCRwhenUnix = vim.g.PHP_removeCRwhenUnix or 0
}

-- Initialize buffer variables
local function init_buffer_vars()
    vim.b.PHP_lastindented = 0
    vim.b.PHP_indentbeforelast = 0
    vim.b.PHP_indentinghuge = 0
    vim.b.PHP_CurrentIndentLevel = config.PHP_default_indenting
    vim.b.PHP_LastIndentedWasComment = 0
    vim.b.PHP_InsideMultilineComment = 0
    vim.b.InPHPcode = 0
    vim.b.InPHPcode_checked = 0
    vim.b.InPHPcode_and_script = 0
    vim.b.InPHPcode_tofind = ""
    vim.b.PHP_oldchangetick = vim.b.changedtick or 0
    vim.b.UserIsTypingComment = 0
    vim.b.optionsset = 0
end

-- PHP syntax patterns
local patterns = {
    endline = [[\s*\%(//.*\|#\[\@!.*\|/\*.*\*/\s*\)\=$]],
    PHP_validVariable = [[[a-zA-Z_-ÿ][a-zA-Z0-9_-ÿ]*]],
    notPhpHereDoc = [[\<\%(break\|return\|continue\|exit\|die\|true\|false\|elseif\|else\|end\%(if\|while\|for\|foreach\|match\|switch\)\)\>]],
    blockstart = [[\%(\%(\%(}\s*\)\=else\%(\s\+\)\=\)\=if\>\|\%(}\s*\)\?else\>\|do\>\|while\>\|match\>\|switch\>\|case\>\|default\>\|for\%(each\)\=\>\|declare\>\|class\>\|trait\>\|\%()\s*\)\=use\>\|interface\>\|abstract\>\|final\>\|try\>\|\%(}\s*\)\=catch\>\|\%(}\s*\)\=finally\>\)]],
    functionDecl = [[\<function\>\%(\s\+&\=]] .. [[[a-zA-Z_-ÿ][a-zA-Z0-9_-ÿ]*]] .. [[\)\=\s*(.*)],
    terminated = [[\%(\%(;\%(\s*\%(?>\|}\)\)\=\|<<<\s*[''"]\=\w*[''"]\=$\|^\s*}\|^\s*]] .. [[[a-zA-Z_-ÿ][a-zA-Z0-9_-ÿ]*]] .. [[::\)]] .. [[\s*\%(//.*\|#\[\@!.*\|/\*.*\*/\s*\)\=$]] .. [[\)]],
    structureHead = [[^\s*\%(]] .. [[\%(\%(\%(}\s*\)\=else\%(\s\+\)\=\)\=if\>\|\%(}\s*\)\?else\>\|do\>\|while\>\|match\>\|switch\>\|case\>\|default\>\|for\%(each\)\=\>\|declare\>\|class\>\|trait\>\|\%()\s*\)\=use\>\|interface\>\|abstract\>\|final\>\|try\>\|\%(}\s*\)\=catch\>\|\%(}\s*\)\=finally\>\)]] .. [[\)\|]] .. [[\<function\>\%(\s\+&\=]] .. [[[a-zA-Z_-ÿ][a-zA-Z0-9_-ÿ]*]] .. [[\)\=\s*(.*)]] .. [[\s*\%(//.*\|#\[\@!.*\|/\*.*\*/\s*\)\=$]] .. [[\|\<new\s\+class\>\|match\s*(\s*\$\?]] .. [[[a-zA-Z_-ÿ][a-zA-Z0-9_-ÿ]*]] .. [[\s*)\s*{]] .. [[\s*\%(//.*\|#\[\@!.*\|/\*.*\*/\s*\)\=$]]
}

-- Enhanced PHP indent function
local function get_php_indent()
    local lnum = vim.v.lnum
    local line = vim.fn.getline(lnum)
    local trimmed = line:gsub("^%s+", "")

    -- Get shift width
    local sw = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or 4

    -- Get previous non-blank line
    local prev_lnum = vim.fn.prevnonblank(lnum - 1)
    local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
    local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0

    -- Handle blank line inside empty array brackets (from custom php-indent.lua)
    if trimmed == "" and prev_lnum > 0 and prev_line:match("%[%s*$") then
        -- Check if next non-blank line has closing bracket
        local next_lnum = lnum + 1
        local next_line = vim.fn.getline(next_lnum)
        while next_line:match("^%s*$") and next_lnum < vim.fn.line("$") do
            next_lnum = next_lnum + 1
            next_line = vim.fn.getline(next_lnum)
        end
        if next_line:match("^%s*%]") then
            return prev_indent + 2 * sw
        end
    end

    -- Align closing bracket ']' with opening bracket '[' (from custom)
    if trimmed:match("^%]%s*$") and prev_lnum > 0 and prev_line:match("%[%s*$") then
        return prev_indent
    end

    -- Dedent closing braces/brackets/parens (enhanced from custom)
    if trimmed:match("^[%]%)}]") then
        return math.max(vim.fn.indent(lnum - 1) - sw, 0)
    end

    -- Switch statement handling (from custom, enhanced)
    if prev_lnum > 0 and prev_line:match("^%s*switch%s*%(.*%)%s*{%s*$") and lnum == prev_lnum + 1 then
        return prev_indent + sw
    end

    -- Case/default labels (from custom, enhanced)
    if trimmed:match("^case%s+.+:") or trimmed:match("^default%s*:") then
        -- Find the matching switch brace
        local switch_lnum = vim.fn.search("{", "bnW")
        local base_indent = switch_lnum > 0 and vim.fn.indent(switch_lnum) or 0
        if not config.PHP_vintage_case_default_indent then
            return base_indent + sw
        else
            return base_indent
        end
    end

    -- Indent statements inside case (from custom)
    if prev_line:match("^%s*case%s+.+:") or prev_line:match("^%s*default%s*:") then
        return prev_indent + sw
    end

    -- Function parameter indentation
    if config.PHP_IndentFunctionCallParameters > 0 or config.PHP_IndentFunctionDeclarationParameters > 0 then
        if prev_line:match("%(") and not prev_line:match("%)") then
            return prev_indent + sw
        end
    end

    -- Indent after opening braces/brackets/parens (enhanced from custom)
    if prev_line:match("{%s*$") or prev_line:match("%[%s*$") or prev_line:match("%(%s*$") then
        return prev_indent + sw
    end

    -- Handle control structures
    if prev_line:match(patterns.structureHead) then
        return prev_indent + sw
    end

    -- Handle terminated statements
    if prev_line:match(patterns.terminated) then
        return prev_indent
    end

    -- Arrow method chaining (unless disabled)
    if not config.PHP_noArrowMatching and prev_line:match("->") and not prev_line:match(patterns.structureHead) then
        if trimmed:match("^->") then
            return prev_indent
        else
            return prev_indent + sw
        end
    end

    -- Handle PHP tags
    if config.PHP_outdentphpescape > 0 then
        if trimmed:match("^%?>") then
            return 0
        end
        if trimmed:match("^<%?php") or trimmed:match("^<%?") then
            return 0
        end
    end

    -- Default: keep previous indentation
    return prev_indent
end

-- Set up indentation
local function setup_php_indent()
    -- Initialize buffer variables
    init_buffer_vars()

    -- Remove CR characters if on Unix (from official script)
    if vim.bo.fileformat == "unix" and config.PHP_removeCRwhenUnix > 0 then
        vim.cmd("silent! %s/\r$//g")
    end

    -- Set indent options
    vim.bo.smartindent = false
    vim.bo.autoindent = false
    vim.bo.cindent = false
    vim.bo.lisp = false
    vim.bo.indentexpr = "v:lua.require'enhanced_php_indent'.get_php_indent()"
    vim.bo.indentkeys = "0{,0},0),0],:,!^F,o,O,e,*,=?>,=,=*/"

    -- Set up comment formatting if enabled
    if config.PHP_autoformatcomment > 0 then
        vim.bo.formatoptions = vim.bo.formatoptions .. "qrowcb"
    end
end

-- Auto-indenting for real-time fixes (from custom php-indent.lua)
local function setup_auto_indent()
    local group = vim.api.nvim_create_augroup("PHPEnhancedIndent", { clear = true })

    vim.api.nvim_create_autocmd({ "InsertLeave", "TextChangedI" }, {
        group = group,
        pattern = "*.php",
        callback = function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local line = vim.api.nvim_get_current_line()
            local prev_line = vim.fn.getline(row - 1)

            -- Auto-indent closing brackets for empty arrays
            if line:match("^%s*$") and prev_line:match("%[%s*$") then
                local next_line = vim.fn.getline(row + 1)
                if next_line:match("^%s*%]") then
                    vim.api.nvim_command((row + 1) .. "normal! ==")
                end
            end
        end,
    })
end

-- Public API
local M = {
    get_php_indent = get_php_indent,
    setup = setup_php_indent,
    config = config
}

-- Set up the indentation
setup_php_indent()
setup_auto_indent()

return M
