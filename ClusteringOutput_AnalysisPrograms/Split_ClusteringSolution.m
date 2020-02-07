function [ClusterTS_List, NoiseTS] = Split_ClusteringSolution(...
    OutputStruct, TraceStruct, extraction_epsilon, cutoff_frac, ToPlot)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given clustering output and a particular 
    %solution (i.e. a particular epsilon value), split the original trace
    %structure into one for each cluster, including the noise
    %
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output
    %
    %TraceStruct: the trace structure used to produce the clustering output
    %
    %extraction_epsilon: the value of epsilon at which extraction takes
    %   place; clusters will be valleys that exist below this cut-off value
    %   in the reachability plot
    %
    %cutoff_fraction: the minimum size a valley in the reachability plot
    %   must be to be considered a true cluster, as a fraction of the total
    %   # of data points (so 0.02 means clusters must contain at least 2%
    %   of all data points). Points in valleys with fewer than this # of
    %   data points are re-assigned to the noise cluster
    %
    %ToPlot: logical variable; whether or not to make a 2D histogram
    %   showing the traces corresponding to each cluster
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %ClusterTS_List: a cell array containing one trace structure for each
    %   cluster in the given clustering solution, containing those traces
    %   that had piece assigned to that cluster
    %
    %NoiseTS: the trace structure for the noise cluster
    
    
    if nargin < 4
        cutoff_frac = 0.02;
    end
    if nargin < 5
        ToPlot = true;
    end
    
    if ~any(strcmp(OutputStruct.Format,{'ExtendedTraces','Segments',...
            'Segments_LengthWeighting','TraceHists'}))
        error(strcat('This only works for clustering modes where the ',...
            'objects being clustered are traces or correspond easily to them'));
    end
    
    %First get the cluster assignments:
    [Y, T, ~] = ExtractClusterSolution(OutputStruct.RD, OutputStruct.CD,...
        extraction_epsilon, cutoff_frac);
    
    %Remove duplicates from Y and order if applicable
    if strcmp(OutputStruct.Format,'Segments_LengthWeighting')
        Y = RemoveDuplicateSegmentsFromY(Y, OutputStruct);
        OutputStruct = RemoveDuplicateSegmentsFromOutput(OutputStruct);
    end
    
    %Re-order Y to put it in the same order as the traces
    [~, sortI] = sort(OutputStruct.order);
    Y = Y(sortI);
    
    %Get total # of clusters, including the noise cluster even it it is
    %empty!
    nClust = size(T,1);
    
    %Make a cell array with one cell for each non-noise cluster
    ClusterTS_List = cell(nClust-1,1);
    
    old_name = TraceStruct.name;
    
    %Make structure for the noise cluster
    if any(strcmp(OutputStruct.Format,{'Segments','Segments_LengthWeighting'}))
        NoiseTS = tracestruct_from_subset(TraceStruct, OutputStruct.SegmentTraceIDs(Y == 0),strcat(old_name,'_NoiseClust'));
    else
        NoiseTS = tracestruct_from_subset(TraceStruct, find(Y == 0),strcat(old_name,'_NoiseClust'));
    end
    
    %Make structure for each non-noise cluster
    for i = 1:nClust-1
        if any(strcmp(OutputStruct.Format,{'Segments','Segments_LengthWeighting'}))
            ClusterTS_List{i} = tracestruct_from_subset(TraceStruct,...
                OutputStruct.SegmentTraceIDs(Y == i),strcat(old_name','_Cluster',num2str(i)));            
        else
            ClusterTS_List{i} = tracestruct_from_subset(TraceStruct,...
                find(Y == i),strcat(old_name','_Cluster',num2str(i)));
        end
    end
    
    if ToPlot
        Make2DHist_FromTraceStructure(NoiseTS,50,20);
        title('Traces Assigned to Noise Cluster');
        xlim([-0.2 1.2]);
        caxis([0 2]);
        
        
        for i = 1:nClust-1
            Make2DHist_FromTraceStructure(ClusterTS_List{i},50,20);
            title(strcat('Traces Assigned to Cluster',{' '},num2str(i)));
            xlim([-0.2 1.2]);
            caxis([0 2]);
        end
    end
    
end