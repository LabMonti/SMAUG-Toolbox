%Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  

%Script for clustering the same dataset using several different minSize
%parameter values

%Get trace structure that we are going to use:
lib = build_library();
dataset_ID = 25;
TraceStruct = load_library_entry_OCELOTE(lib, dataset_ID);
name = create_name_for_library_entry(lib, dataset_ID);

%Get standard clustering parameters, fix minPts at 85
onHPC = true;
[I, ~] = generateClusteringInput_Bamberger2020(name, onHPC);
I.minPts = 85;

minSize_List = [20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,300,400,500];
n = length(minSize_List);

%Parameters for plotting of clustering solutions
cutoff_frac = 0.01;
minSize_ID_ToPlot = 7;

%Pre-segment traces, so that we only have to do this ONCE even though
%we are going to cluster multiple times with different minPts values
SegStr = PreSegmentTraces(TraceStruct,'ErrorGain',I.left_chop,...
    I.CondCeiling,I.nCores);

OO_List = cell(n,1);

for i = 1:n
    %Change minSize
    I.minSize = minSize_List(i);
       
    OO = runClustering(I,SegStr);

    %Let's only save out traces used once to avoid wasting space with
    %repetition
    if i == 1
        TracesUsed = OO.TracesUsed;
    end

    if i == minSize_ID_ToPlot
       
        %Save reachability plot and "maximum valley clusters" for reference
        %clustering output
        Show_FullValleyClusters(OO,cutoff_frac,'LinearSegments',name);        
        
    end
    
    %Remove traces used to save space
    OO.TracesUsed = [];
    OO_List{i} = OO;
end

%Save output (to local directory)
save(strcat(name,'_minSizeTest_ClustOut.mat'),'OO_List','TracesUsed');
