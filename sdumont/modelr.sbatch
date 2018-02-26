#!/bin/sh

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH -p cpu_dev
#SBATCH -J modelr
#SBATCH --exclusive

module load R/3.3.1_intel
source /scratch/app/modulos/intel-psxe-2016.2.062.sh
module load openmpi/1.10_intel

export R_LIBS_USER='/scratch/ebiodiv/guilherme.gall/R'

export LD_LIBRARY_PATH="/scratch/ebiodiv/guilherme.gall/geos/lib:$LD_LIBRARY_PATH"
export PATH="/scratch/ebiodiv/guilherme.gall/geos/bin:$PATH"

module load gdal/2.1.2
module load proj-4/9.3
module load java/jdk-8u102
export JAVA_HOME="/scratch/app/java/jdk1.8.0_102/jre"
export JAVA="/scratch/app/java/jdk1.8.0_102/jre/bin/java"
export JAVAC="/scratch/app/java/jdk1.8.0_102/bin/javac"
export JAVAH="/scratch/app/java/jdk1.8.0_102/bin/javah"
export JAR="/scratch/app/java/jdk1.8.0_102/bin/jar"
export JAVA_INCLUDE_DIR=/scratch/app/java/jdk1.8.0_102/include
export JAVA_LD_LIBRARY_PATH=/scratch/app/java/jdk1.8.0_102/lib

${PWD}/modelr.R
