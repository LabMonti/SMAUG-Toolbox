function Size_Table = ExtractAndPlotClustering(OutputStruct, eps, ...
    cutoff_fraction, PlotNoise, PlotStyle)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Use a given epsilon value to extract a 
    %clustering solution from the reachability plot, then plot that 
    %solution in a new figure
    %
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output
    %
    %eps: the value of epsilon at which extraction takes place; clusters
    %   will be valleys that exist below this cut-off value in the
    %   reachability plot
    %
    %cutoff_fraction: the minimum size a valley in the reachability plot
    %   must be to be considered a true cluster, as a fraction of the total
    %   # of data points (so 0.02 means clusters must contain at least 2%
    %   of all data points). Points in valleys with fewer than this # of
    %   data points are re-assigned to the noise cluster
    %
    %PlotNoise: logical variable, whether to visibly plot the noise cluster
    %   or not
    %
    %PlotStyle: for some types of clustering output (currently just segment
    %   clustering), their are multiple options for how to display the
    %   clustering solutions; PlotStyle is a string identifying which of
    %   those options to choose.  
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %Size_Table: table of cluster sizes (1st column: cluster ID, 2nd 
    %   column: # points in cluster, 3rd column: fraction of points in 
    %   cluster)
    
    %Default values
    if nargin < 5
        PlotStyle = 'LinearSegments';
    end
    if nargin < 4
        PlotNoise = false;
    end
    if nargin < 3
        cutoff_fraction = 0.01;
    end
    
    %If there are duplicates that haven't been removed yet, remove them now
    if strcmp(OutputStruct.Format,'Segments_LengthWeighting') && ...
            ~isfield(OutputStruct, 'OG_order')
        OutputStruct = RemoveDuplicateSegmentsFromOutput(OutputStruct);   
    end  
    
    %If traces need to be resampled but haven't been yet, resample them now
    if strcmp(PlotStyle,'AverageTraceSegments') && ~isfield(OutputStruct, 'AlignedSegments')
        OutputStruct = GetResampledSegments(OutputStruct);
    end

    %Extract cluster solution at given epsilon value
    [Y, SizeArray, Size_Table] = ExtractClusterSolution(OutputStruct.RD, OutputStruct.CD, ...
        eps, cutoff_fraction);
    
    %Plot the cluster solution using the appropriate program based on the
    %format of data that was clustered
    data_format = OutputStruct.Format;
    if strcmp(data_format,'Histogram')
        
        %Re-assign clusters consisting solely of low-count bins to the 
        %noise cluster:   
        [Y, SizeArray] = excludeLowIntensityPoints(OutputStruct.Xraw,...
            OutputStruct.order, Y);
        Size_Table =  array2table(SizeArray,'VariableNames',...
            {'Cluster_ID','Points_in_Cluster','Fraction_Points_in_Cluster'});
        
        PlotClusterSolution_Histogram(OutputStruct, Y, SizeArray, eps, PlotNoise);
        
    elseif strcmp(data_format,'DataPoints') || strcmp(data_format,'TraceEnhancedDataPoints')
       
        PlotClusterSolution_DataPoints(OutputStruct.Xraw,...
            OutputStruct.order,Y,SizeArray,eps,'MixedHeatMaps',PlotNoise);

    elseif strcmp(data_format,'ExtendedTraces') %|| strcmp(data_format,'TraceMatrix') || strcmp(data_format,'Traces')
        
        PlotClusterSolution_Traces(OutputStruct, Y, SizeArray, eps, PlotNoise);

    elseif strcmp(data_format,'TraceHists')
        
        PlotClusterSolution_TraceHists(OutputStruct, Y, SizeArray, eps, PlotNoise);
      
    elseif strcmp(data_format,'Segments') || strcmp(data_format,'Segments_LengthWeighting')
        
        %Remove duplicates before plotting, in the case that there are
        %duplicates.  However, calculate the cluster sizes FIRST so that
        %the length weighting is reflected in them.  
        [SizeArray, Size_Table] = GetPopulationTables(Y); 
        if strcmp(data_format,'Segments_LengthWeighting')
            Y = RemoveDuplicateSegmentsFromY(Y, OutputStruct);       
        end
        
        %There are multiple styles for plotting segments:
        if strcmp(PlotStyle,'LinearSegments')
            PlotClusterSolution_LinearSegments(OutputStruct, Y, SizeArray, ...
                eps, PlotNoise);
        elseif strcmp(PlotStyle,'SegmentPoints')
            PlotClusterSolution_SegmentPoints(OutputStruct, Y, SizeArray, ...
                eps, 5, PlotNoise);         
        elseif strcmp(PlotStyle,'TraceSegments')
            PlotClusterSolution_TraceSegments(OutputStruct, Y, SizeArray, ...
                eps, PlotNoise);              
        elseif strcmp(PlotStyle,'AverageTraceSegments')
            PlotClusterSolution_AverageTraceSegments_V2(OutputStruct, Y, ...
                SizeArray, eps, PlotNoise);
        else
            disp('Unrecognized plotting style; allowed styles are:');
            disp({'LinearSegments'; 'SegmentPoints'; 'TraceSegments'; ...
                'AverageTraceSegments'});
            error('STOPPING');
        end
        
    else
        error('Unrecognized clustering format used');
    end


end
