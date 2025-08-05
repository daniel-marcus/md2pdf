// link_color must be set in template

#let styled_link(url, text, underline_color: link_color ) = {
  link(url)[
    #context {
      let text_width = measure(text).width
      box[
        #place(
          top + left,
          dy: -0.25em,
          dx: 0.25em,
          rect(
            width: text_width,
            height: 6pt,
            fill: underline_color,
            stroke: none
          )
        )
      ]
      text
    }]
}

#let bubble_tag(name, color: rgb("dddddd"), text_color: rgb("666666")) = {
    box(
      fill: color,
      stroke: none,
      radius: 5pt,
      inset: (x: 4pt, y: 4pt),
      outset: 0pt,
      baseline: 50%,
      text(name, font: "Menlo", size: 8pt, fill: text_color)
    )
}