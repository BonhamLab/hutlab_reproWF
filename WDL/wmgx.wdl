version 1.0

workflow wmgx_workflow {
  input {
    File input               # your input file or manifest
    String output_dir        # path to the directory to be created for outputs
    String functional_profiling_option = "--bypass-translated-search"
    Boolean bypass_strain_profiling = true
    Int threads = 4
  }

  call wmgx_task {
    input:
      input = input,
      output_dir = output_dir,
      functional_profiling_option = functional_profiling_option,
      bypass_strain_profiling = bypass_strain_profiling,
      threads = threads
  }

  output {
    Directory output_data = wmgx_task.output_dir
  }
}

task wmgx_task {
  input {
    File input
    String output_dir
    String functional_profiling_option
    Boolean bypass_strain_profiling
    Int threads
  }

  command <<<
    set -euo pipefail
    # create output dir if it doesn’t exist
    mkdir -p "${output_dir}"

    biobakery_workflows wmgx \
      --input "${input}" \
      --output "${output_dir}" \
      ${functional_profiling_option} \
      ${ if (bypass_strain_profiling) "--bypass-strain-profiling" else "" } \
      --threads ${threads}
  >>>

  output {
    # expose the entire output directory
    Directory output_dir = output_dir
  }

  runtime {
    cpu: threads
    # memory, disks, etc. can be added here if needed
  }
}
