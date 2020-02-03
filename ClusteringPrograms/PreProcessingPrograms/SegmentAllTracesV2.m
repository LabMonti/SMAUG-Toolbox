%11May18 NDB: segments all traces in a dataset using my "optimal"
%segmenatation algorithm
function [AllSegments,AllBounds,nSegments,TraceIDs,TracesUsed] = ...
    SegmentAllTracesV2(TraceStruct,EvalType,ToPlot,pool)
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %EvalType: a string choosing the error metric to be used by the
    %   iterative L-Method; either "TotalError" or "ErrorGain"
    %
    %ToPlot: logical variable, whether or not to plot all the final
    %   segments on top of each other
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
    %TracesUsed: a structure containing the traces that were segmented in
    %   the form they were in just before segmentation 
    
    
    if nargin < 2
        EvalType = 'ErrorGain';
    end
    if nargin < 3
        ToPlot = false;
    end
    if nargin < 4
        pool = [];
    end

    Ntraces = TraceStruct.Ntraces;
    segs_storage = cell(Ntraces,1);
    bounds_storage = cell(Ntraces,1);
    nSegments = zeros(Ntraces,1);
    
    if isfield(TraceStruct,'NoiseFloor')
        NoiseFloor = log10(TraceStruct.NoiseFloor);
    else
        NoiseFloor = -6;
    end
    
    %First, cut off all traces below noise floor.  Save traces in a cell
    %array in the form they will be segmented in.  
    TracesUsed = cell(Ntraces,1);
    for i = 1:Ntraces
        %%%trace = TraceStruct.(strcat('Trace',num2str(i)));
        trace = TraceStruct.Traces{i};
        
        %Remove pieces of trace below noise floor: (best option???)
        trace = trace(trace(:,2) > NoiseFloor, :);
        
        %Save trace in the form that it was used:
        TracesUsed{i} = trace;        
    end
    
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
    
    %Plot all segments on top of each other
    if ToPlot
        figure();
        hold on;
        for i = 1:nSegTotal
            line(AllSegments(i,1:2),AllSegments(i,3:4));
        end
    end

end
