#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { metaphlan } from './process.nf'

workflow {
    reads = Channel
        .fromPath("$params.readsdir}/*.fastq.gz")
        .map {
                file ->
                    def file.baseName // 
            }
}

process kneaddata {
    input:
    val sample
    path reads

    output
    path "${sample}_kneaddata.fastq.gz"
    path "${sample_kneaddata*.fastq.gz"
    path "${sample}_kneaddata.log"


    shell:

    """
    kneaddata --unpaired $reads --output ./ --output-prefix ${sample}_kneaddata
    """
}
