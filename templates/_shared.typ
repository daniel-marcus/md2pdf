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

#let bubble_tag(name, color: rgb("#e6e6e6"), text_color: rgb("#595959")) = {
    box(
      fill: color,
      stroke: none,
      radius: 5pt,
      inset: (x: 4pt, top: 3pt, bottom: 0pt),
      height: 1.1em,
      outset: 0pt,
      baseline: 0%,
      text(name, font: "Menlo", size: 8pt, fill: text_color)
    )
}