# Nextflow Biobakery Tutorial

In this version of the workflow tutorial,
we're going to be building a workflow
that takes single-end read files and runs 3 steps

1. `kneaddata` for quality control
2. `metaphlan` for taxonomic profiling
3. `humann` for functional profiling

This is what it would look like for a single file,
call it `XXXX_subsample.fastq.gz`.

First, we run `kneaddata`:

```sh
kneaddata --unpaired XXXX_subsample.fastq.gz \
    --output ./ \Starting files

    --output-prefix XXXX_kneaddata
```

This will create a few different files,

- `XXXX_kneaddata.fastq.gz`: this is the main output we care about for downstream applications
- `XXXX_kneaddata*.fastq.gz`: there may be a few different are outputs from quality control (eg trimmed/low quality reads)
- `XXXX_kneaddata.log`: log files that contains info on read depth etc (useful for reporting later)

We then want to take the first of these outputs, and run metaphlan

```sh
metaphlan XXXX_kneaddata.fastq.gz --output XXXX_profile.tsv \
    --input_type fastq
```

This will create the file `XXXX_profile.tsv`.

Finally, we want to take the first output from `kneaddata`
and the output from `metaphlan`
and run `humann`:

```sh
humann --input XXXX_kneaddata.fastq.gz \
    --taxonomic-profile XXXX_profile.tsv \
    --output ./ \
    --output-basename XXXX
```

## The structure of a nextflow workflow

Nextflow scripts are written in groovy - 
a dialect of Java.

```groovy
#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// This is a comment
workflow {

    // Channel factory to get starting values / files / etc
    input_ch = Channel.fromPath("../input/*.fastq.gz")

    // processes to call
    p1_out = process1(input_ch)
    p2_out = process2(p1_out)
}

// process definitions
process p1 {
    input
    val some_var

    output
    val other_var

    script:
    """
    echo $some_var > $other var
    """
}

process p2 {
    // etc...
}
```

The basic structure is:

1. preamble - shebang to define the language,
   and a declaration of the nextflow language version
2. a workflow definition - at it's most basic,
   this just calls a series of functions
3. process definitions - these can go before or after the workflow

A few optional components:

- Other files with eg process definitions can be brought in using `include`,
  eg `include { my_process } from "./other_processes.nf"`
- If you'd like to define additional variables / parameters,
  you can do so in a `yaml` file.
  For example, you can have a `my_params.yaml` file:

  ```yaml
  input_directory: /path/on/hpc/
  file_pattern: "*_R{1,2}.fastq.gz"
  ```

  and then refer to them as `"${params.input_directory}"` and
  `"${params.file_pattern}"` in your nextflow workflow.
  - point to the params file with `-params my_params.yaml` when calling the script
  - or you can also pass `params` variables when calling the nextflow script
    using command-line flags, eg `--input_directory "/path/on/hpc" --file_pattern "*_R{1,2}.fastq.gz`
- You can include additional parameters on a per-process basis
  or globally, either by including them within a process definition, or using a config file.


## Channel Factories

The first thing when defining a script is to determine the inputs.
`nextflow` uses "channels", which are just iterators over multiple values.
When you call a process on a channel, the output of that process is another channel,
which you can pass to another process.

Helpfully, `nextflow` has a number of ["channel factories"][channel-factory]
that can make channels using common patterns, like pairs of files
or sequencess of numbers.
Because we're using single-end files for this tutorial,
we're using the `fromPath` channel,
which finds all files matching a given glob pattern,
in this case, `*.fastq.gz`.

[channel-factory]: https://www.nextflow.io/docs/latest/reference/channel.html#channel-factory

Take a look in the `tutorial.nf` file - in the `workflow` definition,
you'll see:

```groovy
reads_ch = Channel.fromPath("*.fastq.gz")
```

## Processes

The bulk of the logic for a workflow occurs in a `process` definition.
Processes need `input:`, `output:` and `script:` directives[^script].

[^script]: You can also use `exec:` which will run `groovy` code
rather than shell code.

### Script

Let's start at the end - take a look at the `kneaddata` process:

```groovy
process kneaddata {
    // ...

    script:
    sample = file.name.replaceAll("fastq.gz", "")

    """
    kneaddata --unpaired $file --output ./ --output-prefix ${sample}_kneaddata \
        --reference-db ${params.kneaddata_db}

    gzip *.fastq
    """
}
```

Here, we define a new variable `sample` that is the input file name
without the `fastq.gz` extension.
For example, the first input `HD32R1_subsample.fastq.gz`
will have `sample = HD32R1_subsample`.

Below that, we use triple-quotes to enter a multi-line string -
this is what will get passed to the shell.
Variables can be interpolated with `$`, so eg `$file` will get replaced
with the contents of the variable `file`.
The `--output-prefix` flag is given `${sample}_kneaddata` with surrounding curly braces
since `$sample_kneaddata` would look for the variable `sample_kneaddata`,
rather than appending `_kneaddata` to the variable `sample`.
You can also use curly braces if your variable is an accessor or a function, 
eg `${params.some_var}` will get the `some_var` field from the `params` variable,
while `$params.some_var` (without curly braces) in a string will try to append the string `.some_var`
to the variable `params`.

Otherwise, this looks just like a shell command.
Here, we're running kneaddata and then gzipping the outputs.

### Input and output

Now, let's look at the beginning of the process:

```groovy
process kneaddata {
    input:
    path file

    output:
    val sample
    path "${sample}_kneaddata.fastq.gz"
    path "${sample}_kneaddata*.fastq.gz"
    path "${sample}_kneaddata.log"

    // ...
}
```

Here, we're defining the inputs and outputs to the process.
In this case, we have a single input - the `file` path
that comes from the `fromFile` channel factory.
And we'll generate several outputs.
Recall that the `sample` variable (`val` can be a string or number etc)
is defined below in the `script` section.
We will return that value so that downstream processes can use it,
as well as 3 paths

1. `${sample}_kneaddata.fastq.gz` is the primary output file
2. `${sample}_kneaddata*.fastq.gz` will get all of the other files
   matching this glob pattern in an array
3. `${sample}_kneaddata.log` the log file

## Running the workflow

In it's current state, if you make this directory
(`hutlab_reproWF/nextflow`)
the working directory, you should be able to run:

```sh
$ nextflow tutorial.nf --kneaddata_db # whatever the path to kd is
```

This will find the 6 fastq files and run `kneaddata` on them.
Logs for the run are found in `.nextflow.log`,
and all of the products of the run
will be found in a "work directory" - by default `work/`.

This is probably not want you want though -
chances are you want them in a specific location.
For that, we can add a `publishDir` to the process definition.

Eg:

```groovy
process kneaddata {
    publishDir "kneaddata/"

    // ...
}
```

After adding this, run the workflow again,
including the `-resume` flag, eg:

```groovy
$ nextflow tutorial.nf -resume --kneaddata_db # whatever the path to kd is
```

Your previous run should be cached, but now the outputs will be linked
to the `kneaddata/` directory.
Notice that these are symlinks - run `ls -l kneaddata/`
and you will see that they still point into the work directory.

If you want to change this behavior, you can change the `mode` parameter of `publishDir`.
For example, `publishDir "kneaddata/", mode: 'link'` will use hard links instead of symlinks.
`mode: 'copy'` will make copies of files instead.
You can also use `mode: 'move'`, but I would avoid this in general -
if you need the files in later steps, this will break the workflow.

## Adding a new process

We are now ready to add in the next step - `metaphlan`.
Recall that the shell command we want to run is

```sh
metaphlan XXXX_kneaddata.fastq.gz --output XXXX_profile.tsv \
    --input_type fastq
```

First, uncomment the call to the `metaphlan` process in the workflow
(remove the leading `//`).
Notice that there are two arguments being passed: `kneaddata_out[0]` and `kneaddata_out[1]`.
These refer to the first and second outputs of the `kneaddata` process,
the `sample` value and the `knead_out` path.

Take a look at the process definition already completed -

```groovy
process metaphlan {
    input:
    val sample
    path knead_out

    output:
    val sample
    path knead_out
    path "${sample}_profile.tsv"

    script:
    """
    # Your code here...
    
    """

}
```

Here, `input:` has these two arguments,
*and so does `output:`*.
This is because we'll need to pass these variables to `humann` as well -
unfortunately, if you try to re-use the `kneaddata` outputs in a subsequent step,
the order of the iterators get out of whack
and you end up mixing outputs from different samples together.

Enter the correct command in the `script` section -
remember to replace `XXXX` with the correct string interpolation syntax.

Once you're ready to try it, run the exact same command as above (including `-resume`!).
You should see something like:

```sh
nextflow tutorial.nf --kneaddata_db /home/kevin/Repos/hutlab_reproWF/input/human_genome/ -resume

 N E X T F L O W   ~  version 24.04.3

Launching `tutorial-inprogress.nf` [sick_shockley] DSL2 - revision: e0e9bc543a

executor >  local (6)
[4b/a32e45] kneaddata (4) [100%] 6 of 6, cached: 6 ✔
[76/547136] metaphlan (2) [  0%] 0 of 6
```

Did you remember to add a `publishDir`?
If not, don't sweat it!
Add it now, and run it again with `-resume`,
your previous results should not need to re-run.

## Make the humann process and call it

You now know all of the pieces!
Can you create a process to run `humann`?
This is the shell command:

```sh
humann --input XXXX_kneaddata.fastq.gz \
    --taxonomic-profile XXXX_profile.tsv \
    --output ./ \
    --output-basename XXXX
```

The input and taxonomic profiles should be outputs from previous processes.
How will you get the output basename?

## TODO:

- add parameter for input directory
- add parameter for location of kneaddata database
- paired-end files
