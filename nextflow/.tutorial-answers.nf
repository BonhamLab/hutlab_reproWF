#!/usr/bin/env nextflow

nextflow.enable.dsl=2

workflow {
    reads_ch = Channel.fromPath("../input/*.fastq.gz")

    kneaddata_out = kneaddata(reads_ch)
    metaphlan_out = metaphlan(kneaddata_out[0], kneaddata_out[1])
    humann_out = humann(metaphlan_out[0], metaphlan_out[1], metaphlan_out[2])
}

process kneaddata {
    publishDir "kneaddata/"
    input:
    path file

    output:
    val sample
    path "${sample}_kneaddata.fastq.gz"
    path "${sample}_kneaddata*.fastq.gz"
    path "${sample}_kneaddata.log"


    script:
    sample = file.name.replaceAll(".fastq.gz", "")

    """
    kneaddata --unpaired $file --output ./ --output-prefix ${sample}_kneaddata \
        --reference-db ${params.kneaddata_db}

    gzip *.fastq
    """
}

process metaphlan {
    publishDir "metaphlan/", mode: copy

    input:
    val sample
    path knead_out

    output:
    val sample
    path knead_out
    path "${sample}_profile.tsv"

    shell:

    """
    metaphlan $knead_out -o ${sample}_profile.tsv \
        --input_type fastq
    """
}

process humann {
    publishDir "humann/", mode: copy

    input:
    val sample
    path knead_out
    path profile

    output:
    path "${sample}_genefamilies.tsv"
    path "${sample}_pathabundance.tsv"
    path "${sample}_pathcoverage.tsv"

    shell:
    
    """
    humann --input $knead_out -o ./ --taxonomic-profile $profile \
       --remove-temp-output --search-mode uniref90 \
       --output-basename $sample
    """
}

