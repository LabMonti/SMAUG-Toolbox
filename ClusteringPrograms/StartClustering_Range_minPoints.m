function [OutputList, TracesUsed] = StartClustering_Range_minPoints(data, ...
    ClustInputParams, minPtsRange)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Runs clustering multiple times for a range of 
    %minPoints values (well, more specifically, a list of different minPts
    %values)
    %
    %~~~INPUTS~~~:
    %
    %data: input structure for data to be clustered (TraceStructure or
    %   Pre-Segmented Structure)
    %
    %ClustInputParams: struture containing all input parameters for the
    %   clustering
    %
    %minPtsRange: vector containing a list of minPts values to cluster at
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %   
    %OutputList: cell array containing a clustering output structure for
    %   each minPts value
    %
    %TracesUsed: In the case of Segment Clustering, the "TracesUsed" field
    %   of each output structure will be removed and this field will
    %   instead just be outputted once, here, to save on space
    
    
    N = length(minPtsRange);
    OutputList = cell(N,1);
    
    %If Segment clustering is being used, pre-segment all traces ONCE here
    %instead of doing it for each minPts value (since it will be the same
    %every time!)
    if strcmp(ClustInputParams.clustering_mode,'Segments')
        data = PreSegmentTraces(data,'ErrorGain',ClustInputParams.left_chop,...
            ClustInputParams.CondCeiling,ClustInputParams.nCores);
    end
    
    %This output is only needed for segment clustering
    if ~strcmp(ClustInputParams.clustering_mode, 'Segments_PreSegmented') && ...
        ~strcmp(ClustInputParams.clustering_mode, 'Segments')
        TracesUsed = [];
    end
    
    for i = 1:N
        
        %Update minPts and run clustering
        ClustInputParams.minPts = minPtsRange(i);
        OO = runClustering(ClustInputParams, data);
        
        %For segment clustering, let's not waste space by duplicating the
        %TracesUsed field; instead, delete it from each output and just
        %save it out once
        if strcmp(ClustInputParams.clustering_mode, 'Segments_PreSegmented') || ...
            strcmp(ClustInputParams.clustering_mode, 'Segments')
            if i == 1
                TracesUsed = OO.TracesUsed;
            end        
            OO.TracesUsed = [];
        end
        OutputList{i} = OO;
    end

end