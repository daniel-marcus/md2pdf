#let link_color = rgb("ffe8a9")

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

#set text(
  font: "New Computer Modern",
  size: 11pt
)
#set par(leading: 0.55em)

#pad(x: -1em, top: -1em)[
  #align(right)[
    #text("Jane Doe", size: 1.5em) \ 
    #v(-2pt) Some Street 21 \
    12345 Berlin \
    +49 123 456 789 \
    #link("mailto:jane.doe@icloud.com")[jane.doe\@icloud.com] \
  ]

  #v(1em)
  Some Company \ Another Street 21 \ 12345 Berlin
  #v(3em)
]

#pad(x: 1.5em)[
  #align(right)[Berlin, August 1, 2025]
  #v(1.5em)
  #text("Lorem ipsum dolor sit amet", weight: "bold")
  #v(2em)

  Dear Mr.~Xyz,

  #line(length: 0%)
  #v(-0.5em)
  #set par(first-line-indent: 1em, justify: true, spacing: 0.6em)
  #set list(
    spacing: 1.4em, 
    indent: 1.4em
  )

  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
  eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
  minim veniam, quis nostrud exercitation ullamco laboris nisi ut
  aliquip ex ea commodo consequat.Duis aute irure dolor in reprehenderit
  in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
  Excepteur sint occaecat cupidatat non proident, sunt in culpa qui
  officia deserunt mollit anim id est laborum.

  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
  nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in
  reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
  pariatur.

  #pad(y: 1em)[
  - #styled_link("https://externallink.com", "Ut enim ad minim veniam"),
    quis nostrud exercitation

  - Duis aute irure
    #styled_link("https://externallink.com", "dolor in reprehenderit")

  - #styled_link("https://externallink.com", "Excepteur sint") occaecat
    cupidatat non proident

  ]
  Excepteur sint occaecat cupidatat non proident, sunt in culpa qui
  officia deserunt mollit anim id est laborum.


  #v(0.25em)
  #line(length: 0%)

  Kind regards,

  #v(2.5em)

  Jane Doe
]
