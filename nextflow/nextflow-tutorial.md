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

## Starting files

With this in mind, the `main.nf` file in this directory
has the start of a workflow setup for you.

First, it uses an input "Channel factory" -
this is an iterator that can run each sequence of tasks
on each of the input files.
Because we're using single-end files,
we're using the `from_path` channel,
which finds all files matching a given glob pattern,
in this case, `*.fastq.gz`
