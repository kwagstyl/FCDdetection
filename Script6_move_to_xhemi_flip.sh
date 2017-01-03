###################### SCRIPT 6#######################
# This script Moves features to fsaverage_sym - a bilaterally symmetrical template
# Then it calculates interhemsipheric asymmetry
# It also moves the manual lesion label to fsaverage_sym
##Run on all patients and controls

## Change to your subjects directory ##
subjects_dir = "~/Desktop/FCD_study/"
cd "$subjects_dir"

## Change to list your subjects
sub = "FCD_01 FCD_02 FCD_03 FCD_04"

Measures = "thickness w-g.pct
      Doughnut_thickness_6 Doughnut_intensity_contrast_6
      Doughnut_FLAIR_0_6 Doughnut_FLAIR_0.25_6 
      Doughnut_FLAIR_0.5_6 Doughnut_FLAIR_0.75_6
      Doughnut_FLAIR_wm_0.5_6 Doughnut_FLAIR_wm_1_6
      LCD gm_FLAIR_0 gm_FLAIR_0.25 gm_FLAIR_0.5
      gm_FLAIR_0.75 wm_FLAIR_0.5 wm_FLAIR_1"

#These measures are done separately as they are not smoothed or z scored.
Measures2 = "curv sulc"

for s in $sub
do

for m in $Measures
do

# Move onto left hemisphere
mris_apply_reg --src  "$s"/surf/lh."$m"_z.sm10.mgh --trg "$s"/xhemi/surf/lh."$m"_z_on_lh.sm10.mgh  --streg $SUBJECTS_DIR/"$s"/surf/lh.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
mris_apply_reg --src "$s"/surf/rh."$m"_z.sm10.mgh --trg "$s"/xhemi/surf/rh."$m"_z_on_lh.sm10.mgh    --streg $SUBJECTS_DIR/"$s"/xhemi/surf/lh.fsaverage_sym.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg

# Calculate interhemispheric asymmetry
mris_calc --output "$s"/xhemi/surf/lh.lh-rh."$m"_z.sm10.mgh "$s"/xhemi/surf/lh."$m"_z_on_lh.sm10.mgh sub "$s"/xhemi/surf/rh."$m"_z_on_lh.sm10.mgh

done

for m2 in $Measures2
do

# Move onto left hemisphere
mris_apply_reg --src  "$s"/surf/lh."$m2".mgh --trg "$s"/xhemi/surf/lh."$m2".mgh  --streg $SUBJECTS_DIR/"$s"/surf/lh.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
mris_apply_reg --src "$s"/surf/rh."$m2".mgh --trg "$s"/xhemi/surf/rh."$m2".mgh    --streg $SUBJECTS_DIR/"$s"/xhemi/surf/lh.fsaverage_sym.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
# Asymmetry
mris_calc --output "$s"/xhemi/surf/lh.lh-rh."$m2".mgh "$s"/xhemi/surf/lh."$m2".mgh sub "$s"/xhemi/surf/rh."$m2".mgh

done


# Move lesion Label
# Move onto left hemisphere
mris_apply_reg --src  "$s"/surf/lh.lesion.mgh --trg "$s"/xhemi/surf/lh.lesion_on_lh.mgh  --streg $SUBJECTS_DIR/"$s"/surf/lh.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
mris_apply_reg --src "$s"/surf/rh.lesion.mgh --trg "$s"/xhemi/surf/rh.lesion_on_lh.mgh   --streg $SUBJECTS_DIR/"$s"/xhemi/surf/lh.fsaverage_sym.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg

done
