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
  
  Kevin Bonham \
  Sagun Maharjan \
  Emily Green

  2025-07-11
]


== Workflows consist of the following components

1. Tasks (processes, rules, etc): single step in a workflow (typically one command)
  - inputs
  - outputs
  - command#pause
2. Workflow: Order of steps (instructions to build computational graph)
  - Also a way to find / specify inputs#pause
3. Parameters: variables that may change from run to run
  - may be global (eg output directory)
  - or task-specific (eg memory to allocate)


== Workflows build computational graph

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

#text(16pt)[
#diagram(
  node-stroke: blue,
  edge-corner-radius: none,
  edge-stroke: purple.darken(50%),
  label-sep:0.2em,
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

  node((2.5,2), [Task 4 output], name: <f>),

  node((3.5,3), [Report], name: <h>),

  node((5,0), [Input file 2], name: <x>),
  node((5,2), [outputs...], name: <y>),

  node((8,2), [outputs...], name: <u>),

  edge((-0.3,3),(0.1,3), "-|>"),
  node((0.4,3), [Task], stroke:none),
  node((0,3.5), [], width:1em,height:1em),
  node((0.4,3.5), [File ], stroke: none),

  // Edges
  bent-edge(<a>, <b>, [_Task 1_]),
  bent-edge(<a>, <c>, [_Task 2_]),
  bent-edge(<b>, <d>, [_Task 3_]),
  bent-edge(<b>, <e>),
  edge(<c>, <f>, "-|>", [_Task 4_]),
  edge(<e>, <h>, "-|>"),
  edge(<x>, <y>, "--|>", [Tasks...]),
  edge(<w>, <u>, "--|>", [Tasks...]),
  edge(<y>, <h>, "-|>"),
  edge(<u>, <h>, "-|>"),
)
]

== In anadama, tasks are added to workflows

#slide(composer: (40%,60%))[
#set text(16pt)
```python
workflow.add_task(
  "cat [depends[0]] > [targets[0]]",
  depends = input_files,
  targets = output_files
)
```

][
#set text(16pt)
#diagram(
  node-stroke: blue,
  edge-corner-radius: none,
  edge-stroke: purple.darken(50%),
  label-sep:0.2em,
  spacing: (10pt, 47pt),

  // Nodes
  node((1.5,0), [*input_file*], stroke:3pt, name: <a>),
  node((0.5,1), [*output_file*], stroke:3pt, name: <b>),
  node((2.5,1), [Task 2 output], name: <c>),
  node((0,2), [Task 3 output 1], name: <d>),
  node((1,2), [Task 3 output 2], name: <e>),

  node((2.5,2), [Task 4 output], name: <f>),
  bent-edge(<a>, <b>, [*_task1_*]),
  bent-edge(<a>, <c>, [_Task 2_]),
  bent-edge(<b>, <d>, [_Task 3_]),
  bent-edge(<b>, <e>),
  edge(<c>, <f>, "-|>", [_Task 4_]),

  node(stroke:teal+2pt, enclose:(<a>,<b>))
)
]
== In nextflow, tasks are `process`es

#slide(composer: (40%,60%))[
#set text(16pt)

```groovy
process task1 {
  input:
  path input_file

  output:
  path output_file

  shell:
  """
  cat $input_file > $output_file
  """
}
```

][
#set text(16pt)
#diagram(
  node-stroke: blue,
  edge-corner-radius: none,
  edge-stroke: purple.darken(50%),
  label-sep:0.2em,
  spacing: (10pt, 47pt),

  // Nodes
  node((1.5,0), [*input_file*], stroke:3pt, name: <a>),
  node((0.5,1), [*output_file*], stroke:3pt, name: <b>),
  node((2.5,1), [Task 2 output], name: <c>),
  node((0,2), [Task 3 output 1], name: <d>),
  node((1,2), [Task 3 output 2], name: <e>),

  node((2.5,2), [Task 4 output], name: <f>),
  bent-edge(<a>, <b>, [*_task1_*]),
  bent-edge(<a>, <c>, [_Task 2_]),
  bent-edge(<b>, <d>, [_Task 3_]),
  bent-edge(<b>, <e>),
  edge(<c>, <f>, "-|>", [_Task 4_]),

  node(stroke:teal+2pt, enclose:(<a>,<b>))
)
]

#slide(composer: (40%,60%))[

#set text(16pt)
```groovy
process task3 {
  input:
  path in_from_1

  output:
  path out1
  path out2

  shell:
  """
  cat $input_file > $out1
  echo "I'm done!" > $out2
  """
}
```

][
#set text(16pt)
#diagram(
  node-stroke: blue,
  edge-corner-radius: none,
  edge-stroke: purple.darken(50%),
  label-sep:0.2em,
  spacing: (10pt, 47pt),

  // Nodes
  node((1.5,0), [Input file 1], name: <a>),
  node((0.5,1), [*in_from_1*], name: <b>, stroke:3pt),
  node((3.5,1), [Task 2 output], name: <c>),
  node((0,2), [*out1*], name: <d>, stroke:3pt),
  node((1.5,2), [*out2*], name: <e>, stroke:3pt),

  node((3.5,2), [Task 4 output], name: <f>),
  bent-edge(<a>, <b>, [_Task 1_]),
  bent-edge(<a>, <c>, [_Task 2_]),
  bent-edge(<b>, <d>, [*_task3_*], label-pos:0.6),
  bent-edge(<b>, <e>),
  edge(<c>, <f>, "-|>", [_Task 4_]),
  node(stroke:teal+2pt, enclose:(<b>,<d>,<e>))
)
]

== Processes are called like functions

#slide(composer: (43%,50%))[
#set text(15pt)
```groovy
workflow {
  input_ch = Channel
    .fromPath("inputs/*.txt")

  t1_out = task1(input_ch)
  t2_out = task2(input_ch)
  
  t3_out = task3(t1_out)
  t4_out = task4(t2_out)

  report = report_task(t3_out
    .collect().map {
      t3-> t3[1]
  })

}
```

][
#set text(13pt)
#diagram(
  node-stroke: blue,
  edge-corner-radius: none,
  edge-stroke: purple.darken(50%),
  label-sep:0.2em,
  spacing: (10pt, 47pt),

  // Nodes
  node((1.5,0), [input_ch[0]], name: <a>),
  node((0.5,1), [t1_out], name: <b>),
  node((2.5,1), [t2_out], name: <c>),
  node((6, 0), [input_ch[n]], name:<w>),

  node((5.5, 1), [...], stroke:none),

  node((0,2), [t3_out[0]], name: <d>),
  node((1,2), [t3_out[1]], name: <e>),

  node((2.5,2), [t4_out], name: <f>),

  node((2.5,3), [Report], name: <h>),

  node((5,0), [input_ch[1]], name: <x>),
  node((5,2), [outputs...], name: <y>),

  node((6,2), [outputs...], name: <u>),

  edge((-0.3,3),(0.1,3), "-|>"),
  node((0.4,3), [Task], stroke:none),
  node((0,3.5), [], width:1em,height:1em),
  node((0.4,3.5), [File ], stroke: none),

  // Edges
  bent-edge(<a>, <b>, [_Task 1_]),
  bent-edge(<a>, <c>, [_Task 2_]),
  bent-edge(<b>, <d>, [_Task 3_]),
  bent-edge(<b>, <e>),
  edge(<c>, <f>, "-|>", [_Task 4_]),
  edge(<e>, <h>, "-|>"),
  edge(<x>, <y>, "--|>", []),
  edge(<w>, <u>, "--|>", []),
  edge(<y>, <h>, "-|>"),
  edge(<u>, <h>, "-|>"),
)
]


