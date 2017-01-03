%% Script 10. Rank clusters of Neural Network Output
% This script writes out 2 files:
% 1. The top cluster across both hemispheres
% 2. The top 5 clusters across both hemispheres
clear all

% Directory of patients - change to appropriate
subjects_dir = '~/Desktop/Sophie_study/FCD_study/'
cd(subjects_dir)

setenv SUBJECTS_DIR .
addpath /Applications/freesurfer/matlab/

%Set appropriate prefix
Subs=dir('FCD_*');

subs=cell(length(Subs),1);
for s = 1:length(Subs);
    subs{s}=Subs(s).name;
end

% List of patients to be excluded
Remove={'FCD_05'; 'FCD_14';};
ind=find(ismember(subs,Remove));
subs(ind)=[];

% For each subject 
for s=1:length(subs)
    
     sub=subs(s);
     sub=cell2mat(sub);

     
% Load in neural network and clustered neural network output for each hemisphere
 h1='lh';
 h2='rh';
 

     %load in clustered outputs.
    M=MRIread(['',sub,'/xhemi/classifier/',h1,'.',sub,'.NN_Nodes_11_Features_AllPvalues_Pat_22_Layers_1.mgh']);
    aM=MRIread(['',sub,'/xhemi/classifier/',h2,'.',sub,'.NN_Nodes_11_Features_AllPvalues_Pat_22_Layers_1.mgh']);
     
    C=MRIread(['',sub,'/xhemi/classifier/',h1,'.',sub,'.NN_Nodes_11_Features_AllPvalues_Pat_22_Layers_1_Clusters_minarea1.mgh']);
    aC=MRIread(['',sub,'/xhemi/classifier/',h2,'.',sub,'.NN_Nodes_11_Features_AllPvalues_Pat_22_Layers_1_Clusters_minarea1.mgh']);
    
    R=C;R.vol(:)=0;
    aR=aC;aR.vol(:)=0;
        
     %From 1 to 5
     for r=1:5;
         %Find vertices with cluster number. Get maximum vertex classifier value
         %This could be changed to mean if deemed more appropriate.
         Max1=max(M.vol(C.vol~=0));
         Max2=max(aM.vol(aC.vol~=0));
         %Compare which is larger for the two hemispheres
         %eg If left max is larger that contains cluster 1
         %The right cluster
         
if   Max1>Max2 ;
    %Get cluster reference of index with highest value
    ClustNum=C.vol(M.vol==Max1);
    %set all of that cluster to r (ranking from 1 to 5)
    R.vol(C.vol==ClustNum)=r;
M.vol(C.vol==ClustNum)=0;
if r==1;
      %save top cluster
        MRIwrite(R, ['',sub,'/xhemi/classifier/',h1,'.',sub,'.NN_Nodes_11_Features_AllPvalues_Pat_22_Layers_1_Z_by_controls_signed_control_PCA_OneCluster_minarea1_cortex_only.mgh'])
    end
elseif Max2>Max1;
        %Get cluster reference of index with highest value
       ClustNum=aC.vol(aM.vol==Max2);
           %set all of that cluster to r (ranking from 1 to 5)
    aR.vol(aC.vol==ClustNum)=r;
aM.vol(aC.vol==ClustNum)=0;
     if r==1;
      %save top cluster
        MRIwrite(aR, ['',sub,'/xhemi/classifier/',h2,'.',sub,'.NN_Nodes_11_Features_AllPvalues_Pat_22_Layers_1_Z_by_controls_signed_control_PCA_OneCluster_minarea1_cortex_only.mgh'])
     end
elseif isempty(Max2);
        %Get cluster reference of index with highest value
   ClustNum=C.vol(M.vol==Max1);
    R.vol(C.vol==ClustNum)=r;
M.vol(C.vol==ClustNum)=0;
    if r==1;
            %save top cluster

        MRIwrite(R, ['',sub,'/xhemi/classifier/',h1,'.',sub,'.NN_Nodes_11_Features_AllPvalues_Pat_22_Layers_1_Z_by_controls_signed_control_PCA_OneCluster_minarea1_cortex_only.mgh'])
    end
elseif isempty(Max1);
     ClustNum=aC.vol(aM.vol==Max2);
    aR.vol(aC.vol==ClustNum)=r;
aM.vol(aC.vol==ClustNum)=0;
     if r==1;
               %save top cluster

        MRIwrite(aR, ['',sub,'/xhemi/classifier/',h2,'.',sub,'.NN_Nodes_11_Features_AllPvalues_Pat_22_Layers_1_Z_by_controls_signed_control_PCA_OneCluster_minarea1_cortex_only.mgh'])
     end
end
    
    
     end
         
         
         MRIwrite(R, ['',sub,'/xhemi/classifier/',h1,'.',sub,'.NN_Nodes_11_Features_AllPvalues_Pat_22_Layers_1_Z_by_controls_signed_control_PCA_Clusters5_minarea1_cortex_only.mgh'])
                  MRIwrite(aR, ['',sub,'/xhemi/classifier/',h2,'.',sub,'.NN_Nodes_11_Features_AllPvalues_Pat_22_Layers_1_Z_by_controls_signed_control_PCA_Clusters5_minarea1_cortex_only.mgh'])


end