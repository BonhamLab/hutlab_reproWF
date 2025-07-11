### Section #1: Import anadama2 and create a workflow instance (Required)
from anadama2 import Workflow
workflow = Workflow(
    version="0.0.1",
    description="A workflow to run KneadData → MetaPhlAn3 → HUMAnN3 on multiple samples"
)

### Section #2: Add custom arguments and parse arguments
workflow.add_argument("input-extension", desc="the extensions of the input files", default="fastq")
workflow.add_argument("kneaddata-db",       desc="path to KneadData reference db", default="../input/human_genome")
workflow.add_argument("threads",            desc="number of threads to use",       default="2")
args = workflow.parse_args()

### Section #3: Get input/output file names
in_files      = workflow.get_input_files(extension=args.input_extension)
knead_out     = workflow.name_output_files(name=in_files, tag="kneaddata")
metaphlan_out = workflow.name_output_files(name=in_files, tag="metaphlan_taxonomy")
humann_out    = workflow.name_output_files(name=in_files, tag="kneaddata_genefamilies",extension="tsv")

### Section #4: Add tasks
# 1) clean reads with KneadData
workflow.add_task_group(
    "kneaddata --unpaired [depends[0]] --reference-db {} --output {} --threads {}".format(
        args.kneaddata_db, args.output, args.threads
    ),
    depends=in_files,
    targets=knead_out
)

# 2) taxonomic profiling with MetaPhlAn3 (using default DB location)
workflow.add_task_group(
    "metaphlan [depends[0]] --input_type fastq --nproc {} > [targets[0]]".format(
        args.threads
    ),
    depends=knead_out,
    targets=metaphlan_out
)

# 3) functional profiling with HUMAnN3 (using default DB environment vars)
workflow.add_task_group(
    "humann --input [depends[0]] --output {} --threads {}".format(
        args.output,args.threads
    ),
    depends=knead_out,
    targets=humann_out
)

### Section #5: Run tasks (Required)
workflow.go()

