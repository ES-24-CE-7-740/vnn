#!/bin/bash
#SBATCH --job-name=vnn_test
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=vnn_test_%j.out
#SBATCH --error=vnn_test_%j.err

# Set the number of tasks and GPUs directly
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1

# Execute the job using Singularity
srun singularity exec --nv --bind /ceph:/ceph /ceph/project/ce-7-740/containers/vnn.sif \
	python test_cls.py \
	--model vn_dgcnn_cls \
	--rot so3 \
	--log_dir vn_dgcnn/aligned/

