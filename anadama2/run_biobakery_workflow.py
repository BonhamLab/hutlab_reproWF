### Section #1: Import anadama2 and create a workflow instance (Required)
from anadama2 import Workflow
workflow = Workflow(version="0.0.1", description="A workflow to run MetaPhlAn" )

### Section #2: Add custom arguments and parse arguments (Optional)
workflow.add_argument("input-extension", desc="the extensions of the input files", default="fastq")
args = workflow.parse_args()

### Section #3: Get input/output file names (Optional)
in_files = workflow.get_input_files(extension=args.input_extension)
out_files = workflow.name_output_files(name=in_files, tag="biobakery_workflow")

### Section #4: Add tasks (Required)
workflow.add_task_group("biobakery_workflow wmgx [depends[0]] --input_type [extension] > [targets[0]] --bypass-quality-control --bypass-functional-profiling --taxonomic-profiling-options='-t rel_ab_w_read_stats'  --bypass-strain-profiling --remove-intermediate-output", depends=in_files, targets=out_files, extension=args.input_extension)
### Section #5: Run tasks (Required)
workflow.go()