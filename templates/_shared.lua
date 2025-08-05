local tag_base_url

function Meta(meta)
    local stringify = pandoc.utils.stringify

    if meta.website then
        meta.website_name = stringify(meta.website):gsub("^https?://", "")
    end

    if meta.email then
        local email = stringify(meta.email)
        meta.email = no_style_link(email, "mailto:" .. email)
    end

    if meta.tag_base_url then
        tag_base_url = stringify(meta.tag_base_url)
    end

    return meta
end

function no_style_link(text, target)
    return pandoc.Link(text, target, "", pandoc.Attr("", {"url"}, {
        no_style = "true"
    }))
end

function Link(el)
    local url = el.target
    local text = pandoc.utils.stringify(el.content)
    if el.attr.attributes["no_style"] then
        if FORMAT == "latex" then
            return pandoc.RawInline("latex", string.format("\\href{%s}{%s}", url, text)) -- override default, bc/ pandoc would add unwanted \nolinkurl for mailto links
        end
        return el
    end

    return {pandoc.RawInline("latex", string.format("\\styledlink{%s}{%s}", url, text)),
            pandoc.RawInline("typst", string.format("#styled_link(\"%s\", \"%s\")", url, text))}
end

function Str(el)
    local lead, tag, trail = el.text:match("^(%p*)#([%w_.+-]+)(%p*)$")
    if tag and tag_base_url then
        local tag_name = tag:gsub("_", " ")
        local url = tag_base_url .. tag_name
        return {pandoc.Str(lead or ""), no_style_link(tag_name, url), pandoc.Str(trail or "")}
    end
    return el
end

function Code(el)
    local text = el.text
    local tag = text:match("^#(.+)$") or text
    local bubble_latex = string.format("\\bubbletag{%s}", tag)
    local bubble_typst = string.format("#bubble_tag(\"%s\")", tag)
    if tag_base_url and text:sub(1, 1) == "#" then
        local tag_url = tag_base_url .. tag
        return {pandoc.RawInline("latex", string.format("\\href{%s}{%s}", tag_url, bubble_latex)),
                pandoc.RawInline("typst", string.format("#link(\"%s\")[%s]", tag_url, bubble_typst))}
    end
    return {pandoc.RawInline("latex", bubble_latex), pandoc.RawInline("typst", bubble_typst)}
end

-- Ensure Meta runs before others
return {{
    Meta = Meta
}, {
    Link = Link,
    Str = Str,
    Code = Code
}}
