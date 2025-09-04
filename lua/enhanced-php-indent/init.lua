-- enhanced-php-indent.nvim
-- A comprehensive PHP indentation plugin for Neovim
-- Combines official php.vim robustness with modern enhancements

local M = {}

-- Plugin configuration with defaults
M.config = {
  -- Default indenting level (0 = no extra indentation)
  default_indenting = 0,

  -- Outdent single-line comments (0 = disabled)
  outdent_sl_comments = 0,

  -- Put braces at code level instead of indented
  braces_at_code_level = false,

  -- Auto-format comments
  autoformat_comment = true,

  -- Outdent PHP escape sequences
  outdent_php_escape = true,

  -- Disable arrow matching indentation
  no_arrow_matching = false,

  -- Use vintage case/default indentation
  vintage_case_default_indent = false,

  -- Indent function call parameters
  indent_function_call_parameters = false,

  -- Indent function declaration parameters
  indent_function_declaration_parameters = false,

  -- Remove CR characters when on Unix
  remove_cr_when_unix = false,

  -- Enable real-time auto-indentation
  enable_real_time_indent = true,
}

-- Setup function called by users
function M.setup(opts)
  -- Merge user options with defaults
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Set global variables for the indent script
  vim.g.PHP_default_indenting = M.config.default_indenting
  vim.g.PHP_outdentSLComments = M.config.outdent_sl_comments
  vim.g.PHP_BracesAtCodeLevel = M.config.braces_at_code_level and 1 or 0
  vim.g.PHP_autoformatcomment = M.config.autoformat_comment and 1 or 0
  vim.g.PHP_outdentphpescape = M.config.outdent_php_escape and 1 or 0
  vim.g.PHP_noArrowMatching = M.config.no_arrow_matching and 1 or 0
  vim.g.PHP_vintage_case_default_indent = M.config.vintage_case_default_indent and 1 or 0
  vim.g.PHP_IndentFunctionCallParameters = M.config.indent_function_call_parameters and 1 or 0
  vim.g.PHP_IndentFunctionDeclarationParameters = M.config.indent_function_declaration_parameters and 1 or 0
  vim.g.PHP_removeCRwhenUnix = M.config.remove_cr_when_unix and 1 or 0

  -- Load the main indent functionality
  require('enhanced-php-indent.indent').setup(M.config)
end

-- Allow plugin to work without explicit setup call
-- (Uses default configuration)
local function auto_setup()
  if vim.g.enhanced_php_indent_loaded then
    return
  end

  -- Check if user wants to disable auto-setup
  if vim.g.enhanced_php_indent_disable_auto_setup then
    return
  end

  -- Auto-setup with defaults
  M.setup({})
  vim.g.enhanced_php_indent_loaded = true
end

-- Auto-setup on PHP filetype
vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = auto_setup,
  group = vim.api.nvim_create_augroup("EnhancedPhpIndentAutoSetup", { clear = true }),
})

return M
