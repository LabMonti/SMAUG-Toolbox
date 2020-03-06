%Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  

%Script for clustering the same dataset using several different TopChop
%parameter values

%Get trace structure that we are going to use:
lib = build_library();
dataset_ID = 3;
TraceStruct = load_library_entry_OCELOTE(lib, dataset_ID);
name = create_name_for_library_entry(lib, dataset_ID);

onHPC = true;
[I, minPtsList] = generateClusteringInput_Bamberger2020(name, onHPC);
I.clustering_mode = 'Segments_PreSegmented';

CondCeiling_List = [1.5; 1.75; 2.0; 2.25; 2.5; 2.75; 3.0; 3.25; 3.5];
n = length(CondCeiling_List);

%Parameters for plotting of clustering solutions
cutoff_frac = 0.01;
cond_ID_ToPlot = 5;
RefID = 6;

for i = 1:n
    %Change TopChop
    I.CondCeiling = CondCeiling_List(i);
    
    %Pre-segment traces, so that we only have to do this ONCE even though
    %we are going to cluster multiple times with different minPts values
    SegStr = PreSegmentTraces(TraceStruct,'ErrorGain',I.left_chop,...
        I.CondCeiling,I.nCores);
    
    %Cluster at each value of minPts
    [OO_List,TracesUsed] = StartClustering_Range_minPoints(SegStr,I,minPtsList);
    
    %Save output (to local directory)
    save(strcat(name,'_',num2str(CondCeiling_List(i)),'_ClustOut.mat'),...
        'OO_List','TracesUsed');
    
    if i == cond_ID_ToPlot
       
        %Get clustering output for "reference" minPts value
        OO = OO_List{RefID}; 
        OO.TracesUsed = TracesUsed;

        %Save reachability plot and "maximum valley clusters" for reference
        %clustering output
        Show_FullValleyClusters(OO,cutoff_frac,'LinearSegments',name);        
        
    end
end