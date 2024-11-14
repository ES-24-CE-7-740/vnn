#!/bin/bash
#SBATCH --job-name=vnn_train
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=vnn_train_%j.out
#SBATCH --error=vnn_train_%j.err

# Set the number of tasks and GPUs directly
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1

# Execute the job using Singularity
srun singularity exec --nv --bind /ceph:/ceph /ceph/project/ce-7-740/containers/vnn.sif \
	python train_cls.py \
	--model vn_dgcnn_cls \
	--rot aligned \
	--log_dir vn_dgcnn/aligned/
	--epoch=50
