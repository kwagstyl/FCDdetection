# FCDdetection
The following scripts accompany the publication: 
"Novel surface features for automated detection of focal cortical dysplasias in paediatric epilepsy."
http://dx.doi.org/10.1016/j.nicl.2016.12.030
Briefly, the scripts calculate surface-based structural MRI features from cortical reconstructions and use these
data to train a supervised neural network classifier to identify lesion-like vertices. In the sample used, the leave-one-out classifier
was able to correctly identify FCDs in 73% of patients.

Please send any queries to kw350@cam.ac.uk or sophie.adler.13@ucl.ac.uk.

The original scans could not be shared publicly, but the matrix of subjects morphological data, along with lesion/non-lesion labelling of each
vertex can be freely downloaded from:
https://doi.org/10.17863/CAM.6923

The scripts are numbered 1-10
Pre-script steps:

1. You need to have FreeSurfer cortical reconstructions of all your participants (https://surfer.nmr.mgh.harvard.edu/). 
It is important that these are checked and edits are done to correct the surfaces.

- it is important to check that the FLAIR scan is correctly coregistered to the T1 scan and therefore to the surfaces. 

- With volumetric FLAIR, the recon-all process included the FLAIR scan. 
If volumetric FLAIR is unavailable, supplementary script 1 will coregister the FLAIR scan after the recon-all step (Supplementary_script_1).
Further analyses need to be made to assess whether non-volumetric FLAIR is sufficient.


2. Create manual lesion labels of the FCDs. 

- this can be done in FreeSurfer

- after creating the labels, they need to be converted to .mgh files for compatibility with the rest of the scripts (see Supplementary_script_2).


Script 1: This script does the following

1. Sample FLAIR at 25%, 50%, 75% of the cortical thickness, at the grey-white matter boundary, and 0.5mm and 1mm subcortically
2. Smooth the following features using a 10mm gaussian kernel:
 - cortical thickness
 - FLAIR at 25%, 50%, 75% of the cortical thickness, at the grey-white matter boundary, and 0.5mm and 1mm subcortically
 - grey-white matter intensity contrast
3. Calculate curvature for use in script 2 - calculation of local cortical deformation
4. Convert curvature and sulcal depth and lgi to .mgh file type

Script 2: This script calculates local cortical deformation

Script 3: This script calculates the Doughnut method

Script 4: Smoothing of local cortical deformation and doughnut metrics

Script 5: Intra-subject normalisation of features

Script 6: Move features to template space (this involves flipping the right hemisphere features so that everything is moved to the left hemisphere)

Script 7: Inter-subject normalisation of features for the classifier

Script 8: Neural Network classifier (including principal component analysis for determining number of nodes in classifier)

Script 9: Clustering of classifier output

Script 10: Ranking of top 5 clusters
