#!/bin/bash
#SBATCH -c 2                # Number of cores (-c)
#SBATCH -t 9-00:00          # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH -p huttenhower   # Partition to submit to
#SBATCH --mem=45000           # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -o workflow_.out  # File to which STDOUT will be written
#SBATCH -e workflow_.err  # File to which STDERR will be written

source /n/huttenhower_lab/tools/hutlab/src/hutlabrc_rocky8.sh
hutlab load rocky8/biobakery_workflows/3.1.0-devel-dependsUpdate
hutlab load rocky8/metaphlan4/4.1.1

biobakery_workflows wmgx --input /n/holylfs05/LABS/huttenhower_lab/Lab/data/EMP500/cleaned_fastqs/\
 --output /n/holylfs05/LABS/huttenhower_lab/Lab/data/EMP500/workflow_outputs/MPAJan25_EMP500/ --input-extension fastq.gz\
 --grid-jobs 900 --grid-partition shared --bypass-quality-control --bypass-functional-profiling\
 --threads 8 --taxonomic-profiling-options="-t rel_ab_w_read_stats"\
 --bypass-strain-profiling --remove-intermediate-output