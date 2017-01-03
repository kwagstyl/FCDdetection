% This script converts a freesurfer label into a .mgh surface file

clear all
% Directory of patients - change to appropriate
cd ~/Desktop/Sophie_study/FCD_study_with_FLAIR/FreeSurfer/
addpath /Applications/freesurfer/matlab
setenv SUBJECTS_DIR .

% List of patients / controls
subs={ 'FCD_16';'FCD_01'};

% Loop through subjects
for s=1:length(subs);
    %sub=subs(s).name
   sub=cell2mat(subs(s));
   
   
   % If lesion is on left hemisphere
    if exist(['',sub,'/label/lh.lesion_2.label'])
        h1='lh';
        h2='rh';
        Lesion=read_label(['',sub,''],['',h1,'.lesion_2']);
      
        % must add 1 as Matlab labeling is from 1 whereas FreeSurfer
        % labeling is from 0
    Lesion=Lesion(:,1)+1;
        
    % load example mgh structure
       NT=MRIread(['',sub,'/surf/',h1,'.thickness_z.sm10.mgh']);
    % write lesion label data into structure   
       NT.vol(:)=0;
       NT.vol(Lesion)=1;
    % save lesion label   
       MRIwrite(NT,['',sub,'/surf/',h1,'.lesion_2.mgh']);
       
       % If lesion is on right hemisphere
    elseif exist(['',sub,'/label/rh.lesion_2.label'])
        h1='rh';
        h2='lh';
   
      Lesion=read_label(['',sub,''],['',h1,'.lesion_2']);
      
    Lesion=Lesion(:,1)+1;
    
       NT=MRIread(['',sub,'/surf/',h1,'.thickness_z.sm10.mgh']);
       
       NT.vol(:)=0;
       NT.vol(Lesion)=1;
       
       MRIwrite(NT,['',sub,'/surf/',h1,'.lesion_2.mgh']);
     else
    end   
end
