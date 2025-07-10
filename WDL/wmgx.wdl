version 1.0

workflow metagenomics_batch_pipeline {
  input {
    Array[File] raw_reads_fastqs
    String      kneaddata_db
    String      metaphlan_db
    String      humann_protein_db
    String      humann_nucleotide_db
    String      output_dir
    Int         threads = 4
  }

  scatter sample_fastq in raw_reads_fastqs {
    # derive a sample‐specific name (strip extension)
    String sample_name = basename(sample_fastq).replace(/\.fastq$/, "")

    call kneaddata_task {
      input:
        raw_reads = sample_fastq,
        db        = kneaddata_db,
        threads   = threads,
        out_dir   = output_dir + "/${sample_name}/kneaddata"
    }

    call metaphlan_task {
      input:
        knead_out_fastq = kneaddata_task.cleaned_fastq,
        db              = metaphlan_db,
        threads         = threads,
        out_dir         = output_dir + "/${sample_name}/metaphlan"
    }

    call humann_task {
      input:
        knead_out_fastq   = kneaddata_task.cleaned_fastq,
        protein_db        = humann_protein_db,
        nucleotide_db     = humann_nucleotide_db,
        threads           = threads,
        out_dir           = output_dir + "/${sample_name}/humann"
    }
  }

  output {
    Array[Directory] kneaddata_dirs      = kneaddata_task.out_dir
    Array[File]      metaphlan_profiles = metaphlan_task.profile_txt
    Array[Directory] humann_dirs         = humann_task.out_dir
  }
}

########################################
# Task definitions (unchanged from before)
########################################

task kneaddata_task {
  input {
    File   raw_reads
    String db
    Int    threads
    String out_dir
  }

  command <<<
    set -euo pipefail
    mkdir -p ~{out_dir}
    kneaddata \
      --input ~{raw_reads} \
      --reference-db ~{db} \
      --output ~{out_dir} \
      --threads ~{threads}
  >>>

  output {
    File     cleaned_fastq = "~{out_dir}/${basename(raw_reads)}_kneaddata_clean.fastq"
    Directory out_dir
  }

  runtime { cpu: threads }
}

task metaphlan_task {
  input {
    File   knead_out_fastq
    String db
    Int    threads
    String out_dir
  }

  command <<<
    set -euo pipefail
    mkdir -p ~{out_dir}
    metaphlan \
      ~{knead_out_fastq} \
      --input_type fastq \
      --nproc ~{threads} \
      --bowtie2db ~{db} \
      --bowtie2out ~{out_dir}/metaphlan.bowtie2.bz2 \
      -o ~{out_dir}/profile.txt
  >>>

  output {
    File      profile_txt = "~{out_dir}/profile.txt"
    Directory out_dir
  }

  runtime { cpu: threads }
}

task humann_task {
  input {
    File   knead_out_fastq
    String protein_db
    String nucleotide_db
    Int    threads
    String out_dir
  }

  command <<<
    set -euo pipefail
    mkdir -p ~{out_dir}
    humann \
      --input ~{knead_out_fastq} \
      --output ~{out_dir} \
      --threads ~{threads} \
      --protein-database ~{protein_db} \
      --nucleotide-database ~{nucleotide_db}
  >>>

  output {
    Directory out_dir
  }

  runtime { cpu: threads }
}
