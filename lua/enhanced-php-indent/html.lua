-- Comprehensive working HTML indenter with extensive debugging
local M = {}

-- Block-level tags that should cause indentation
local BLOCK_TAGS = {
  html = true, head = true, body = true, div = true, section = true, article = true,
  header = true, footer = true, nav = true, main = true, aside = true, form = true,
  fieldset = true, ul = true, ol = true, li = true, table = true, thead = true,
  tbody = true, tfoot = true, tr = true, th = true, td = true, blockquote = true,
  figure = true, details = true, summary = true
}

-- Debug function
local function debug_log(config, message)
  if config.html_debug then
    print("HTML DEBUG: " .. message)
  end
end

-- Extract tag name and type from line
local function analyze_line(line_clean)
  if not line_clean or line_clean == "" then
    return nil, "empty"
  end

  -- Skip PHP code
  if line_clean:find('<%?') or line_clean:find('%?>') then
    return nil, "php"
  end

  -- DOCTYPE
  if line_clean:find('^%s*<!DOCTYPE') then
    return "!doctype", "doctype"
  end

  -- HTML comments
  if line_clean:find('^%s*<!--') or line_clean:find('^%s*%-->') then
    return nil, "comment"
  end

  -- Closing tag: </div>
  local closing_tag = line_clean:match('^%s*</%s*([%w%-]+)')
  if closing_tag then
    return closing_tag:lower(), "closing"
  end

  -- Self-closing tag: <br /> or <img src="" />
  local self_closing_tag = line_clean:match('^%s*<%s*([%w%-]+)[^>]*/%s*>')
  if self_closing_tag then
    return self_closing_tag:lower(), "self_closing"
  end

  -- Opening tag: <div> or <div class="test">
  local opening_tag = line_clean:match('^%s*<%s*([%w%-]+)')
  if opening_tag then
    return opening_tag:lower(), "opening"
  end

  -- Text content
  return nil, "text"
end

-- Find the opening tag that matches a closing tag
local function find_matching_opening(lnum, target_tag, config)
  debug_log(config, "Looking for opening <" .. target_tag .. "> to match closing at line " .. lnum)

  local depth = 1
  local search_line = lnum - 1

  while search_line > 0 and depth > 0 and (lnum - search_line) < 100 do
    local line = vim.fn.getline(search_line)
    if line then
      local line_clean = vim.trim(line)
      local tag_name, tag_type = analyze_line(line_clean)

      if tag_name == target_tag then
        if tag_type == "closing" then
          depth = depth + 1
          debug_log(config, "  Line " .. search_line .. ": found closing </" .. tag_name .. ">, depth=" .. depth)
        elseif tag_type == "opening" then
          depth = depth - 1
          debug_log(config, "  Line " .. search_line .. ": found opening <" .. tag_name .. ">, depth=" .. depth)
          if depth == 0 then
            debug_log(config, "  Found matching opening <" .. tag_name .. "> at line " .. search_line)
            return search_line
          end
        end
      end
    end
    search_line = search_line - 1
  end

  debug_log(config, "  No matching opening tag found for </" .. target_tag .. ">")
  return nil
end

-- Main HTML indentation function
function M.get_indent(lnum, config)
  local line = vim.fn.getline(lnum)
  if not line then 
    debug_log(config, "Line " .. lnum .. " is nil, returning nil")
    return nil 
  end

  local line_clean = vim.trim(line)
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_line = prev_lnum > 0 and vim.fn.getline(prev_lnum) or ""
  local prev_line_clean = vim.trim(prev_line)
  local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
  local sw = vim.fn.shiftwidth()

  debug_log(config, "=== PROCESSING LINE " .. lnum .. " ===")
  debug_log(config, "Current line: '" .. line_clean .. "'")
  debug_log(config, "Previous line " .. prev_lnum .. ": '" .. prev_line_clean .. "' (indent=" .. prev_indent .. ")")
  debug_log(config, "Shiftwidth: " .. sw)

  -- Analyze current line
  local current_tag, current_type = analyze_line(line_clean)
  debug_log(config, "Current line analysis: tag='" .. tostring(current_tag) .. "' type='" .. current_type .. "'")

  -- Handle empty lines
  if current_type == "empty" then
    debug_log(config, "Empty line, maintaining previous indent: " .. prev_indent)
    return prev_indent
  end

  -- Don't process PHP code
  if current_type == "php" then
    debug_log(config, "PHP code detected, returning nil for PHP indenter")
    return nil
  end

  -- Handle comments
  if current_type == "comment" then
    debug_log(config, "HTML comment, maintaining previous indent: " .. prev_indent)
    return prev_indent
  end

  -- Handle DOCTYPE
  if current_type == "doctype" then
    debug_log(config, "DOCTYPE declaration, using base indent: 0")
    return 0
  end

  -- Handle closing tags
  if current_type == "closing" and current_tag then
    if BLOCK_TAGS[current_tag] then
      debug_log(config, "Processing closing block tag: " .. current_tag)
      local opening_line = find_matching_opening(lnum, current_tag, config)
      if opening_line then
        local result = vim.fn.indent(opening_line)
        debug_log(config, "Closing </" .. current_tag .. "> aligns with opening at line " .. opening_line .. " = " .. result)
        return result
      else
        local result = math.max(prev_indent - sw, 0)
        debug_log(config, "No matching opening found, dedenting: " .. prev_indent .. " - " .. sw .. " = " .. result)
        return result
      end
    else
      debug_log(config, "Closing inline tag " .. current_tag .. ", maintaining indent: " .. prev_indent)
      return prev_indent
    end
  end

  -- Handle self-closing tags
  if current_type == "self_closing" and current_tag then
    debug_log(config, "Self-closing tag " .. current_tag .. ", maintaining indent: " .. prev_indent)
    return prev_indent
  end

  -- Handle opening tags
  if current_type == "opening" and current_tag then
    debug_log(config, "Opening tag " .. current_tag .. ", maintaining indent: " .. prev_indent)
    return prev_indent
  end

  -- Handle text content - check if previous line was opening block tag
  if current_type == "text" then
    debug_log(config, "Text content, checking previous line for indentation")

    if prev_line_clean ~= "" then
      local prev_tag, prev_type = analyze_line(prev_line_clean)
      debug_log(config, "Previous line analysis: tag='" .. tostring(prev_tag) .. "' type='" .. prev_type .. "'")

      if prev_type == "opening" and prev_tag and BLOCK_TAGS[prev_tag] then
        local result = prev_indent + sw
        debug_log(config, "Content after opening block tag " .. prev_tag .. ": " .. prev_indent .. " + " .. sw .. " = " .. result)
        return result
      end
    end

    debug_log(config, "Text content with no special indentation, maintaining: " .. prev_indent)
    return prev_indent
  end

  -- Check if we should indent because previous line was opening block tag
  if prev_line_clean ~= "" then
    local prev_tag, prev_type = analyze_line(prev_line_clean)
    debug_log(config, "Checking if should indent after previous line: tag='" .. tostring(prev_tag) .. "' type='" .. prev_type .. "'")

    if prev_type == "opening" and prev_tag and BLOCK_TAGS[prev_tag] then
      local result = prev_indent + sw
      debug_log(config, "Should indent after opening block tag " .. prev_tag .. ": " .. prev_indent .. " + " .. sw .. " = " .. result)
      return result
    end
  end

  -- Default case
  debug_log(config, "Default case, maintaining previous indent: " .. prev_indent)
  return prev_indent
end

return M
