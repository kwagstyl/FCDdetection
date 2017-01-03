%% Script 3. Doughnut method
%This script is run on patients only
clear all
%change to correct subject directory
SUBJECTS_DIR = '~/Desktop/Sophie_study/FCD_study/'
cd(SUBJECTS_DIR)
%set environment and freesurfer matlab library
setenv SUBJECTS_DIR .
addpath /Applications/freesurfer/matlab/

%replace with appropriate prefix. All subjects in our directory start with
%FCD_*
Subs=dir('FCD_*');

subs=cell(length(Subs),1);
for s = 1:length(Subs);
    subs{s}=Subs(s).name;
end

% List any subjects who are excluded eg did not pass quality control.
Remove={'FCD_05'; 'FCD_14';};
ind=find(ismember(subs,Remove));
subs(ind)=[];

for s=1:length(subs)
    sub=subs(s)
    %sub=subs(s).name
    sub=cell2mat(sub)
   cd(sub)
   
% for each hemisphere;
for h={'rh','lh'}
    clear f p F P
%cell2mat is a command necessary to make hemi work in the line below
    hemi=cell2mat(h);

% Load inflated surface
Inflated=read_surf(['surf/',hemi,'.inflated']);
Inflatedx=Inflated(:,1);
Inflatedy=Inflated(:,2);
Inflatedz=Inflated(:,3);


%Load surface data
 
% FLAIR measures
    lh=MRIread(['surf/',hemi,'.gm_FLAIR_0.25.mgh']);
    FLAIR_0=lh.vol;
    lh=MRIread(['surf/',hemi,'.gm_FLAIR_0.75.mgh']);
    FLAIR_025=lh.vol;
    lh=MRIread(['surf/',hemi,'.gm_FLAIR_0.mgh']);
    FLAIR_05=lh.vol;
    lh=MRIread(['surf/',hemi,'.gm_FLAIR_0.5.mgh']);
    FLAIR_075=lh.vol;
    lh=MRIread(['surf/',hemi,'.wm_FLAIR_0.5.mgh']);
    wm_FLAIR_05=lh.vol;
    lh=MRIread(['surf/',hemi,'.wm_FLAIR_1.mgh']);
    wm_FLAIR_1=lh.vol;
    
% Load thickness and grey-white matter intensity contrast
    lh=MRIread(['surf/',hemi,'.thickness']);
    thick=lh.vol; 
    lh=MRIread(['surf/',hemi,'.w-g.pct.sm5.mgh']);
    gmwm=lh.vol;


% Choose the radius of the circle - e.g. 2mm, 4mm, 6mm ,8mm ,10mm 
for r=6 % 6mm radius    

% Calculate radius of Doughnut    
R=sqrt(2)*r;
h=zeros(length(Inflated),1);
p=h;

% Calculate Doughnut measure per vertex
for i=1:length(Inflated);
    Centre=Inflated(i,:);
    Diff=sqrt((Inflatedx-Centre(1,1)).^2+(Inflatedy-Centre(1,2)).^2+(Inflatedz-Centre(1,3)).^2);
    Donut=find(Diff(:)<R);
    Circle=find(Diff(:)<r);
    Donut=setdiff(Donut,Circle);
    
% FLAIR intensity in circle and doughnut
CircleFLAIR_0=FLAIR_0(Circle);
DonutFLAIR_0=FLAIR_0(Donut);
CircleFLAIR_025=FLAIR_025(Circle);
DonutFLAIR_025=FLAIR_025(Donut);
CircleFLAIR_05=FLAIR_05(Circle);
DonutFLAIR_05=FLAIR_05(Donut);
CircleFLAIR_075=FLAIR_075(Circle);
DonutFLAIR_075=FLAIR_075(Donut);
Circlewm_FLAIR_05=wm_FLAIR_05(Circle);
Donutwm_FLAIR_05=wm_FLAIR_05(Donut);
Circlewm_FLAIR_1=wm_FLAIR_1(Circle);
Donutwm_FLAIR_1=wm_FLAIR_1(Donut);
    
% Thickness / grey-white matter contrast in circle and doughnut
Circlethick=thick(Circle);
Donutthick=thick(Donut);
Circlegmwm=gmwm(Circle);
Donutgmwm=gmwm(Donut);

% ttest between FLAIR intensities in circle and doughnut
[h(i,1),p(i,1)]=ttest2(CircleFLAIR_0,DonutFLAIR_0);
[e(i,1),f(i,1)]=ttest2(CircleFLAIR_025,DonutFLAIR_025);
[g(i,1),q(i,1)]=ttest2(CircleFLAIR_05,DonutFLAIR_05);
[u(i,1),v(i,1)]=ttest2(CircleFLAIR_075,DonutFLAIR_075);
[w(i,1),x(i,1)]=ttest2(Circlewm_FLAIR_05,Donutwm_FLAIR_05);
[y(i,1),z(i,1)]=ttest2(Circlewm_FLAIR_1,Donutwm_FLAIR_1);

% ttest between thickness / grey-white matter intensity contrast in circle and doughnut
[b(i,1),c(i,1)]=ttest2(Circlethick,Donutthick);
[a(i,1),d(i,1)]=ttest2(Circlegmwm,Donutgmwm);
end

% Log of pvalues
P=abs(log(p));
F=abs(log(f));
Q=abs(log(q));
V=abs(log(v));
X=abs(log(x));
Z=abs(log(z));
C=abs(log(c));
D=abs(log(d));
%load any .mgh file as example structure
lh=MRIread(['surf/',hemi,'.w-g.pct.mgh']);
lh.vol(1:end)=0;

% Radius of Doughnut
hr=num2str(r);

% Write out Doughnut measures
lh.vol(:)=P;
MRIwrite(lh, ['surf/',hemi,'.Doughnut_FLAIR_0_',hr,'.mgh'])
lh.vol(:)=F;
MRIwrite(lh, ['surf/',hemi,'.Doughnut_FLAIR_0.25_',hr,'.mgh'])
lh.vol(:)=Q;
MRIwrite(lh, ['surf/',hemi,'.Doughnut_FLAIR_0.5_',hr,'.mgh'])
lh.vol(:)=V;
MRIwrite(lh, ['surf/',hemi,'.Doughnut_FLAIR_0.75_',hr,'.mgh'])
lh.vol(:)=X;
MRIwrite(lh, ['surf/',hemi,'.Doughnut_wm_FLAIR_0.5_',hr,'.mgh'])
lh.vol(:)=Z;
MRIwrite(lh, ['surf/',hemi,'.Doughnut_wm_FLAIR_1_',hr,'.mgh'])
lh.vol(:)=C;
MRIwrite(lh, ['surf/',hemi,'.Doughnut_thickness_',hr,'.mgh']) 
lh.vol(:)=D;
MRIwrite(lh, ['surf/',hemi,'.Doughnut_intensity_contrast_',hr,'.mgh'])

clear P F Q V X Z p f q v x z A B C D a b c d 

end
end
cd ..

end
