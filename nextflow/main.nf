#!/usr/bin/env nextflow

nextflow.enable.dsl=2

workflow {
    reads_ch = Channel
        .fromPath("${params.readsdir}/*.fastq.gz")
        .map {
                file ->
                    def sample = file.baseName.split("_")[0] // HD32R1_subsample.fastq.gz -> HD32R1
                    return tuple(sample, file)
        }

        kneaddata_out = kneaddata(reads_ch)
        metaphlan_out = metaphlan(kneaddata_out[0], kneaddata_out[1])
        humann_out = humann(kneaddata_out[0], kneaddata_out[1], metaphlan_out)
}

process kneaddata {
    input:
    tuple val(sample), path(file)

    output:
    val sample
    path "${sample}_kneaddata.fastq.gz"
    path "${sample}_kneaddata*.fastq.gz"
    path "${sample}_kneaddata.log"


    shell:

    """
    kneaddata --unpaired $file --output ./ --output-prefix ${sample}_kneaddata \
        --reference-db ${params.kneaddata_db}

    gzip *.fastq
    """
}

process metaphlan {
    input:
    val sample
    path knead_out

    output:
    path "${sample}_profile.tsv"

    shell:

    """
    metaphlan $knead_out -o ${sample}_profile.tsv \
        --input_type fastq
    """
}

process humann {
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
    humann --input $knead_out --taxonomic-profile $profile \
       --temove-temp-output --search-mode uniref90
       --output-basename $sample
    """
}

