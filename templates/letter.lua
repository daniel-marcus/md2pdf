function Meta(meta)
    local lang = pandoc.utils.stringify(meta.lang or "en")
    meta.toaddress = parse_linebreaks(meta.toaddress)
    meta.date = parse_date(meta.date, lang)
    meta.closing = meta.closing or (lang == "de" and meta.closing_de or meta.closing_en)
    return meta
end

function parse_linebreaks(blocks)
    if type(blocks) == "table" and blocks[1] and blocks[1].t == "Para" then
        local inlines = {}
        for _, inline in ipairs(blocks[1].c) do
            if inline.t == "SoftBreak" then
                table.insert(inlines, pandoc.LineBreak())
            else
                table.insert(inlines, inline)
            end
        end
        return pandoc.MetaInlines(inlines)
    end
end

local months_de = {"Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober",
                   "November", "Dezember"}

local months_en = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
                   "November", "December"}

function parse_date(meta_date, lang_str)
    local date_str = pandoc.utils.stringify(meta_date or "")

    local y, m, d = date_str:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
    if not (y and m and d) then
        return nil
    end

    local month_index = tonumber(m)
    local day = tonumber(d)
    local year = y

    local formatted_date

    if lang_str == "de" then
        formatted_date = string.format("%d. %s %s", day, months_de[month_index], year)
    else
        formatted_date = string.format("%s %d, %s", months_en[month_index], day, year)
    end

    return pandoc.MetaInlines {pandoc.Str(formatted_date)}
end

function wrap_list_in_pad(block)
    local typst_str = pandoc.write(pandoc.Pandoc({block}), "typst")
    local wrapped = "#pad(y: 1em)[\n" .. typst_str .. "\n]\n"
    return pandoc.RawBlock("typst", wrapped)
end

function BulletList(el)
    if FORMAT == "typst" then
        return wrap_list_in_pad(el)
    end
    return el
end
