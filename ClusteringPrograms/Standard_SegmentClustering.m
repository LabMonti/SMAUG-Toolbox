%NDB 18Jun19: Function to run my new "standard" segment clustering
%appproach on a given trace structure; clusters in 12 different ways, saves
%outputs, makes clustering plots for one of the outputs
function Standard_SegmentClustering(TraceStruct, name, onHPC)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Function to run my new "standard" segment
    %clustering appproach on a given trace structure; clusters in 12
    %different ways, saves outputs, makes clustering plots for one of the
    %outputs
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: the trace structure containing the dataset to be
    %clustered
    %
    %name: a name to identify the dataset being clustered
    %
    %onHPC: logical variable; if true, parameters are set to include
    %   parallelization for the HPC at Arizona


    if nargin < 2
        onHPC = false;
    end
    
    %Get "standard" clustering input parameters
    [I, minPtsList] = generateClusteringInput_Bamberger2020(name, onHPC);
    
    %Parameters for plotting of clustering solutions
    cutoff_frac = 0.01;
    minPts_ID_toPlot = 6;
   
    %Pre-segment traces, so that we only have to do this ONCE even though
    %we are going to cluster multiple times with different minPts values
    SegStr = PreSegmentTraces(TraceStruct,'ErrorGain',I.left_chop,...
        I.CondCeiling,I.nCores);
    
    %Cluster at each value of minPts
    [OO_List,TracesUsed] = StartClustering_Range_minPoints(SegStr,I,minPtsList);
    
    %Save output (to local directory)
    save(strcat(name,'_ClustOut.mat'),'OO_List','TracesUsed');

    %Get clustering output for "reference" minPts value
    OO = OO_List{minPts_ID_toPlot}; 
    OO.TracesUsed = TracesUsed;

    %Save reachability plot and "maximum valley clusters" for reference
    %clustering output
    Show_FullValleyClusters(OO,cutoff_frac,name);

end