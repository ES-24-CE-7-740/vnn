#!/bin/bash

#SBATCH --job-name=vnn_seg_train
#SBATCH --time=11:30:00
#SBATCH --signal=B:SIGTERM@30
#SBATCH --signal=SIGTERM@60
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G

#####################################################################################

# tweak this to fit your needs
max_restarts=3

# Fetch the current restarts value from the job context
scontext=$(scontrol show job ${SLURM_JOB_ID})
restarts=$(echo ${scontext} | grep -o 'Restarts=[0-9]*' | cut -d= -f2)

# If no restarts found, it's the first run, so set restarts to 0
iteration=${restarts:-0}

# Dynamically set output and error filenames using job ID and iteration
outfile="${SLURM_JOB_ID}_${iteration}.out"
errfile="${SLURM_JOB_ID}_${iteration}.err"

# Print the filenames for debugging
echo "Output file: ${outfile}"
echo "Error file: ${errfile}"

##  Define a term-handler function to be executed           ##
##  when the job gets the SIGTERM (before timeout)          ##

term_handler()
{
    echo "Executing term handler at $(date)"
    if [[ $restarts -lt $max_restarts ]]; then
        # Requeue the job, allowing it to restart with incremented iteration
        scontrol requeue ${SLURM_JOB_ID}
        exit 0
    else
        echo "Maximum restarts reached, exiting."
        exit 1
    fi
}

# Trap SIGTERM to execute the term_handler when the job gets terminated
trap 'term_handler' SIGTERM

#######################################################################################

# Use srun to dynamically specify the output and error files
srun --output="${outfile}" --error="${errfile}" \
	singularity exec --nv --bind /ceph:/ceph \
	/ceph/project/ce-7-740/containers/vnn.sif \
        python train_partseg_modded.py --model vn_dgcnn_partseg --rot aligned \
	--log_dir vn_dgcnn/aligned/ --epoch=250 --batch_size=16 --optimizer='Adam' \
	--gpu='5'
