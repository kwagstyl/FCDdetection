%% Script 8. Neural Network Classifier
clear all

% Directory of patients
subjects_dir = '~/Desktop/Sophie_study/FCD_study/'
cd(subjects_dir)

setenv SUBJECTS_DIR .
addpath /Applications/freesurfer/matlab/

%change to appropriate prefix
Subs=dir('FCD_*');

subs=cell(length(Subs),1);
for s = 1:length(Subs);
    subs{s}=Subs(s).name;
end

% List of patients to be excluded
Remove={'FCD_05'; 'FCD_14';};
ind=find(ismember(subs,Remove));
subs(ind)=[];



%% load in cortex label left hemi, +1 for freesurfer-matlab indexing
 Cortex=read_label(['fsaverage_sym'],['lh.cortex']);
 Cortex=Cortex(:,1)+1;  
%%Start subjects loop - leave one out classifier - removes Test Subject so
%%that classifier is not trained on this data

for TestNumber=1:length(subs);
TestSubject=cell2mat(subs(TestNumber))
%outputs to be stored in:
mkdir(['',TestSubject,'/xhemi/classifier'])
%Find index of test subject and omit from training set
ind=find(ismember(subs,TestSubject));
%Subjects list minus test subject
subset=subs;
subset(ind)=[];
%create empty variables multi - contains input 
%variables for each subject & vertex  and
%score - identifies lesional and non lesional rows (vertices) in multi
Multi=[];
Score=[];

%MEASURES
% This is the set of measures you want to include in your classifier

All=1:28;
NoSulc=[1:9,11:28];

Sets={'All'}; %This is the set of measures to include e.g. NoSulc, or All


for SetNumber=1:length(Sets);
    Set=eval(Sets{SetNumber});
    SetName=Sets{SetNumber}
    
Measures={'.Z_by_controls.thickness_z_on_lh.sm10.mgh'; '.Z_by_controls.lh-rh.thickness_z.sm10.mgh';...
    '.Z_by_controls.w-g.pct_z_on_lh.sm10.mgh';'.Z_by_controls.lh-rh.w-g.pct_z.sm10.mgh';...
    '.Doughnut_thickness_6_on_lh.sm10.mgh';'.Doughnut_intensity_contrast_6_on_lh.sm10.mgh';...
    '.Z_by_controls.LCD_z_on_lh.mgh';'.Z_by_controls.lh-rh.LCD_z.mgh';...
    '.Z_by_controls.curv_on_lh.mgh';'.Z_by_controls.sulc_on_lh.mgh';...
    '.Z_by_controls.gm_FLAIR_0.75_z_on_lh.sm10.mgh';'.Z_by_controls.gm_FLAIR_0.5_z_on_lh.sm10.mgh';...
    '.Z_by_controls.gm_FLAIR_0.25_z_on_lh.sm10.mgh';'.Z_by_controls.gm_FLAIR_0_z_on_lh.sm10.mgh';...
    '.Z_by_controls.wm_FLAIR_0.5_z_on_lh.sm10.mgh';'.Z_by_controls.wm_FLAIR_1_z_on_lh.sm10.mgh';...
    '.Doughnut_FLAIR_0_6_on_lh.sm10.mgh';'.Doughnut_FLAIR_0.5_6_on_lh.sm10.mgh';...
    '.Doughnut_FLAIR_0.25_6_on_lh.sm10.mgh';'.Doughnut_FLAIR_0.75_6_on_lh.sm10.mgh';...
    '.Doughnut_wm_FLAIR_0.5_6_on_lh.sm10.mgh';'.Doughnut_wm_FLAIR_1_6_on_lh.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_FLAIR_0.75_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_FLAIR_0.5_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_FLAIR_0.25_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_FLAIR_0_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.wm_FLAIR_0.5_z.sm10.mgh';'.Z_by_controls.lh-rh.wm_FLAIR_1_z.sm10.mgh'};

%%Removing measures
Measures=Measures(Set);
NumberOfMeasures=length(Measures);

%NODES

for s=1:length(subset)
    clear Binary Combined
    sub=subset(s);
    sub=cell2mat(sub);
    %Set h1 to be lesional hemisphere
    if exist(['',sub,'/xhemi/surf/lh.lesion_2_on_lh.mgh'])
        h1='lh';
        h2='rh';
    else
        h1='rh';
        h2='lh';
    end
 
 
 

    %%Load in overlay files from non-lesional hemisphere
    Normal=zeros(length(NumberOfMeasures),length(Cortex));
    for L=1:NumberOfMeasures;
        M=MRIread(['',sub,'/xhemi/surf/',h2,'',Measures{L},'']);
    Normal(L,:)=M.vol(Cortex);
    end
  
   
    %%Load in lesion label and get indices of vertices
   Lesion=MRIread(['',sub,'/xhemi/surf/',h1,'.lesion_2_on_lh.mgh']);
    [a,Lesion,c]=find(Lesion.vol==1);
    Lesion=intersect(Lesion,Cortex);
    Lesion=Lesion';
 %%Load in data from lesional hemisphere
 LesionData=zeros(length(NumberOfMeasures),length(Lesion));
 for L=1:NumberOfMeasures;
     M=MRIread(['',sub,'/xhemi/surf/',h1,'',Measures{L},'']);
    LesionData(L,:)=M.vol(Lesion);
 end
  
    %%Load all data together as a single matrix
    Combined=[Normal,LesionData];
    Combined=Combined';
    
    %%Add Normal and Lesional data to data of all other subjects
    Multi=[Multi;Combined];
    

    Binary(1:length(Normal))=1;
    Binary(length(Normal)+1:length(Normal)+length(LesionData))=-1;
    Binary=Binary';
    Score=[Score; Binary(:)];
    
end

% Use principal component analysis to pick number of nodes in neural
% network - number of components explaining 99% of the variance

 [COEFF,SCORE,latent,tsquare] = princomp(Multi);
 PCA=cumsum(latent)./sum(latent);
 PCA(PCA>0.99)=[];
NumberHiddenNodes=length(PCA)

Score(Score==-1)=0;
Score(:,2)=Score(:,1).*-1+1;

%Neural network
% alternatively - if you do not want to use a PCA to decide the number of
% nodes - you can enter the nummber of nodes below e.g. hiddenLayerSize=12;
 hiddenLayerSize=[NumberHiddenNodes];
 net=patternnet(hiddenLayerSize);
 net.divideParam.trainRatio=70/100;
 net.divideParam.valRatio=15/100;
 net.divideParam.testRatio=15/100;
 [net,tr]=train(net,Multi',Score','showResources','yes','useParallel','yes','showResources','yes');
 
 
  %Test classifier on patient left out of training 
  
sub=TestSubject;
 for hemi=1:2;
     %run on both hemispheres
if hemi==1;
        h1='lh';
        h2='rh';
    else
        h1='rh';
        h2='lh';
end

%load in cortex label and +1 to correct for freesurfer-matlab indexing
Cortex=read_label(['fsaverage_sym'],['lh.cortex']);
 Cortex=Cortex(:,1)+1;   
 %load in all measures for hemisphere
   for L=1:NumberOfMeasures;
      M=MRIread(['',sub,'/xhemi/surf/',h1,'',Measures{L},'']);
    Normal(L,:)=M.vol(Cortex);
    end


X{1}=Normal;
%classify vertices. Output column 2 is continuous between 0 and 1.
%higher value is more likely to be lesional
[Y]=net(X);
Out=Y{1};
M.vol=M.vol*0;
M.vol(Cortex)=Out(2,:)';

%Save out lesional likelyhood map. This filename
%includes various parameters used in network.
MRIwrite(M,['',TestSubject,'/xhemi/classifier/',h1,'.',sub,'.NN_Nodes_',num2str(NumberHiddenNodes),'_Features_',SetName,'_Pat_',num2str(length(subs)),'_Layers_1.mgh'])
Multi=[];
Score=[];
 

end
end
end
