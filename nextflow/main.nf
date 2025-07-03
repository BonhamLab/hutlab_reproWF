#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { metaphlan } from './process.nf'

workflow {
    reads = Channel
        .fromPath("${params.readsdir}/*.fastq.gz")
        .map {
                file ->
                    def sample = file.baseName.split("_")[0] // HD32R1_subsample.fastq.gz -> HD32R1
                    return tuple(sample, file)
        }
        
        kneaddata(reads)
}

process kneaddata {
    input:
    tuple val(sample), path(reads)

    output:
    path "${sample}_kneaddata.fastq.gz"
    path "${sample}_kneaddata*.fastq.gz"
    path "${sample}_kneaddata.log"


    shell:

    """
    kneaddata --unpaired $reads --output ./ --output-prefix ${sample}_kneaddata
    """
}
