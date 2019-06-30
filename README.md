# Brain State Project

Compute transient brain states within resting state fMRI data using k-means clustering.

This package is currently a work in progress. The main functionalities can all be accessed using `Scripts/k_wrapper.sh`. Once initiated, it will prompt the user to perform one of five different operations, which can be selected by entering in the corresponding number:
1. Compute group-specific ROIs using an ICA analysis (subj or group).
  ROIs = "Regions Of Interest"
  This can be done on either a group of subjects or for a single subject. 
2. Compute sliding time windows for a set of ROIs (subj or group).
  This can be done on either a group of subjects or for a single subject. 
  The user will be prompted to indicate the directory containing ROI mask files, which must be provided in order to compute the sliding time windows of activation across the entire brain. These ROIs must be in the same brain space as the MRI data being analyzed.
3. Compute brain states (subj or group).
  This can be done on either a group of subjects or for a single subject. 
  K-means clustering is used on the sliding time windows in order to identify individual brain states the subject(s) enters while at rest. Currently the number of brain states to be computed (k) must be entered manually. In a future release there will be an option to automatically compute the optimal number of brain states to be used to best capture the dynamic repertoire of brain activity over time.
4. Find relations between frequency of brain states and behavioural performance.
  *Not currently functioning*
  This will identify the brain states that most closely resemble task-based activation patterns. This will require the user to input task-based brain activation maps in order to find states whose spatial activation patterns most closely resemble it. Brain states will be ranked from most- to least-similar.
5. Perform a whole-brain PPI to find FC patterns associated with behavioural performance.
  This function will only work for task-based fMRI data, due tp the nature of psychophysiological interaction (PPI) analyses (see https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PPI for an overview). It will go through each ROI provided and compute a seperate PPI statistical parametric map, which will then be used as a column in a task-based functional connectivity matrix. This will provide a whole-brain overview of task-dependent functional connectivity. Like task-based activation maps, these maps can also be entered into step 4 to find brain states whose functional connectivity most resembles the identified task-based FC patterns. Please not that because each PPI is an independent GLM-based analysis, there is a greater risk of Type-1 Error with this step.
