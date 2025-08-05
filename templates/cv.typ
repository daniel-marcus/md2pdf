#let link_color = rgb("$link_color$")

$header-includes$

#set text(
  font: "New Computer Modern",
  size: 11pt
)

#align(right)[
  #text("$name$", size: 2em) \
  $jobtitle$ | $city$ \
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

$body$