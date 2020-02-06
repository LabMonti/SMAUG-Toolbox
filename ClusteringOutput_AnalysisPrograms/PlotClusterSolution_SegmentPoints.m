%09May2018 NDB: Plot a specific clustering solution based on the "Segment"
%format of clustering, but for the actual plotting, get the original trace
%points that each segment was fit to and plot those
function PlotClusterSolution_SegmentPoints(OutputStruct, Y, T, ...
    eps, ExSegs2Plot, PlotNoise)
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output
    %
    %Y: vector of cluster assignments for each point (in order of cluster
    %   order)
    %
    %T: array of cluster sizes (1st column: cluster ID, 2nd column: #
    %   points in cluster, 3rd column: fraction of points in cluster)
    %
    %eps: the value of epsilon at which extraction takes place; clusters
    %   will be valleys that exist below this cut-off value in the
    %   reachability plot
    %
    %ExSegs2Plot: # of segments per cluster to overlay on the plot as a way
    %   to show the "direction" of each cluster (to be chosen randomly)
    %
    %PlotNoise: logical variable, whether to visibly plot the noise cluster
    %   or not
    
    
    if nargin < 6
        PlotNoise = false;
    end
    if nargin < 5
        ExSegs2Plot = 0;
    end
    
    disp('Finding points represnted by segments...');

    order = OutputStruct.order;
    AllBounds = OutputStruct.AllBounds;
    SegmentTraceIDs = OutputStruct.SegmentTraceIDs;
    
    %Re-order data arrays to correspond to ordering of points in Y
    AllBounds = AllBounds(order,:);
    SegmentTraceIDs = SegmentTraceIDs(order,:);
    nSegs = size(AllBounds,1);
    
    %Calculate total # of data points:
    NumTotalPoints = 0;
    Ntraces = length(OutputStruct.TracesUsed);
    for i = 1:Ntraces
        %%%tr = OutputStruct.TracesUsed.(strcat('Trace',num2str(i)));
        tr = OutputStruct.TracesUsed{i};
        NumTotalPoints = NumTotalPoints + size(tr,1);
    end
    
    newOrder = (1:NumTotalPoints);
    
    %Make array to hold all trace data points, and a new version of Y to
    %indictae the cluster that each of those points belong to
    DataPoints = zeros(NumTotalPoints, 2);
    newY = zeros(NumTotalPoints, 1);
    
    %Loop over each segment, and add its points and their cluster
    %assignment to the appropriate arrays
    counter = 0;
    for i = 1:nSegs
        %Find the trace that the current segment belongs to
        TraceID = SegmentTraceIDs(i);
        %%%trace = OutputStruct.TracesUsed.(strcat('Trace',num2str(TraceID)));
        trace = OutputStruct.TracesUsed{TraceID};
        
        %Get all points in region this segment was fit to
        segPoints = trace(AllBounds(i,1):AllBounds(i,2),:);
        n = size(segPoints,1);
        
        %Add segment points to array of all points
        DataPoints(counter+1:counter+n,:) = segPoints;
        
        %All of these points get assigned to the cluster that the entire
        %segment was assigned to
        newY(counter+1:counter+n) = Y(i);
        
        counter = counter + n;
    end
    
    %Now we have equivalent results as if we had clustered raw 2D data
    %points, so use the program to plot the cluster output of that format!
    PlotClusterSolution_DataPoints(DataPoints,newOrder,newY,T,eps,'MixedHeatMaps',PlotNoise);    
    
    if ExSegs2Plot > 0
        OverlayExampleSegments(Y, PlotNoise, AllBounds, SegmentTraceIDs, ...
            OutputStruct.TracesUsed,ExSegs2Plot)
    end

end