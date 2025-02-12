#!/bin/bash
#SBATCH -A stf007
#SBATCH -J mpi4py
#SBATCH -o %x-%j.out
#SBATCH -t 0:10:00
#SBATCH -p batch
#SBATCH -N 1

unset SLURM_EXPORT_ENV

date

module load PrgEnv-gnu
module load miniforge3

source activate /ccs/proj/stf007/suzanne/mpi4py_env_frontier

srun -n42 python3 -u hello_mpi.py
