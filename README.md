# Python on Frotnier 

In high-performance computing, Python is heavily used to analyze scientific data on the system.
OLCF has a "Python on OLCF Systems" guide within the software guide. To find it, go to [https://docs.olcf.ornl.gov](https://docs.olcf.ornl.gov)> Software> Python on OLCF Systems. [Link](https://docs.olcf.ornl.gov/software/python/index.html#python-on-olcf-systems).

It tells you how to load the latest versions of python, manage your environment and run python on Frontier and Andes.

Goals:

## Basic Python Hands-on (Suzanne)

* Create a new virtual environment using conda
* Install mpi4py from source
* Test our build with a Python script

## Setting up the environment

### Base Environment

Loading a module sets up a base python environment on each of our systems. Custom packages like numpy and scipy are not included in the base environment on most of our resources. We are going to use the "Python on OLCF Systems" guide for this exercise.

Go to docs.olcf.ornl.gov> Software> [Python on OLCF Systems Base Environments](https://docs.olcf.ornl.gov/software/python/index.html#base-environment).

Select the tab for the resource you are on and follow the instructions to list the packages. If you are using Odo follow the Frontier instructions.

For example, for Frontier/Odo you would do.

```
$ module load miniforge3/23.11.0
$ conda list
```
### Setting up a Custom Environment

Suppose you want to install the `numpy` package. If you do that in your base environment, it could get messy as you install more packages. It is a best practice to setup a custom environment that contains consistent versions of all the packages you use for each particular project.

This next hands-on walks you through setting up a custom environment that we will use later in the training.

For your future refrence, open a new browser tab or window and direct it to [https://docs.olcf.ornl.gov/software/python/index.html#custom-environments](https://docs.olcf.ornl.gov/software/python/index.html#base-environment). You will see tabs under "To create and activate an environment:" that have instructions for creating custom enviroments on each of our resouces.

For this exercise we will create a custom environment called *mpi4py_env* in your /ccs/proj/<<your_project_id>>. If you are on Odo, you will use /ccsopen/proj/<<your_project_id>>.


For example on Frontier:


Next, we will load the gnu compiler module (most Python packages assume GCC):

```bash
$ module load PrgEnv-gnu
$ module load miniforge3
```

We are in a "base" conda environment, but we need to create a new environment using the `conda create` command.
It is highly recommended to create new environments in the "Project Home" directory (on Frontier, this is /ccs/proj/<YOUR_PROJECT_ID>/<YOUR_USER_ID>). This space avoids purges and allows for potential collaboration within your project.
```
$ conda create -p /ccs/proj/<<your_project_id>>/<<your_user_id>>/.conda/mpi4py_env_frontier python=3.10.13
modl```

The "-p" flag specifies the desired path and name of your new virtual environment. The directory structure is case sensitive, so be sure to insert "<your_project_id>" ad as lowercase. Directories will be created if they do not exist already (provided you have write-access in that location).


A Note on Organization:
I chose to create a `.conda` directory to keep my Python environments organized and separate from a plain directory listing. Within `.conda`, I created a `frontier` subdirectory to store all my environments specifically for Frontier. While both Frontier and Andes mount the home and project areas, an environment built for one machine cannot be assumed to work seamlessly on the other, so it is important to have an orgaization strucutre for your python envoriments from the start.


After following the prompts for creating your new environment, the installation should be successful, and you will see something similar to:

```

Preparing transaction: done
Verifying transaction: done
Executing transaction: done
#
# To activate this environment, use
#
#     $ conda activate /ccs/proj/stf007/suzanne/.conda/frontier/mpi4py_env     
#
# To deactivate an active environment, use
#
#     $ conda deactivate
```

Due to the specific nature of conda on Frontier, we will be using `source activate` instead of `conda activate` to activate our new environment:

```bash
$ source activate /ccs/proj/stf007/suzanne/.conda/frontier/mpi4py_env
```

The path to the environment should now be displayed in "( )" at the beginning of your terminal lines, which indicate that you are currently using that specific conda environment.
If you check with `conda env list`, you should see that the `*` marker is next to your new environment, which means that it is currently active:

```bash
$ conda env list

# conda environments:
#
base                     /autofs/nccs-svm1_sw/frontier/miniforge3/23.11.0
                      *  /ccs/proj/stf007/suzanne/.conda/frontier/mpi4py_env
```


## Installing mpi4py

Now that we have a fresh conda environment, we will next install mpi4py from source into our new environment.
To make sure that we are building from source, and not a pre-compiled binary, we will be using pip:

```bash
$ MPICC="cc -shared" pip install --no-cache-dir --no-binary=mpi4py mpi4py
```

* The `MPICC` flag ensures that you are using the correct C wrapper for MPI on the system.
* -shared tells the compiler to produce a shared object (dynamic library) instead of an executable.
* --no-cache-dir: Prevents pip from using or storing cached packages, forcing a fresh download and build.
* --no-binary=mpi4py: Ensures that mpi4py is built from source instead of using a pre-compiled binary. This is important for compatibility with the specific MPI implementation on the system.

Building from source typically takes longer than a simple `conda install`, so the download and installation may take a couple minutes.
If everything goes well, you should see a "Successfully installed mpi4py" message.

## Running with Python 

To test the mpi4py we just installed in the exercise above, we will use an example Python script called "hello_mpi.py".

To do so, we will be submitting a job to the batch queue with "submit_hello.sbatch":

This part of the hands-on covers the (How to Run)[https://docs.olcf.ornl.gov/software/python/index.html#how-to-run] section of the Python on OLCF system Guide. 

The example below is for Frontier, but if you are using Andes or Odo you can use the guide linked above to understand how to ajust the commands accordingly. 


To get to this script 

```
cd python_hands-on. 

```

On Frontier and Andes, you are already on a compute node once you are in a batch job. Therefore, you only need to use srun if you plan to run parallel-enabled Python, and you do not need to specify srun if you are running a serial application.

$PATH issues are known to occur if not submitting from a fresh login shell, which can result in the wrong environment being detected. To avoid this, you must use the --export=NONE flag during job submission and use unset SLURM_EXPORT_ENV in your job script (before calling srun), which ensures that no previously set environment variables are passed into the batch job, but makes sure that srun can still find your python path:

```bash
$ sbatch --export=NONE submit_hello.sbatch
```

This means you will have to load your modules and activate your environment inside the batch script. An example batch script for is provided below:

```
#!/bin/bash
#SBATCH -A <your_project_id_here>
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
```

Open the submit_hello.sbatch 
```
vi submit_hello.sbatch 

```
* Edit the second like after -A to your project ID
* Note the `unset SLURM_EXPORT_ENV` line 
* Note the lines that relaod modules
* Edit the source activate line to activate the mpi4p_env we created together. 
* close and save the file. 

To submit the batch script: 
```
sbatch --export=NONE submit_hello.sbatchsubmit_hello.sbatch
``

Once the batch job makes its way through the queue, it will run the "hello_mpi.py" script with 42 MPI tasks.
If mpi4py is working properly, in `mpi4py-<JOB_ID>.out` you should see output similar to:

```
Hello from MPI rank 21 !
Hello from MPI rank 23 !
Hello from MPI rank 28 !
Hello from MPI rank 40 !
Hello from MPI rank 0 !
Hello from MPI rank 1 !
Hello from MPI rank 32 !

Congratulations! You have the tools and knowledge you need to user python on Frontier! 
# using_python_olcf
