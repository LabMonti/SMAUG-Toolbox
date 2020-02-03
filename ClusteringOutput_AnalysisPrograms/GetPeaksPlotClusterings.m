%10May18 NDB: Find all peaks in the reachability plot that separate valleys
%of sufficient size, extract the clustering solution at each such peak, and
%plot that solution in an appropriate manner
function SizeTables = GetPeaksPlotClusterings(OutputStruct, ...
    cutoff_fraction, PlotNoise, PlotStyle)
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output
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
    %Size_Tables: cell array of tables of cluster sizes (1st column: 
    %   cluster ID, 2nd column: # points in cluster, 3rd column: fraction 
    %   of points in cluster)
    
    
    %Default inputs
    if nargin < 4
        PlotStyle = 'TraceSegments';
    end
    if nargin < 3
        PlotNoise = false;
    end
    if nargin < 2
        cutoff_fraction = 0.02;
    end
    
    disp('---Finding Peaks...---');
    RD = OutputStruct.RD;
    [~, peak_values] = FindReachabilityPeaks(RD, cutoff_fraction);
    
    if isempty(peak_values)
        error('No peaks discovered in Reachability Plot, Cannot Continue');
    end
    
    %Sort peak values and remove duplicates
    peak_values = unique(peak_values);
    
    %Plot reachability plot with extraction levels overlaid
    figure();
    plot(RD);
    hold on;
    for i = 1:length(peak_values)
        plot([0 length(RD)], [peak_values(i) peak_values(i)]);
    end    
    hold off;
    ylim([0 max(peak_values)*1.1]);
    xlabel('Cluster Order');
    ylabel('Reachability Distance');
    
    %Replace peaks at infinity with the maximum finite reachability
    %distance
    for i = 1:length(peak_values)
        if peak_values(i) == Inf
            peak_values(i) = max(RD(isfinite(RD)));
        end
    end
    
    %Remove duplicates before plotting, in the case that there are
    %duplicates; this is done before re-sampling traces so that we don't
    %waste time re-sampling duplicates of the same trace
    if strcmp(OutputStruct.Format,'Segments_LengthWeighting')
        OutputStruct = RemoveDuplicateSegmentsFromOutput(OutputStruct);   
    end    
    
    %For this clustering display style, we need the segment to be
    %resampled.  To save time, only do this once, now, and put the output
    %insdie the OutputStruct
    if strcmp(PlotStyle,'AverageTraceSegments')
        OutputStruct = GetResampledSegments(OutputStruct);
    end
    
    
    disp('---Extracting Clustering Solutions...---');
    
    Niter = length(peak_values);
    SizeTables = cell(Niter, 1);
    for i = 1:Niter
        eps = peak_values(i);
        [T] = ExtractAndPlotClustering(OutputStruct,eps,cutoff_fraction,...
            PlotNoise,PlotStyle);
        SizeTables{i} = T;
        disp([i Niter]);
    end   


end