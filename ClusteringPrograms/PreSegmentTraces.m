%11May18 NDB: Segment all traces in a data set and store the relevant
%information in a structure that can be input into the clustering program
%(the point of this shortcut is to save time so that a single data set can
%be segmented just once, because segmentation is slow, and then clustered
%many times without having to re-segment).  
function PreSegmentedTraceStruct = PreSegmentTraces(TraceStruct,EvalType,...
    left_chop, cond_ceil, nCores)
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
    %nCores: number of cores to be used for parallelization; set to 1 for
    %not parallelization.  
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %PreSegmentedTraceStruct: a structure containing the segmented traces
    %   that can be used as an input data file for the clustering program
    %   in the "Segments_PreSegmented" clustering mode
    
    
    %Default inputs
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
        nCores = 1;
    end
    
    %Create pool if requested
    if nCores > 1
        %Start parallel pool
        pc = parcluster('local');
        pool = parpool(pc,nCores);
        pool.IdleTimeout = 600;
    else
        pool = [];
    end
    
    %Segment all traces using "optimal" algorithm
    disp('Begin segmenting traces...');
    [AllSegments,AllBounds,~,TraceIDs,TracesUsed] = ...
        SegmentAllTraces(TraceStruct,EvalType,left_chop,cond_ceil,0,pool);

    %Save relevant output in a structure that can be clustered
    PreSegmentedTraceStruct = struct();
    PreSegmentedTraceStruct.AllSegments = AllSegments;
    PreSegmentedTraceStruct.AllBounds = AllBounds;
    PreSegmentedTraceStruct.TraceIDs = TraceIDs;
    PreSegmentedTraceStruct.TracesUsed = TracesUsed;
    
    %Delete pool if it was created
    if ~isempty(pool)
        delete(pool);
    end

end