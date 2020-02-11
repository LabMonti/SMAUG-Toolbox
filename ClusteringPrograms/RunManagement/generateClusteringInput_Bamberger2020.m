function [ClusteringInputParams, minPtsList] = ...
    generateClusteringInput_Bamberger2020(name, onHPC)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Generates the "standard" set of clustering input
    %paramters used for segment clustering in the paper Bamberger et al.
    %2020
    %
    %~~~INPUTS~~~:
    %
    %name: either the file name of the dataset to cluster, or just a name
    %   to identify the dataset to be clustered
    %
    %onHPC: logical variable; if true, parameters are set to include
    %   parallelization for the HPC at Arizona
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %ClusteringInputParameters: structure containing all input parameters
    %   for a clustering run
    %
    %minPtsList: list of minPts values if multiple clustering runs are to
    %   be performed
    
    
    if nargin < 2
        onHPC = false;
    end

    ClusteringInputParams = struct();
    ClusteringInputParams.input_file_name = name;
    ClusteringInputParams.output_tag = 'default'; 
    ClusteringInputParams.save_output = 0; %whether or not to save the output structure to a file
    [~,ClusteringInputParams.running_folder,~] = fileparts(pwd); %Get running folder
    ClusteringInputParams.clustering_mode = 'Segments';
    ClusteringInputParams.clustering_algorithm = 'SOPTICS'; %possibilities are 'SOPTICS' or 'OPTICS'
    if onHPC
        ClusteringInputParams.nCores = 28;
    else
        ClusteringInputParams.nCores = 1; %# of cores to use; if >1, projection will be parallelized
    end
    ClusteringInputParams.random_seed = 'use_time'; %seed to use for generating random #s
    ClusteringInputParams.left_chop = -Inf; %minimum distance value to be used for clustering (can be set to -Inf to include all points)
    ClusteringInputParams.cL = 30; %coefficient for how many projection lines to use in SOPTICS
    ClusteringInputParams.cP = 30; %coefficient for how may partitions to calculate in SOPTICS
    ClusteringInputParams.minPts = 85; %used to determine core distances in OPTICS algorithm
    ClusteringInputParams.minSize = 120; %used to determine how finely to partition data in SOPTICS algorithm
    ClusteringInputParams.length_weighting = true; %Whether to duplicate segments in proportion to their length to increase density around long segments
    ClusteringInputParams.CondCeiling = 2.5; %Conductances above this value will be removed prior to segmentation (units of G_0, NOT logged)
    ClusteringInputParams.length_per_duplicate = 0.05; %each segment is duplicated once per this length (in nm)
    
    %List of minPts values to use
    minPtsList = [35; 45; 55; 65; 75; 85; 95; 105; 115; 125; 135; 145];
    
end