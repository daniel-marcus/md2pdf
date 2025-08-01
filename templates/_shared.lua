local tag_base_url

function Meta(meta)
    local stringify = pandoc.utils.stringify

    if meta.website then
        meta.website_name = stringify(meta.website):gsub("^https?://", "")
    end

    if meta.email then
        local email = stringify(meta.email)
        meta.email = pandoc.RawInline("latex", string.format("\\href{mailto:%s}{%s}", email, email))
    end

    if meta.tag_base_url then
        tag_base_url = stringify(meta.tag_base_url)
    end

    return meta
end

function Link(el)
    return pandoc.RawInline("latex",
        string.format("\\customhref{%s}{%s}", el.target, pandoc.utils.stringify(el.content)))
end

function Str(el)
    local lead, tag, trail = el.text:match("^(%p*)#([%w_.+-]+)(%p*)$")
    if tag and tag_base_url then
        local tag_disp = tag:gsub("_", " ")
        local url = tag_base_url .. tag_disp
        return {pandoc.Str(lead or ""), pandoc.RawInline("latex", string.format("\\href{%s}{%s}", url, tag_disp)),
                pandoc.Str(trail or "")}
    end
    return el
end

function Code(el)
    local text = el.text
    local tag = text:match("^#(.+)$") or text
    local bubble = string.format("\\bubbletag{%s}", tag)
    if tag_base_url and text:sub(1, 1) == "#" then
        return pandoc.RawInline("latex", string.format("\\href{%s}{%s}", tag_base_url .. tag, bubble))
    end
    return pandoc.RawInline("latex", bubble)
end

-- Ensure Meta runs before others
return {{
    Meta = Meta
}, {
    Link = Link,
    Str = Str,
    Code = Code
}}
