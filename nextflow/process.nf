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
        -t rel_ab_w_read_stats
    """
}
