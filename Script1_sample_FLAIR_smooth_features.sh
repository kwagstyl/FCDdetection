########################### SCRIPT 1 ###################################################
# This script can be run after FreeSurfer reconstructions have been manually checked and edited where necessary
# It does the following:
# 1. Sample FLAIR at 25%, 50%, 75% of the cortical thickness, at the grey-white matter boundary, and 0.5mm and 1mm subcortically
# 2. Smooth the following features using a 10mm gaussian kernel:
# - cortical thickness
# - FLAIR at 25%, 50%, 75% of the cortical thickness, at the grey-white matter boundary, and 0.5mm and 1mm subcortically
# - grey-white matter intensity contrast
# 3. Calculate curvature for use in script 2 - calculation of local cortical deformation
# 4. Convert curvature and sulcal depth and lgi to .mgh file type

##This script needs to be run on all patients and all controls
## Change to your subjects directory ##
subjects_dir = "~/Desktop/FCD_study/"
cd "$subjects_dir"

## Change to list your subjects
sub = "FCD_01 FCD_02 FCD_03 FCD_04"

# for each subject do the following
for s in $sub
do

# creates Identidy.dat - a transormation matrix required for sampling intensities with surfaces. In this case an identity matrix as volumes are already coregistered
bbregister --s "$s" --mov "$s" --mov "$s"/mri/brainmask.mgz --reg "$s"/mri/transforms/Identity.dat --init-fsl --t1

H = "lh rh"
#for each hemisphere
for h in $H
do

# Sample FLAIR at 25%, 50%, 75% of the cortical thickness & at the grey-white matter boundary & smooth using 10mm Gaussian kernel

D = "0.5 0.25 0.75 0"
for d in $D
do

#sampling volume to surface
mri_vol2surf --src "$s"/mri/FLAIR.mgz --out "$s"/surf/"$h".gm_FLAIR_"$d".mgh --hemi "$h" --projfrac "$d" --srcreg "$s"/mri/transforms/Identity.dat --trgsubject "$s" --surf white

#smoothing
mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".gm_FLAIR_"$d".mgh --o "$s"/surf/"$h".gm_FLAIR_"$d".sm10.mgh

done

# Sample FLAIR 0.5mm and 1mm subcortically & smooth using 10mm Gaussian kernel
D_wm = "0.5 1"

for d_wm in $D_wm
do

mri_vol2surf --src "$s"/mri/FLAIR.mgz --out "$s"/surf/"$h".wm_FLAIR_"$d_wm".mgh --hemi "$h" --projdist -"$d_wm" --srcreg "$s"/mri/transforms/Identity.dat --trgsubject "$s" --surf white

mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".wm_FLAIR_"$d_wm".mgh --o "$s"/surf/"$h".wm_FLAIR_"$d_wm".sm10.mgh

done

# Smooth cortical thickness and grey white matter intensity contrast

mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".thickness --o "$s"/surf/"$h".thickness.sm10.mgh

mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".w-g.pct.mgh --o "$s"/surf/"$h".w-g.pct.sm10.mgh

mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 5\
 --i "$s"/surf/"$h".w-g.pct.mgh --o "$s"/surf/"$h".w-g.pct.sm5.mgh

# Calculate curvature 

mris_curvature_stats -f white -g --writeCurvatureFiles "$s" "$h" curv 
mris_curvature_stats -f pial -g --writeCurvatureFiles "$s" "$h" curv

# Convert mean curvature and sulcal depth to .mgh file type

mris_convert -c "$s"/surf/"$h".curv "$s"/surf/"$h".white "$s"/surf/"$h".curv.mgh
mris_convert -c "$s"/surf/"$h".sulc "$s"/surf/"$h".white "$s"/surf/"$h".sulc.mgh

done
done



