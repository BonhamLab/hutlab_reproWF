#import "@preview/touying:0.6.1": *
#import "@preview/cetz:0.4.0"
#import themes.simple: *
#import "@preview/codly:1.0.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

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


== Workflows consist of the following components

1. Tasks (processes, rules, etc): single step in a workflow (typically one command)
  - inputs
  - outputs
  - command
2. Workflow: Order of steps (instructions to build computational graph)
3. Parameters: variables that may change from run to run
  - may be global (eg output directory)
  - or task-specific (eg memory to allocate)


== Workflows builds computational graph

#let bent-edge(from, to, ..args) = {
  let midpoint = (from, 50%, to)
  let vertices = (
    from,
    (from, "|-", midpoint),
    (midpoint, "-|", to),
    to,
  )
  edge(..vertices, "-|>", ..args)
}

#set text(16pt)
#diagram(
  node-stroke: luma(80%),
  edge-corner-radius: none,
  spacing: (10pt, 47pt),

  // Nodes
  node((1.5,0), [Input file 1], name: <a>),
  node((0.5,1), [Task 1 output], name: <b>),
  node((2.5,1), [Task 2 output], name: <c>),
  node((8, 0), [Input file N], name:<w>),
  node((7, 0), [...], stroke:none),
  node((7, 2), [...], stroke:none),

  node((0,2), [Task 3 output 1], name: <d>),
  node((1,2), [Task 3 output 2], name: <e>),

  node((2.5,2), [Task3 output], name: <f>),

  node((3.5,3), [Report], name: <h>),

  node((5,0), [Input file 2], name: <x>),
  node((5,2), [outputs...], name: <y>),

  node((8,2), [outputs...], name: <u>),

  // Edges
  bent-edge(<a>, <b>, [_Task 1_]),
  bent-edge(<a>, <c>, [_Task 2_]),
  bent-edge(<b>, <d>, [_Task 3_]),
  bent-edge(<b>, <e>),
  edge(<c>, <f>, "-|>", [_Task 4_]),
  edge(<f>, <h>, "-|>"),
  edge(<e>, <h>, "-|>"),
  edge(<d>, <h>, "-|>"),
  edge(<x>, <y>, "--|>", [Tasks...]),
  edge(<w>, <u>, "--|>", [Tasks...]),
  edge(<y>, <h>, "-|>"),
  edge(<u>, <h>, "-|>"),
)
