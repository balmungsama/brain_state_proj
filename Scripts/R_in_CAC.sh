#!/bin/bash
#$ -S /bin/bash
#$ -q abaqus.q
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -o /home/hpc3586/brain_state_proj/Scripts/k_logs/STD.out
#$ -e /home/hpc3586/brain_state_proj/Scripts/k_logs/STD.err


rscript=$1

Rscript $rscript