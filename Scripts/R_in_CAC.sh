#!/bin/bash
#$ -S /bin/bash
#$ -q abaqus.q
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be

rscript=$1

Rscript $rscript