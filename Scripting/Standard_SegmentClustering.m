function [OO_List, TracesUsed] = Standard_SegmentClustering(TraceStruct,...
    save_name, onHPC)
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
    %save_name: a name to identify the dataset being clustered in saved
    %   output files; leave blank/empty to not save output files
    %
    %onHPC: logical variable; if true, parameters are set to include
    %   parallelization for the HPC at Arizona


    if nargin < 3
        onHPC = false;
    end
    if nargin < 2
        save_name = [];
    end
    
    %Get "standard" clustering input parameters
    [I, minPtsList] = generateClusteringInput_Bamberger2020(save_name, onHPC);
    
    %Parameters for plotting of clustering solutions
    cutoff_frac = 0.01;
    minPts_ID_toPlot = 6;
    
    %Cluster at each value of minPts
    [OO_List,TracesUsed] = StartClustering_Range_minPoints(TraceStruct,...
        I,minPtsList);
    
    %Save output (to local directory)
    save(strcat(save_name,'_ClustOut.mat'),'OO_List','TracesUsed');

    %Get clustering output for "reference" minPts value
    OO = OO_List{minPts_ID_toPlot}; 
    OO.TracesUsed = TracesUsed;

    %Save reachability plot and "maximum valley clusters" for reference
    %clustering output
    Show_FullValleyClusters(OO,cutoff_frac,'LinearSegments',save_name);

end