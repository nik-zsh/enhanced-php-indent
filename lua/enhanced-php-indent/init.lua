-- enhanced-php-indent.nvim
-- A working PHP indentation plugin for Neovim
local M = {}

-- Configuration with defaults
M.config = {
  default_indenting = 0,
  braces_at_code_level = false,
  autoformat_comment = true,
  outdent_php_escape = true,
  no_arrow_matching = false,
  vintage_case_default_indent = false,
  indent_function_call_parameters = false,
  indent_function_declaration_parameters = false,
  remove_cr_when_unix = false,
  enable_real_time_indent = true,
}

-- Global indent function (MUST be global for indentexpr)
function _G.EnhancedPhpIndent()
  local config = require('enhanced-php-indent').config
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
  local sw = vim.fn.shiftwidth()

  -- Handle blank lines inside array brackets (ENHANCED FEATURE)
  if vim.fn.match(line, '^\s*$') >= 0 and prev_lnum > 0 then
    if vim.fn.match(prev_line, '\[\s*$') >= 0 then
      -- Look ahead for closing bracket
      local next_lnum = lnum + 1
      while next_lnum <= vim.fn.line('$') do
        local next_line = vim.fn.getline(next_lnum)
        if vim.fn.match(next_line, '^\s*$') >= 0 then
          next_lnum = next_lnum + 1
        else
          if vim.fn.match(next_line, '^\s*\]') >= 0 then
            return prev_indent + 2 * sw  -- Double indent for empty arrays
          end
          break
        end
      end
    end
  end

  -- Align closing bracket with opening bracket
  if vim.fn.match(line, '^\s*\]\s*$') >= 0 and prev_lnum > 0 then
    if vim.fn.match(prev_line, '\[\s*$') >= 0 then
      return prev_indent
    end
  end

  -- Dedent closing braces/brackets/parens
  if vim.fn.match(line, '^\s*[\]})]') >= 0 then
    return math.max(prev_indent - sw, 0)
  end

  -- Switch statement handling
  if prev_lnum > 0 and vim.fn.match(prev_line, '^\s*switch\s*(.*{\s*$') >= 0 then
    return prev_indent + sw
  end

  -- Case/default labels
  if vim.fn.match(line, '^\s*case\s\+.\+:') >= 0 or vim.fn.match(line, '^\s*default\s*:') >= 0 then
    -- Find switch opening brace
    local switch_lnum = vim.fn.search('{', 'bnW')
    if switch_lnum > 0 then
      local base_indent = vim.fn.indent(switch_lnum)
      if not config.vintage_case_default_indent then
        return base_indent + sw
      else
        return base_indent
      end
    end
  end

  -- Indent after case/default
  if prev_lnum > 0 then
    if vim.fn.match(prev_line, '^\s*case\s\+.\+:') >= 0 or vim.fn.match(prev_line, '^\s*default\s*:') >= 0 then
      return prev_indent + sw
    end
  end

  -- Function parameters
  if config.indent_function_call_parameters or config.indent_function_declaration_parameters then
    if vim.fn.match(prev_line, '(') >= 0 and vim.fn.match(prev_line, ')') < 0 then
      return prev_indent + sw
    end
  end

  -- Indent after opening braces/brackets/parens
  if vim.fn.match(prev_line, '{\s*$') >= 0 or vim.fn.match(prev_line, '\[\s*$') >= 0 or vim.fn.match(prev_line, '(\s*$') >= 0 then
    return prev_indent + sw
  end

  -- Control structures
  if vim.fn.match(prev_line, '^\s*\(if\|while\|for\|foreach\|function\|class\|interface\)\s*(') >= 0 then
    return prev_indent + sw
  end

  -- PHP tags
  if config.outdent_php_escape then
    if vim.fn.match(line, '^\s*?>') >= 0 or vim.fn.match(line, '^\s*<?php') >= 0 or vim.fn.match(line, '^\s*<?') >= 0 then
      return 0
    end
  end

  -- Arrow method chaining
  if not config.no_arrow_matching then
    if vim.fn.match(prev_line, '->') >= 0 then
      if vim.fn.match(line, '^\s*->') >= 0 then
        return prev_indent
      end
    end
  end

  -- Default: keep previous indentation
  return prev_indent
end

-- Setup function
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  -- Set global variables for compatibility
  vim.g.PHP_default_indenting = M.config.default_indenting
  vim.g.PHP_BracesAtCodeLevel = M.config.braces_at_code_level and 1 or 0
  vim.g.PHP_autoformatcomment = M.config.autoformat_comment and 1 or 0
  vim.g.PHP_outdentphpescape = M.config.outdent_php_escape and 1 or 0
  vim.g.PHP_noArrowMatching = M.config.no_arrow_matching and 1 or 0
  vim.g.PHP_vintage_case_default_indent = M.config.vintage_case_default_indent and 1 or 0
  vim.g.PHP_IndentFunctionCallParameters = M.config.indent_function_call_parameters and 1 or 0
  vim.g.PHP_IndentFunctionDeclarationParameters = M.config.indent_function_declaration_parameters and 1 or 0

  -- Setup indent for PHP files
  require('enhanced-php-indent.indent').setup()
end

return M
