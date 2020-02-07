function OutputStruct = GetResampledSegments(OutputStruct)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: For an output file from segment clustering, 
    %re-samples all segments using a single grid of x-values and store the
    %re-sampled segments back inside the OutputStruct
    %
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output; clustering
    %   format must have been segment clustering
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %OutputStruct: same as the OutputStruct in the inputs, but with fields
    %   added to store the resampled segments (in a single big matrix), the
    %   grid of x-values all the points were re-sampled at, and which
    %   regions of that big matrix hold data
    
    
    disp('Re-sampling all trace segments...');

    %Calculate total # of data points:
    NumTotalPoints = 0;
    Ntraces = length(OutputStruct.TracesUsed);
    for i = 1:Ntraces
        %%%tr = OutputStruct.TracesUsed.(strcat('Trace',num2str(i)));
        tr = OutputStruct.TracesUsed{i};
        NumTotalPoints = NumTotalPoints + size(tr,1);
    end
    
    %Find typical xstep distance and min/max x-distances (to be used for 
    %re-sampling)
    AllDiffs = zeros(NumTotalPoints,1);
    minX = Inf;
    maxX = -Inf;
    counter = 0;
    for i = 1:Ntraces
        %%%tr = OutputStruct.TracesUsed.(strcat('Trace',num2str(i)));
        tr = OutputStruct.TracesUsed{i};
        n = size(tr,1);
        
        diffs = tr(2:n,1) - tr(1:n-1,1);
        AllDiffs(counter+1:counter+n-1) = diffs;
        counter = counter + n-1;
        
        if tr(1,1) < minX
            minX = tr(1,1);
        end
        if tr(n,1) > maxX
            maxX = tr(n,1);
        end
    end
    AllDiffs = AllDiffs(1:counter);
    xStep = median(AllDiffs)*10; %Temporary kludge?  Increase step size to speed up

    AllBounds = OutputStruct.AllBounds;
    SegmentTraceIDs = OutputStruct.SegmentTraceIDs;
    nSegs = size(AllBounds,1);
    
    %Make big matrix to hold all segments aligned with each other after
    %resampling
    nXvals = ceil((maxX - minX)/xStep) + 5;
    AlignedSegments = Inf(nSegs, nXvals);
    ActiveRegions = zeros(nSegs, 2);
    
    %Get vector of the x-values at which we need to resample
    Xdist = zeros(nXvals,1);
    for i = 1:nXvals
        Xdist(i) = minX + (i-1)*xStep;
    end
    
    %Fill up AlignedSegments by resampling each trace segment:
    for i = 1:nSegs
        %Find the trace that the current segment belongs to
        TraceID = SegmentTraceIDs(i);
        %%%trace = OutputStruct.TracesUsed.(strcat('Trace',num2str(TraceID)));
        trace = OutputStruct.TracesUsed{TraceID};
        
        %Get all points in region this segment was fit to
        segment = trace(AllBounds(i,1):AllBounds(i,2),:);
        n = size(segment,1);
        
        %Find starting and ending lattice x-value indices at which to 
        %re-sample
        xStartIndex = ceil((segment(1,1) - minX)/xStep) + 1;
        xEndIndex = floor((segment(n,1) - minX)/xStep) + 1;
        ActiveRegions(i,:) = [xStartIndex xEndIndex];
        
        %Resample at all relevant x-values, store answers in
        %AlignedSegments matrix
        for j = xStartIndex:xEndIndex
            AlignedSegments(i,j) = LinearInterpolation(segment, Xdist(j));
        end
        
        if mod(i,512) == 0
            disp([i nSegs]);
        end
        
    end

    OutputStruct.AlignedSegments = AlignedSegments;
    OutputStruct.Xdist = Xdist;
    OutputStruct.ActiveRegions = ActiveRegions;
    
end