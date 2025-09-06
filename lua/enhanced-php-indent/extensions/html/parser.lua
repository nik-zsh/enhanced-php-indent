-- FILE: lua/enhanced-php-indent/extensions/html/parser.lua
-- HTML Parser for enhanced-php-indent.nvim
local M = {}

-- Parse HTML tag from line
function M.parse_html_tag(line_clean)
  -- Opening tag: <div>, <body class="test">
  local opening_tag = line_clean:match('^<([%w%-]+)')
  if opening_tag then
    return opening_tag:lower(), 'opening'
  end

  -- Closing tag: </div>, </body>
  local closing_tag = line_clean:match('^</([%w%-]+)')
  if closing_tag then
    return closing_tag:lower(), 'closing'
  end

  -- Self-closing: <br/>, <img src="..."/>
  local self_closing = line_clean:match('^<([%w%-]+).*/%s*>')
  if self_closing then
    return self_closing:lower(), 'self_closing'
  end

  return nil, nil
end

-- Find matching HTML opening tag
function M.find_html_opening_tag(lnum, closing_tag)
  local search_lnum = lnum - 1
  local tag_count = 1
  local max_search = 100

  while search_lnum > 0 and tag_count > 0 and (lnum - search_lnum) < max_search do
    local line = vim.fn.getline(search_lnum)
    local line_clean = vim.trim(line)

    -- Skip PHP blocks when looking for HTML tags
    local utils = require('enhanced-php-indent.extensions.html.utils')
    if utils.get_context_type(search_lnum) == 'php' then
      search_lnum = search_lnum - 1
      goto continue
    end

    local tag_name, tag_type = M.parse_html_tag(line_clean)

    if tag_name and tag_name == closing_tag then
      if tag_type == 'closing' then
        tag_count = tag_count + 1
      elseif tag_type == 'opening' then
        tag_count = tag_count - 1
        if tag_count == 0 then
          return search_lnum
        end
      end
    end

    ::continue::
    search_lnum = search_lnum - 1
  end

  return nil
end

return M