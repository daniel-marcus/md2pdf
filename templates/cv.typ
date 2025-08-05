#set page(
  paper: "a4",
  margin: (
    left: 25mm,
    right: 25mm,
    top: 25mm,
    bottom: 25mm,
  )
)

#let link_color = rgb("$link_color$")

$header-includes$

#set text(
  font: "New Computer Modern",
  size: 11pt
)
#set par(leading: 0.55em)

#align(right)[
  #text("$name$", size: 2.2em) \
  #v(-1.5pt) #text(style: "italic")[$jobtitle$] | $city$ \
  $email$ \
  $if(websites)$
    $for(websites/allbutlast)$
      #styled_link("$websites.url$", "$websites.name$") | 
    $endfor$
    $for(websites/last)$
      #styled_link("$websites.url$", "$websites.name$")
    $endfor$
  $endif$
]

#show heading.where(level: 1): it => [
  #set text(size: 21pt, weight: "regular")
  #block(
    above: 28pt,
    below: 18.5pt,
  )[
    #it.body
  ]
]

#set table(
  stroke: (x, y) => if x > 0 { (left: 0.4pt + rgb("#c8c8c8")) } else { none },
  align: (right, left),
  inset: (x: 1em, y: 1pt),
)

$body$