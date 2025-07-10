#anadama2 workflow tutorial:  

### Anadama2 and general example workflow (python executable + R executable + data table + PDF generation task)
 ```
python3 run.py
 ```

### Anadama2 running metaphlan from scratch for multiple sample
```
python3 run_metaphlan_workflow.py
```

### Anadama2 running metaphlan from scratch in cluster
- Change `add_task` to `add_task_gridable` in the workflow code.
```
python3 run_metaphlan_workflow_grid.py --grid-jobs 2

#To run this workflow and change the time, memory, and cores (increasing all 2x) for the named task task1, run:
python3 run_metaphlan_workflow_grid.py --grid-jobs 2 --grid-tasks="task1,4,40,2"
```

### Anadama2 - making modification of existing biobakery workflows
- Note: Please Make any parameter changes to the biobakery workflows with **CAUTION**
- Note: Making code changes to biobakery_workflows is not recommended 