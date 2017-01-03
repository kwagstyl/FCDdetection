
%% Script 9. Cluster Neural Network Output

% This script thresholds the neural network probability map to only exhibit
% the top 5% of vertices. Then these top 5% of vertices are clustered.
% There is a minimum cluster size of 1mm^2. This can be altered.

clear all

% Directory of patients - change to most appropriate
subjects_dir = '~/Desktop/Sophie_study/FCD_study/'
cd(subjects_dir)

setenv SUBJECTS_DIR .
addpath /Applications/freesurfer/matlab/

% List of FCD patients - change to appropriate prefix
Subs=dir('FCD_*');

subs=cell(length(Subs),1);
for s = 1:length(Subs);
    subs{s}=Subs(s).name;
end

% List of patients to be excluded
Remove={'FCD_05'; 'FCD_14';};
ind=find(ismember(subs,Remove));
subs(ind)=[];


%Set Minimum surface area of cluster in mm^2
% In this example it is 1mm
MinArea=1;

% Load pial surface and cortical label and area
    [surf] = fs_read_surf(['fsaverage_sym/surf/lh.pial']);
    %find neighbouring vertices
    [surf]=fs_find_neighbors(surf);
     Cortex=read_label(['fsaverage_sym'],['lh.cortex']);
     area=read_curv(['fsaverage_sym/surf/lh.area']);
    Cortex=Cortex(:,1)+1; 

% Loop through each subject
for s=1:length(subs)
   
     sub=subs(s);
     sub=cell2mat(sub);

     % Variable created for each hemisphere
     h1='lh';
     h2='rh';
 

     % Load classifier output for each hemisphere
    M=MRIread(['',sub,'/xhemi/classifier/',h1,'.',sub,'.NN_Nodes_11_Features_All_Pat_22_Layers_1.mgh']);
    aM=MRIread(['',sub,'/xhemi/classifier/',h2,'.',sub,'.NN_Nodes_11_Features_All_Pat_22_Layers_1.mgh']);
     
    %%
    %%find threshold value for classifier output
    % Combine left and right hemi output
    Combined=[M.vol(Cortex),aM.vol(Cortex)];
    % Sort probabilities
    NNas=sort(Combined);
    %Top 5% of vertices - so that only cluster top 5 % of vertices
    Threshlength=round(0.95*length(NNas));
    Thresh=NNas(Threshlength);
   %%
    % For each hemisphere
   for h=1:2;
       if h==1;
           h1='lh';
       else 
           h1='rh';
       end
           
    %load in example mgh strucutre
        M=MRIread(['',sub,'/xhemi/classifier/',h1,'.',sub,'.NN_Nodes_11_Features_All_Pat_22_Layers_1.mgh']);
        Map=M.vol;
        M.vol(:)=0;
 
        %Find vertices below and above threshold
Lows=intersect(find(Map<=Thresh),Cortex);
Highs=intersect(find(Map>=Thresh),Cortex);
%Find maximum value to start first cluster
Max=max(Map(Cortex));

Done=false;
l=0;
%continue clustering until the highest non-clustered vertex is below the threshold value
%or 25 clusters have been identified
  while ~Done
      %Start clustering at highest non-clustered vertex
    Vertex=find(Map==Max);
    Vertex=Vertex(1);
    
    Patch=[Vertex;intersect(nonzeros(surf.nbrs(Vertex,:)),Highs)];
    Grown=false;
   %Grow patch by including neighbours that are above threshold (highs)
   %exit loop once cluster has no neighbours in Highs
    while ~Grown
        NBRS=intersect(nonzeros(surf.nbrs(Patch,:)),Highs);
        Growth=unique(setdiff(NBRS,Patch));
        Patch=[Patch;Growth];
        Grown=isempty(Growth);
    end
    
  %Only save cluster if it is larger than the threshold area
    if sum(area(Patch))>MinArea;

        l=l+1;
        %set values in M to l, the cluster number
        M.vol(Patch)=l;
    else
    
    end
    %Set any vertices in the current cluster (Patch) to be negative and
    %therefore not considered by further iterations.
    Map(Patch)=Thresh-2;
    Max=max(Map(Cortex));
     Done=Max<=Thresh||l==25;
  end
MRIwrite(M, ['',sub,'/xhemi/classifier/',h1,'.',sub,'.NN_Nodes_11_Features_All_Pat_22_Layers_1_Clusters_minarea1.mgh'])
   end
end

