#let link_color = rgb("$link_color$")

$header-includes$

#set text(
  font: "New Computer Modern",
  size: 11pt
)
#set par(leading: 0.55em)

#pad(x: -1em, top: -1em)[
  #align(right)[
    #text("$name$", size: 1.5em) \ 
    #v(-2pt) $street$ \
    $zip$ $city$ \
    $phone$ \
    $email$ \
  ]

  #v(1em)
  $toaddress$
  #v(3em)
]

#pad(x: 1.5em)[
  #align(right)[$city$, $date$]
  #v(1.5em)
  #text("$subject$", weight: "bold")
  #v(2em)

  $opening$

  #line(length: 0%)
  #v(-0.5em)
  #set par(first-line-indent: 1em, justify: true, spacing: 0.6em)
  #set list(
    spacing: 1.4em, 
    indent: 1.4em
  )

  $body$

  #v(0.25em)
  #line(length: 0%)

  $closing$

  #v(2.5em)

  $name$
]
