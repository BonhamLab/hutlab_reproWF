#import "@preview/touying:0.6.1": *
#import "@preview/cetz:0.4.0"
#import themes.simple: *
#import "@preview/codly:1.0.0": *
#import "@preview/fletcher:0.5.9" as fletcher: diagram, node, edge

#show: codly-init.with()
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [2025-07-11 | Kevin Bonham],
)

#set text(22pt, font: "Liberation Sans")

#title-slide[
  = Components of reproducible workflows

  #v(2em)
  
  Kevin Bonham, PhD

  2025-07-11
]

