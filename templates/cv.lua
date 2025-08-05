local tabcolwidth = "11cm"

function is_dot_line(inline)
    return inline.t == "Str" and inline.text == "."
end

function parse_element(el)
    return pandoc.write(pandoc.Pandoc({el}), FORMAT)
end

function parse_inlines(inlines)
    local new_inlines = {}
    for _, inline in ipairs(inlines) do
        if inline.t == "SoftBreak" then --  SoftBreak -> "\\"
            table.insert(new_inlines, pandoc.LineBreak())
        elseif is_dot_line(inline) then -- inline "." -> half row spacing
            -- TODO typst
            table.insert(new_inlines, pandoc.RawInline("latex", "\\vspace{-0.5\\baselineskip}"))
        else
            table.insert(new_inlines, inline)
        end
    end
    return pandoc.write(pandoc.Pandoc({pandoc.Para(new_inlines)}), FORMAT):gsub("\n$", "")
end

function parse_blocks(blocks, no_vspace)
    local parsed_blocks = {}
    for _, block in ipairs(blocks) do
        if block.t == "BulletList" and FORMAT == "typst" then
            table.insert(parsed_blocks, wrap_list_in_pad(block))
        else
            table.insert(parsed_blocks, block)
        end
    end
    local latex = pandoc.write(pandoc.Pandoc(parsed_blocks), FORMAT):gsub("\n$", "")
    -- Reduce vertical spacing before itemize
    -- TODO typst
    latex = latex:gsub("\\begin{itemize}", "\\vspace{-1\\baselineskip}\n\\begin{itemize}")
    return latex
end

function split_inlines_at_pipe(inlines)
    local label, text = {}, {}
    local found_pipe = false

    for _, inline in ipairs(inlines) do
        if not found_pipe and inline.t == "Str" and inline.text == "|" then
            found_pipe = true
        elseif not found_pipe then
            table.insert(label, inline)
        else
            table.insert(text, inline)
        end
    end

    return label, text
end

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function process_list(list)
    local latex_rows = {}
    local typst_rows = {}

    for _, item in ipairs(list.content) do
        local label = nil
        local texts = {}

        if #item == 0 then -- empty row
            latex_rows[#latex_rows + 1] = "\\multicolumn{2}{c}{} \\\\"
            typst_rows[#typst_rows + 1] = "table.cell(colspan: 2, stroke: none, block(height: 1em, []))"
        else
            -- Process first paragraph for label and first text piece
            local firstBlock = item[1]
            if firstBlock.t == "Para" or firstBlock.t == "Plain" then
                local label_inlines, text_inlines = split_inlines_at_pipe(firstBlock.content)
                local label_text = parse_inlines(label_inlines)
                label = parse_element(pandoc.SmallCaps(label_text))
                local text_latex = parse_inlines(text_inlines)
                if text_latex ~= "" then
                    table.insert(texts, text_latex)
                end
            end

            -- Process remaining blocks (from 2nd to end)
            if #item > 1 then
                local remaining_blocks = {}
                for i = 2, #item do
                    table.insert(remaining_blocks, item[i])
                end
                local nested_latex = parse_blocks(remaining_blocks, false) -- #texts > 0)
                table.insert(texts, nested_latex)
            end

            local latex_fulltext = table.concat(texts, " \\\\\n")
            local typst_fulltext = table.concat(texts, " \\\n")

            latex_rows[#latex_rows + 1] = string.format(
                "%s & \\begin{minipage}[t]{\\linewidth} %s \\end{minipage} \\\\", label, latex_fulltext)

            typst_rows[#typst_rows + 1] = string.format("[%s], [%s]", label, typst_fulltext)
        end
    end

    local latex_table = "\\begin{flushright}\n\\begin{tabular}{r|p{" .. tabcolwidth .. "}}\n" ..
                            table.concat(latex_rows, "\n") .. "\n\\end{tabular}\n\\end{flushright}\n"

    local typst_table = "#align(right)[#table(\n  columns: (auto, " .. tabcolwidth .. " + 2em),\n" ..
                            table.concat(typst_rows, ",\n") .. "\n)]"

    return {pandoc.RawBlock("latex", latex_table), pandoc.RawBlock("typst", typst_table)}
end

function Pandoc(doc)
    local new_blocks = {}
    local i = 1
    while i <= #doc.blocks do
        local block = doc.blocks[i]
        if i == 1 and block.t ~= "Header" then
            doc.meta.lead = pandoc.MetaBlocks({block})
        elseif block.t == "BulletList" then
            local result = process_list(block)
            for _, b in ipairs(result) do
                table.insert(new_blocks, b)
            end
        else
            table.insert(new_blocks, block)
        end
        i = i + 1
    end
    doc.blocks = new_blocks
    return doc
end

function Strong(elem)
    return pandoc.SmallCaps(elem.content)
end

function Header(el)
    el.classes = {"unnumbered"}
    return el
end

function wrap_list_in_pad(block)
    local typst_str = pandoc.write(pandoc.Pandoc({block}), "typst")
    local wrapped = "#pad(y: 0.25em)[\n" .. typst_str .. "\n]\n"
    return pandoc.RawBlock("typst", wrapped)
end
