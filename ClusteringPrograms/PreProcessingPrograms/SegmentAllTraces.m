function [AllSegments,AllBounds,nSegments,TraceIDs,TracesUsed] = ...
    SegmentAllTraces(TraceStruct,EvalType,left_chop,cond_ceil,ToPlot,pool)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: segments all traces in a dataset using my 
    %"optimal" segmenatation algorithm
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %EvalType: a string choosing the error metric to be used by the
    %   iterative L-Method; either "TotalError" or "ErrorGain"
    %
    %left_chop: data points in each trace that fall to the left of this
    %   value will be removed prior to segmentation
    %
    %cond_ceil: data points in each trace that fall above this conductance
    %   value (in units of G_0, not logged) will be removed prior to
    %   segmentation
    %
    %ToPlot: logical variable, whether or not to plot all the final
    %   segments on top of each other
    %
    %pool: a parallel pool that can be used to speed up trace segmentation
    %   (if passed in as an empty list, segmentation will not be
    %   parallelized)
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %AllSegments: an array holding the x- and y- endpoint values for all
    %   segments
    %
    %AllBounds: an array listing the starting and ending trace-point 
    %   indices for all segments
    %
    %nSegments: a vector specifying the # of segments that each trace was
    %   split into
    %
    %TraceIDs: a vector with one element per segment, with that element
    %   listing the ID# of the trace to which the segment belongs
    %
    %TracesUsed: a cell array containing the traces that were segmented in
    %   the form they were in just before segmentation 
    
    
    if nargin < 2
        EvalType = 'ErrorGain';
    end
    if nargin < 3
        left_chop = -Inf;
    end
    if nargin < 4
        cond_ceil = Inf;
    end
    if nargin < 5
        ToPlot = false;
    end
    if nargin < 6
        pool = [];
    end

    %Load trace structure and make sure the distance is in linear space and
    %the conductance is in logarithmic space:
    TraceStruct = LoadTraceStruct(TraceStruct);
    TraceStruct.convertTraces('Lin','Log');
    
    Ntraces = TraceStruct.Ntraces;
    segs_storage = cell(Ntraces,1);
    bounds_storage = cell(Ntraces,1);
    nSegments = zeros(Ntraces,1);
    
    %Chop traces the first time they cross the noise floor, and also apply
    %the top and left chops
    TraceStruct.convert_to_ChopFirstCross();
    TraceStruct.chopAtConductanceCeiling(log10(cond_ceil));
    TraceStruct.apply_LeftChop(left_chop, true);
    Ntraces = TraceStruct.Ntraces; %Re-grap # of traces in case any were removed by left chop
    TracesUsed = TraceStruct.Traces;
    
    %Segment all the traces!
    if isempty(pool)
        for i = 1:Ntraces
            trace = TracesUsed{i};
            
            [segments, bounds] = OptimalSegmentation(trace,EvalType,false);
            n = size(segments,1);
            nSegments(i) = n;  
            segs_storage{i} = segments;
            bounds_storage{i} = bounds;
            
            if mod(i, 64) == 0
                disp([i Ntraces n]);
            end    
        end
    else
        parfor i = 1:Ntraces
            trace = TracesUsed{i};
            
            [segments, bounds] = OptimalSegmentation(trace,EvalType,false);
            n = size(segments,1);
            nSegments(i) = n;  
            segs_storage{i} = segments;
            bounds_storage{i} = bounds;
            
            if mod(i, 64) == 0
                disp([i Ntraces n]);
            end    
        end        
    end
    
    %Now, unpack the stored segments and bounds into one array each, and 
    %make a vector storing the trace ID of each segment:
    nSegTotal = sum(nSegments);
    AllSegments = zeros(nSegTotal, 4);
    AllBounds = zeros(nSegTotal, 2);
    TraceIDs = zeros(nSegTotal,1);  
    counter = 0;
    for i = 1:Ntraces
        n = nSegments(i);
        
        AllSegments(counter+1:counter+n,:) = segs_storage{i};
        AllBounds(counter+1:counter+n,:) = bounds_storage{i};
        TraceIDs(counter+1:counter+n,:) = i;
        
        counter = counter + n;
    end
    
%     %Turn TracesUsed from a cell array into a structure (for compatibility
%     %purposes; eventually, this should be removed since the cell array is
%     %faster)
%     TracesUsed = struct();
%     TracesUsed.Ntraces = Ntraces;
%     for i = 1:Ntraces
%         TracesUsed.(strcat('Trace',num2str(i))) = TracesUsedcell{i};
%     end
    
    %Plot all segments on top of each other
    if ToPlot
        figure();
        hold on;
        for i = 1:nSegTotal
            line(AllSegments(i,1:2),AllSegments(i,3:4));
        end
    end

end
