########################### SCRIPT 4 ###################################################
# This script can be run after local cortical deformation and doughnut measures have been calculated
#Run on patients and controls. There will be some errors for controls who don’t have or need doughnut measures. Just ignore these.

# It does the following:
# 1. Smooth LCD and Doughnut measures

## Change to your subjects direction ##
subjects_dir = "~/Desktop/FCD_study/"
cd "$subjects_dir"

## Change to list your subjects
sub = "FCD_01 FCD_02 FCD_03 FCD_04"

## Insert radius used for Doughnut measures;
r = "6"

# For each subject
for s in $sub
do

# For each hemisphere
H = "lh rh"

for h in $H
do

# Smooth LCD
mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".LCD.mgh --o "$s"/surf/"$h".LCD.sm10.mgh

# Smooth Doughnut measures
mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".Doughnut_FLAIR_0_"$r".mgh --o "$s"/surf/"$h".Doughnut_FLAIR_0_"$r".sm10.mgh

mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".Doughnut_FLAIR_0.25_"$r".mgh --o "$s"/surf/"$h".Doughnut_FLAIR_0.25_"$r".sm10.mgh

mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".Doughnut_FLAIR_0.5_"$r".mgh --o "$s"/surf/"$h".Doughnut_FLAIR_0.5_"$r".sm10.mgh

mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".Doughnut_FLAIR_0.75_"$r".mgh --o "$s"/surf/"$h".Doughnut_FLAIR_0.75_"$r".sm10.mgh

mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".Doughnut_wm_FLAIR_0.5_"$r".mgh --o "$s"/surf/"$h".Doughnut_wm_FLAIR_0.5_"$r".sm10.mgh

mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".Doughnut_wm_FLAIR_1_"$r".mgh --o "$s"/surf/"$h".Doughnut_wm_FLAIR_1_"$r".sm10.mgh

mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".Doughnut_thickness_"$r".mgh --o "$s"/surf/"$h".Doughnut_thickness_"$r".sm10.mgh

mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
 --i "$s"/surf/"$h".Doughnut_intensity_contrast_"$r".mgh --o "$s"/surf/"$h".Doughnut_intensity_contrast_"$r".sm10.mgh


done
done


