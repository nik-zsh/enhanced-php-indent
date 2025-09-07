-- HTML indentation for enhanced-php-indent.nvim
local M = {}

-- Check if tag is a block-level tag that should indent
local function is_block_tag(tag_name, config)
    if not tag_name then
        return false
    end

    for _, block_tag in ipairs(config.html_indent_tags) do
        if tag_name:lower() == block_tag:lower() then
            return true
        end
    end
    return false
end

-- Check if tag is self-closing
local function is_self_closing_tag(tag_name, config)
    if not tag_name then
        return false
    end

    for _, self_closing in ipairs(config.html_self_closing_tags) do
        if tag_name:lower() == self_closing:lower() then
            return true
        end
    end
    return false
end

-- Check if tag is inline
local function is_inline_tag(tag_name, config)
    if not tag_name then
        return false
    end

    for _, inline_tag in ipairs(config.html_inline_tags) do
        if tag_name:lower() == inline_tag:lower() then
            return true
        end
    end
    return false
end

-- Parse HTML tag from line
local function parse_tag(line_clean)
    if not line_clean or line_clean == "" then
        return nil, nil
    end

    -- Closing tag: </div>
    local closing_tag = line_clean:match("^%s*</%s*([%w%-]+)")
    if closing_tag then
        return closing_tag, "closing"
    end

    -- Self-closing tag: <br/> or <img ... />
    local self_closing = line_clean:match("^%s*<%s*([%w%-]+)[^>]*/%s*>")
    if self_closing then
        return self_closing, "self_closing"
    end

    -- Opening tag: <div> or <div class="...">
    local opening_tag = line_clean:match("^%s*<%s*([%w%-]+)")
    if opening_tag then
        return opening_tag, "opening"
    end

    return nil, nil
end

-- Find matching opening tag for closing tag
local function find_opening_tag(lnum, closing_tag_name, config)
    local search_lnum = lnum - 1
    local tag_count = 1
    local max_search = 50

    while search_lnum > 0 and tag_count > 0 and (lnum - search_lnum) < max_search do
        local line = vim.fn.getline(search_lnum)
        if not line then
            break
        end

        local line_clean = vim.trim(line)

        -- Skip empty lines and PHP code
        if line_clean ~= "" and not line_clean:find("^%s*<%?") and not line_clean:find("^%s*%?>") then
            local tag_name, tag_type = parse_tag(line_clean)

            if tag_name and tag_name:lower() == closing_tag_name:lower() then
                if tag_type == "closing" then
                    tag_count = tag_count + 1
                elseif tag_type == "opening" then
                    tag_count = tag_count - 1
                    if tag_count == 0 then
                        return search_lnum
                    end
                end
            end
        end

        search_lnum = search_lnum - 1
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
    local prev_indent = prev_lnum > 0 and vim.fn.indent(prev_lnum) or 0
    local sw = vim.fn.shiftwidth()
    local base_indent = config.default_indenting or 0

    if config.html_debug then
        print("    HTML: processing '" .. line_clean .. "'")
    end

    -- Handle empty lines
    if line_clean == "" then
        return prev_indent
    end

    -- Handle PHP code in HTML context (preserve PHP indentation)
    if line_clean:find("^%s*<%?") or line_clean:find("^%s*%?>") then
        return prev_indent
    end

    -- Handle HTML comments
    if line_clean:find("^%s*<!--") or line_clean:find("^%s*%-->") then
        return prev_indent
    end

    local tag_name, tag_type = parse_tag(line_clean)

    -- Handle closing tags
    if tag_name and tag_type == "closing" then
        if is_block_tag(tag_name, config) then
            local opening_lnum = find_opening_tag(lnum, tag_name, config)
            if opening_lnum then
                if config.html_debug then
                    print("    HTML: closing tag " .. tag_name .. " matches opening at line " .. opening_lnum)
                end
                return vim.fn.indent(opening_lnum) + base_indent
            else
                -- Fallback: dedent from previous line
                return math.max(prev_indent - sw, base_indent)
            end
        else
            -- Inline closing tags don't change indentation
            return prev_indent
        end
    end

    -- Handle self-closing tags
    if tag_name and tag_type == "self_closing" then
        if config.html_debug then
            print("    HTML: self-closing tag " .. tag_name)
        end
        return prev_indent
    end

    -- Handle content after opening tags
    if prev_lnum > 0 then
        local prev_line = vim.fn.getline(prev_lnum)
        if prev_line then
            local prev_line_clean = vim.trim(prev_line)
            local prev_tag_name, prev_tag_type = parse_tag(prev_line_clean)

            if prev_tag_name and prev_tag_type == "opening" then
                if is_block_tag(prev_tag_name, config) and not is_inline_tag(prev_tag_name, config) then
                    if config.html_debug then
                        print("    HTML: content after opening block tag " .. prev_tag_name)
                    end
                    return vim.fn.indent(prev_lnum) + sw + base_indent
                end
            end
        end
    end

    -- Handle opening tags
    if tag_name and tag_type == "opening" then
        if config.html_debug then
            print("    HTML: opening tag " .. tag_name)
        end
        return prev_indent
    end

    -- Handle DOCTYPE and other declarations
    if line_clean:find("^%s*<!DOCTYPE") or line_clean:find("^%s*<!%[CDATA%[") then
        return base_indent
    end

    -- Default: maintain previous indentation
    return prev_indent
end

return M
