version 1.0

workflow metagenomics_batch_pipeline {
  input {
    Array[File] raw_reads_fastqs
    String      kneaddata_db
    String      output_dir
    Int         threads = 4
  }

  scatter (sample_fastq in raw_reads_fastqs) {
    # derive a sample name by stripping “.fastq”
    String sample_name = sub(basename(sample_fastq), "\\.fastq$", "")

    # Define the output directory paths for each tool explicitly within the scatter
    String kneaddata_sample_out_dir = output_dir + "/" + sample_name + "/kneaddata"
    String metaphlan_sample_out_dir = output_dir + "/" + sample_name + "/metaphlan"
    String humann_sample_out_dir    = output_dir + "/" + sample_name + "/humann"

    call kneaddata_task {
      input:
        raw_reads = sample_fastq,
        db        = kneaddata_db,
        threads   = threads,
        out_dir   = kneaddata_sample_out_dir
    }

    call metaphlan_task {
      input:
        knead_out_fastq = kneaddata_task.cleaned_fastq,
        threads         = threads,
        out_dir         = metaphlan_sample_out_dir
    }

    call humann_task {
      input:
        knead_out_fastq = kneaddata_task.cleaned_fastq,
        threads         = threads,
        out_dir         = humann_sample_out_dir
    }
  }

  output {
    # The workflow already knows the *paths* to these directories from the scatter block
    # so we can directly refer to the 'String' variables defined there.
    # We collect them as arrays since they are in a scatter.
    Array[String] kneaddata_dirs     = kneaddata_sample_out_dir
    Array[File]   metaphlan_profiles = metaphlan_task.profile_txt
    Array[String] humann_dirs        = humann_sample_out_dir
  }
}

task kneaddata_task {
  input {
    File   raw_reads
    String db
    Int    threads
    String out_dir # This is an input path
  }

  command <<<
    set -euo pipefail
    mkdir -p ~{out_dir}
    kneaddata \
      --unpaired ~{raw_reads} \
      --reference-db ~{db} \
      --output ~{out_dir} \
      --threads ~{threads} \
      --bypass-trf
  >>>

  output {
    # Only output newly generated files/paths, not the input 'out_dir' itself
    String sample_base_name = sub(basename(raw_reads), "\\.fastq$", "")
    File cleaned_fastq = "~{out_dir}/~{sample_base_name}_kneaddata.fastq"
  }

  runtime {
    cpu: threads
  }
}

task metaphlan_task {
  input {
    File   knead_out_fastq
    Int    threads
    String out_dir # This is an input path
  }

  command <<<
    set -euo pipefail
    mkdir -p ~{out_dir}
    metaphlan \
      ~{knead_out_fastq} \
      --input_type fastq \
      --nproc ~{threads} \
      --bowtie2out ~{out_dir}/metaphlan.bowtie2.bz2 \
      -o ~{out_dir}/profile.txt
  >>>

  output {
    # Only output newly generated files/paths, not the input 'out_dir' itself
    File profile_txt = "~{out_dir}/profile.txt"
  }

  runtime {
    cpu: threads
  }
}

task humann_task {
  input {
    File   knead_out_fastq
    Int    threads
    String out_dir # This is an input path
  }

  command <<<
    set -euo pipefail
    mkdir -p ~{out_dir}
    humann \
      --input ~{knead_out_fastq} \
      --output ~{out_dir} \
      --threads ~{threads}
  >>>

  output {
    # HUMAnN typically outputs multiple files into the directory.
    # If you need to expose specific files, you'd list them here.
    # If the workflow needs to know the *path* to the output directory,
    # it already has 'humann_sample_out_dir' from the scatter.
    # If you want to explicitly denote that the *entire directory* is an output artifact,
    # you might need to rely on Cromwell's output localization or zip the directory.
    # For now, if no specific files are needed, and the *path* is tracked, you can leave this empty,
    # or if you need to pass the directory itself as a *result* of the task, you'd do:
    # Directory output_directory = out_dir (but this goes back to the Directory type issue)
    # The current best practice in WDL 1.0 for outputting a directory is usually to
    # output specific files within it, or rely on the system handling the output paths.
    # If you truly need the *output directory itself* as an output variable for downstream
    # WDL tasks that operate on a directory, you might need to use a trick like:
    # File humann_output_dir_marker = "~{out_dir}/humann_completed.txt"
    # and then from the path of that marker file, infer the directory.
    # But given your current workflow, the `humann_sample_out_dir` string is sufficient
    # to refer to the location.
  }

  runtime {
    cpu: threads
  }
}
