local tabcolwidth = "11cm"

function is_dot_line(inline)
    return inline.t == "Str" and inline.text == "."
end

function latexify_inlines(inlines)
    local new_inlines = {}
    for _, inline in ipairs(inlines) do
        if inline.t == "SoftBreak" then --  SoftBreak -> "\\"
            table.insert(new_inlines, pandoc.RawInline("latex", "\\\\"))
        elseif is_dot_line(inline) then -- inline "." -> half row spacing
            table.insert(new_inlines, pandoc.RawInline("latex", "\\vspace{-0.5\\baselineskip}"))
        else
            table.insert(new_inlines, inline)
        end
    end
    return pandoc.write(pandoc.Pandoc({pandoc.Para(new_inlines)}), "latex"):gsub("\n$", "")
end

function latexify_blocks(blocks, no_vspace)
    local latex = pandoc.write(pandoc.Pandoc(blocks), "latex"):gsub("\n$", "")
    -- Reduce vertical spacing before itemize
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
    local rows = {}

    for _, item in ipairs(list.content) do
        local label = nil
        local texts = {}

        if #item == 0 then -- empty row
            rows[#rows + 1] = "\\multicolumn{2}{c}{} \\\\"
        else
            -- Process first paragraph for label and first text piece
            local firstBlock = item[1]
            if firstBlock.t == "Para" or firstBlock.t == "Plain" then
                local label_inlines, text_inlines = split_inlines_at_pipe(firstBlock.content)
                label = "\\textsc{" .. latexify_inlines(label_inlines) .. "}"
                local text_latex = latexify_inlines(text_inlines)
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

                local nested_latex = latexify_blocks(remaining_blocks, false) -- #texts > 0)
                table.insert(texts, nested_latex)
            end

            local fulltext = table.concat(texts, " \\\\\n")

            rows[#rows + 1] = string.format("%s & \\begin{minipage}[t]{\\linewidth} %s \\end{minipage} \\\\", label,
                fulltext)
        end
    end

    local table_env =
        "\\begin{flushright}\n\\begin{tabular}{r|p{" .. tabcolwidth .. "}}\n" .. table.concat(rows, "\n") ..
            "\n\\end{tabular}\n\\end{flushright}\n"

    return pandoc.RawBlock("latex", table_env)
end

function Pandoc(doc)
    local new_blocks = {}
    local i = 1
    while i <= #doc.blocks do
        local block = doc.blocks[i]
        if i == 1 and block.t ~= "Header" then
            doc.meta.lead = pandoc.MetaBlocks({block})
        elseif block.t == "BulletList" then
            table.insert(new_blocks, process_list(block))
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

