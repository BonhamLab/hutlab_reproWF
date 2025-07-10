#!/usr/bin/env nextflow

nextflow.enable.dsl=2

workflow {
    reads_ch = Channel.fromPath("../input/*.fastq.gz")

    kneaddata_out = kneaddata(reads_ch)
    // metaphlan_out = metaphlan(kneaddata_out[0], kneaddata_out[1])

    // What to add to run the humann process? 
}

process kneaddata {
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

process humann {
    input:
    // what inputs do you knead?

    output:
    // what outputs do you need?

    script:
    
    """
    # your code here:

    """
}

