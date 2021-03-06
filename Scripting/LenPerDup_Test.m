%Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  

%Script for running the clusterings to test the effects of different 
%LenPerDup values on the clustering of a given dataset, and how those 
%changes correlate with changes in minPts

%Get trace structure that we are going to use:
lib = build_library();
dataset_ID = 2;
TraceStruct = load_library_entry_OCELOTE(lib, dataset_ID);
name = create_name_for_library_entry(lib, dataset_ID);

onHPC = true;
[I, minPtsList] = generateClusteringInput_Bamberger2020(name, onHPC);

%List of LenPerDup values to use
LenPerDupList = [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10];
n = length(LenPerDupList);

%Parameters for plotting of clustering solutions
cutoff_frac = 0.01;
LenPerDup_ID_ToPlot = 5;
RefID = 6;

for i = 1:n
    %Change LenPerDup
    I.length_per_duplicate = LenPerDupList(i);
    
    %Cluster at each value of minPts
    [OO_List,TracesUsed] = StartClustering_Range_minPoints(TraceStruct,...
        I,minPtsList);
    
    %Only save TracesUsed once
    if i == 1
        save(strcat(name,'_TracesUsed.mat'),'TracesUsed');
    end
    
    %Save output (to local directory)
    save(strcat(name,'_',num2str(LenPerDupList(i)),'_ClustOut.mat'),...
        'OO_List');
    
    if i == LenPerDup_ID_ToPlot
       
        %Get clustering output for "reference" minPts value
        OO = OO_List{RefID}; 
        OO.TracesUsed = TracesUsed;

        %Save reachability plot and "maximum valley clusters" for reference
        %clustering output
        Show_FullValleyClusters(OO,cutoff_frac,'LinearSegments',name);        
        
    end
end