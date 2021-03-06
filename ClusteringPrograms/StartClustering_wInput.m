%Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/. 
%
%USE THIS FUNCTION TO CHANGE CLUSTERING PARAMETERS FOR CUSTOM CLUSTERING
%RUNS
function OutputStruct = StartClustering_wInput(optional_input_struct)
    %~~~INPUTS~~~:
    %
    %optional_input_struct: this function can be passed an input trace
    %   structure (or the name of a file containing such a structure, or
    %   its ID# if the dataset library); if left blank, than a filename
    %   must be specified below
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %   
    %OutputStruct: an structure containing the clustering output
    %   information; depending on settings below this will also be saved to
    %   the ClusteringOutputData directory
    
    
    %Make structure to store all input parameters:
    I = struct();

    %Inputs and Outputs:
    I.input_file_name = 'Example_OPV3-2BT-F_Dataset.mat'; %input file must be in the 'DataSets' directory;
                                                          %unused if a trace structure is passed as an input
    I.output_tag = 'TestClustering'; %tag used to label output files; set to "default" to 
                              %use current folder name as the output tag
    I.save_output = 1; %whether or not to save the output structure to a file
    [~,I.running_folder,~] = fileparts(pwd); %Get running folder

    %Define the clustering mode.  Options are below:
    I.clustering_mode = 'Segments';
    %  1.  Segments (break each trace into linear segments and cluster the
    %       segments)
    %  2.  Segments_PreSegmented (same as "Segments" mode, except that the
    %       input file will contain pre-segmented traces to save time)
    %  3.  Histogram (bin trace data into a 2D histogram then cluster; see Wu
    %       el al. 2016)
    %  4.  ExtendedTraces (cluster traces that are chopped on the LEFT to have 
    %       the same length, but on the right are extended along the noise 
    %       floor to have the same length (all traces also re-sampled)
    %  5.  TraceHists (transform each trace into a 1D histogram and cluster
    %       these histograms)
    %  6.  PointsFromTraces (cluster the raw data points from all traces)
    %  7.  Hybrid (cluster raw data points but add a third dimension
    %       representing the local trace slope)
    %  8.  Points (basic clustering of n-dimensional points; in this case only,
    %       the input file should just contain a single array)

    %Parameters that apply to all clustering modes:
    I.clustering_algorithm = 'SOPTICS'; %possibilities are 'SOPTICS' or 'OPTICS'
    I.minPts = 85; %used to determine core distances in OPTICS algorithm
    I.nCores = 1; %# of cores to use; if >1, projection will be parallelized
    I.random_seed = 'use_time'; %seed to use for generating random #s
    I.left_chop = -Inf; %minimum distance value to be used for clustering (can be set to -Inf to include all points)
    I.CondCeiling = 2.5; %Conductances above this value will be removed prior to segmentation (units of G_0, NOT logged)

    %SOPTICS-specific parameters:
    if strcmp(I.clustering_algorithm,'SOPTICS')
        I.cL = 30; %coefficient for how many projection lines to use in SOPTICS
        I.cP = 30; %coefficient for how may partitions to calculate in SOPTICS
        I.minSize = 50; %used to determine how finely to partition data in SOPTICS algorithm
    %OPTICS-specific parameters:
    elseif strcmp(I.clustering_algorithm,'OPTICS')
        I.geneps = 1; %ONLY USED BY REGULAR OPTICS; epsilon value to be used while clustering to find neighborhoods
    end

    %Parameters specific to certain clustering modes:
    if any(strcmp(I.clustering_mode,{'Segments','Segments_PreSegmented'}))
        I.length_weighting = true; %Whether to duplicate segments in proportion to their length 
                                   %to increase density around long segments
        if I.length_weighting
            I.length_per_duplicate = 0.05; %each segment is duplicated once per this length (in nm)
        end
    elseif strcmp(I.clustering_mode,'Histogram')
        I.w = 1.5; %Weight applied to conductance axis 
        I.bins_per_x = 150;
        I.bins_per_y = 37.5;
    elseif strcmp(I.clustering_mode,'Hybrid')
        I.slope_window = 10; %# of points in window used for calculating slope (not including point itself)
    elseif strcmp(I.clustering_mode,'TraceHists')
        I.tracehist_binsper = 5; %# of bins per decade on conductance axis
        I.cond_limits = [-6 2]; %range of log(G/G_0) to be used
    elseif strcmp(I.clustering_mode,'ExtendedTraces')
        I.distStep = 'median'; %Distance between re-sampling points; can be set to 'median' to be data-based
        I.maxDist = Inf; %Maximum distance to extend traces to; set to "Inf" to extend to end of longest trace
    end
    
    %If an input structure was supplied, no need to go open up an input
    %file:
    if nargin == 0
        optional_input_struct = [];
    else
        I.input_file_name = '[run from command line]';
    end

    %Run the clustering
    OutputStruct = runClustering(I, optional_input_struct);

    %Save the clustering output if requested:
    if I.save_output > 0
        [Output_Location, output_tag] = SetUpOutputDirectory(I.output_tag,...
            I.running_folder,mfilename('fullpath'));
        SaveClusteringOutput(OutputStruct, Output_Location, output_tag);
    end
end
