# AnADAMA2 workflow tutorial:

  

### (Section 1.) AnADAMA2 and general example workflow (Python executable + R executable + Data table + PDF generation task)
This tutorial shows how to use AnADAMA2 to build a fully tracked, reproducible workflow. It uses trim.py to trim raw TSV files, plot.py to generate figures, and analysis.R to perform statistical analysis in R, while also backing up intermediate text outputs, and generating a PDF report from a Jinja template. AnADAMA2 handles directory creation, tracks both your scripts and input files, and only reruns tasks when inputs or code have changed to maintain efficiency and reproducibility.

```
cd ~/Tutorials/hutlab_reproWF/anadama2
python3 run.py --input ./input/ --output output --lines 10 --metadata ./input/metadata.tsv
```  

### (Section 2.) AnADAMA2 running metaphlan for multiple samples
This tutorial shows how to set up an AnADAMA2 pipeline to run MetaPhlAn on all your samples with a single command. You start by importing AnADAMA2 and creating a `Workflow` instance, then add an optional argument for file extensions and parse the command-line inputs. Next you collect all input files matching that extension and automatically generate corresponding output names tagged with “metaphlan_taxonomy.” By defining a single task group that runs MetaPhlAn on each input and directs its output to the matching target file, you can then launch everything at once with `workflow.go()`, letting AnADAMA2 handle dependency tracking, parallel execution, and only re-running steps when inputs or code change.
```
cd ~/Tutorials/hutlab_reproWF/anadama2
python3 run_metaphlan_workflow.py --input ./input/ --output output_metaphlan_workflow
```
###  (Section 3.) AnADAMA2 running metaphlan for multiple samples in a cluster

- **Step1:** Change `add_task_group` to `add_task_group_gridable` in the above workflow code. 
- **Step2:** Remove the `bowtie2 intermediate files` generated from last step using `rm -rf ~/Tutorials/hutlab_reproWF/anadama2/input/*bowtie2out.txt`
- NOTE: Since `grid` is not available in the VM, the task will run locally. 
```
cd ~/Tutorials/hutlab_reproWF/anadama2
python3 run_metaphlan_workflow_grid.py --input ./input/ --output output_metaphlan_workflow_grid --grid-jobs 2
```

###  (Section 4.) AnADAMA2 - Running kneadata + metaphlan + humann
This script provides an end-to-end AnADAMA2 custom biobakery workflow that automatically discovers all your FASTQ files, cleans them with KneadData using your specified human reference database, generates taxonomic profiles with MetaPhlAn, and produces functional annotations with HUMAnN, all in one go. 
AnADAMA2 will track your input files and scripts, create per-sample output directories, and only rerun steps when the underlying data or code have changed, ensuring an efficient, reproducible metagenomics pipeline.
```
cd ~/Tutorials/hutlab_reproWF/anadama2
python3 run_custom_biobakery_workflow.py --input ./input --output output_custom_biobakery_workflows 
```


# WDL workflow tutorial:

### Introduction

The Workflow Description Language (WDL) is a concise, human-readable DSL designed to specify bioinformatics and data-science pipelines in terms of **tasks** (individual command-line steps) and **workflows** (how those tasks connect). By pairing a WDL script with the Cromwell execution engine, you get a fully reproducible, portable pipeline: Cromwell reads your `*.wdl` file plus a JSON of runtime inputs, spins up each task in order (or in parallel when you use `scatter`), tracks inputs and outputs, and reruns only what’s changed.
In this example, the `metagenomics_batch_pipeline.wdl` script defines a metagenomics workflow that:
1.  **Scatters** over all your input FASTQ files
2.  **Cleans** reads with KneadData (`kneaddata_task`)
3.  **Profiles** taxonomy via MetaPhlAn3 (`metaphlan_task`)
4.  **Profiles** function via HUMAnN3 (`humann_task`)
    
Each sample’s results live in its own subdirectory under your chosen `output_dir`, and Cromwell will automatically create those directories, allocate the right number of CPUs (`threads`), and collect the outputs you declare.

### Requirements

-   **Java** (to run Cromwell’s JAR)
-   **Cromwell** (`cromwell.jar`)
-   All command-line tools on your `PATH`: `kneaddata`, `metaphlan`, `humann`
    

### Running WDL Locally with Cromwell
```
cd ~/Tutorials/hutlab_reproWF/WDL
cromwell run wmgx.wdl --inputs wmgx_inputs.json
```
This single command tells Cromwell to load your WDL, ingest the inputs from `wmgx_inputs.json`, and execute the entire metagenomics batch pipeline,parallelizing across samples, managing dependencies, and delivering a reproducible set of outputs.