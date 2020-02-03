%NDB 21May19: Given a segment clustering solution, get all data points
%corresponding to a particular cluster in a particular clustering solution
function [peak, error, halfwidth] = SegmentCluster_to_1DHist(OutputStruct, epsilon, ...
    cutoff_frac, cluster_num, ToPlot)

    if nargin < 5
        ToPlot = false;
    end

    [Y,~,~] = ExtractClusterSolution(OutputStruct.RD,OutputStruct.CD,epsilon,...
        cutoff_frac);
    
    %Remove duplicates if necessary
    if strcmp(OutputStruct.Format, 'Segments_LengthWeighting')
        Y = RemoveDuplicateSegmentsFromY(Y,OutputStruct);
        OutputStruct = RemoveDuplicateSegmentsFromOutput(OutputStruct);
    end
    
    Traces = OutputStruct.TracesUsed;
    
    %Get bounds and TraceIDs and put them in the same order as Y
    order = OutputStruct.order;
    TraceIDs = OutputStruct.SegmentTraceIDs(order);
    Bounds = OutputStruct.AllBounds(order,:);
    
    %Keep just the traces and bounds of the cluster we are looking for
    TraceIDs = TraceIDs(Y == cluster_num);
    Bounds = Bounds(Y == cluster_num,:);
    
    Nmax = length(Traces)*15000;
    
    AllCondData = zeros(Nmax,1);
    counter = 0;
    for i = 1:length(TraceIDs)
        n = Bounds(i,2) - Bounds(i,1) + 1;
        AllCondData(counter+1:counter+n) = Traces{TraceIDs(i)}(Bounds(i,1):Bounds(i,2),2);
        counter = counter + n;
    end
    AllCondData = AllCondData(1:counter);
    
    [peak, error, halfwidth] = fit_histogram_peak(AllCondData,1,'algorithm',ToPlot);

end
