-- FILE: lua/enhanced-php-indent/extensions/custom/loader.lua
-- Custom Indent File Loader
local M = {}

-- Safely load custom indent file
function M.load_custom_indent_file(file_path, indent_type, debug)
  if not file_path or file_path == '' then
    return nil
  end

  -- Expand path
  local expanded_path = vim.fn.expand(file_path)

  -- Check if file exists
  if vim.fn.filereadable(expanded_path) == 0 then
    if debug then
      print("Custom " .. indent_type .. " indent file not found: " .. expanded_path)
    end
    return nil
  end

  -- Load the file
  local success, result = pcall(dofile, expanded_path)
  if not success then
    vim.notify("Error loading custom " .. indent_type .. " indent file: " .. result, vim.log.levels.ERROR)
    return nil
  end

  -- Validate the loaded module
  if type(result) == 'table' and type(result.get_indent) == 'function' then
    if debug then
      print("Custom " .. indent_type .. " indent file loaded successfully: " .. expanded_path)
    end
    return result
  else
    vim.notify("Invalid custom " .. indent_type .. " indent file format. Must return table with get_indent function.", vim.log.levels.ERROR)
    return nil
  end
end

return M