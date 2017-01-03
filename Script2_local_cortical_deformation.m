%% Script 2. This script calculates local cortical deformation
%Run this script on patients and controls.
clear all
%change to appropriate subjects_dir
SUBJECTS_DIR = '~/Desktop/Sophie_study/FCD_study/'
cd(SUBJECTS_DIR)

%setting up environment and libraries
setenv SUBJECTS_DIR .
addpath /Applications/freesurfer/matlab/

%get list of subjects (here all subjects begin with FCD_)
subs=dir('FCD_*');


for s=1:length(subs)
    %get subject name
    sub=subs(s).name

% for each hemisphere
for h={'lh','rh'}
    clear f p F P
%cell2mat converts hemisphere from cell to a string for subsequent use
    hemi=cell2mat(h);
    %Load in curvature
Curvature=read_curv(['',sub,'/surf/',hemi,'.pial.K.crv']);
%Filter and modulus intrinsic curvature
%Values above 2 are probably noise
Curvature=abs(Curvature);
Curvature(Curvature>2)=0;
%Load in an example .mgh structure which is used to save out result
 lh=MRIread(['',sub,'/surf/',hemi,'.w-g.pct.mgh']);
 lh.vol(:)=Curvature;
 %Optional save out filtered curvature as mgh in case needs checking
%MRIwrite(lh, ['',sub,'/surf/',hemi,'.AbsoluteK.mgh'])
Intensity=lh.vol';

%Load in inflated surface coordinates
Inflated=read_surf(['',sub,'/surf/',hemi,'.inflated']);
Inflatedx=Inflated(:,1);
Inflatedy=Inflated(:,2);
Inflatedz=Inflated(:,3);

%Load in cortex label to mask out medial wall
Cortex=read_label(['',sub,''],['',hemi,'.cortex']);
Cortex=Cortex(:,1)+1;

 
for i=1:length(Inflated);
    Centre=Inflated(i,:);
    %For each vertex find distance to all other vertices 
    Diff=sqrt((Inflatedx-Centre(1,1)).^2+(Inflatedy-Centre(1,2)).^2+(Inflatedz-Centre(1,3)).^2);
   
    %Find vertices within 25 mm of central vertex
Circle=find(Diff(:)<25);
CortexCircle=intersect(Circle,Cortex);
%Calculate total intrinsic curvature inside disc
CurvatureD(i,1)=sum(Curvature(CortexCircle));

% If you want to normalise LCD by the number of vertices in the 25mm Circle
% comment out the line above and use this line instead:
%CurvatureD(i,1)=sum(Curvature(CortexCircle))/length(CortexCircle);
end

%load in example mgh strucutre
lh=MRIread(['',sub,'/surf/',hemi,'.w-g.pct.mgh']);
lh.vol(1:end)=0;
lh.vol(Cortex)=CurvatureD(Cortex);
%Save LCD  
MRIwrite(lh, ['',sub,'/surf/',hemi,'.LCD.mgh'])
end
end
