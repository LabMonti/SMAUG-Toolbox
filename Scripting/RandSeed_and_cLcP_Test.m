%Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  

%Script for clustering the same dataset using several different random
%seeds AND different cL = cP parameter values

%Get trace structure that we are going to use:
lib = build_library();
dataset_ID = 3;
TraceStruct = load_library_entry_OCELOTE(lib, dataset_ID);
name = create_name_for_library_entry(lib, dataset_ID);

%Get standard clustering paramters, set minPts to a fixed value
onHPC = true;
[I, ~] = generateClusteringInput_Bamberger2020(name, onHPC);
I.minPts = 85;

RandomSeed_List = [9001, 1337, 2101, 72019, 1993, 42, 3141, 2718, 191316, 1776];
c_List = [20, 25, 30];

n1 = length(RandomSeed_List);
n2 = length(c_List);

%Parameters for plotting of clustering solutions
cutoff_frac = 0.01;
seedID = 1;
cID = 3;

%Pre-segment traces, so that we only have to do this ONCE even though
%we are going to cluster multiple times
SegStr = PreSegmentTraces(TraceStruct,'ErrorGain',I.left_chop,...
    I.CondCeiling,I.nCores);

%Cluster at each combination of random seed and cL/cP value
for i = 1:n2
    I.cL = c_List(i);
    I.cP = c_List(i);
    OO_List = cell(n1,1);
    for j = 1:n1
        I.random_seed = RandomSeed_List(j);
        
        OO = runClustering(I, SegStr);
        
        %Make clustering plots for a single iteration
        if j == seedID && i == cID
            Show_FullValleyClusters(OO,cutoff_frac,'LinearSegments',name);  
        end
        
        %We'll only save out TracesUsed a single time to save on space
        if i == 1 && j == 1    
            TracesUsed = OO.TracesUsed;
            save(strcat(name,'_TracesUsed.mat'),'TracesUsed');
        end
        OO.TracesUsed = [];
        
        OO_List{j} = OO;
        
    end
    
    %Save output (to local directory)
    save(strcat(name,'_ClustOut_cL=cP=',num2str(c_List(i)),'.mat'),'OO_List');
end