function Plot_1D_DistHist_OverTime(TraceStruct, TracesPerChunk, ...
    linesper_y, binsper_x, StartTrace, EndTrace, UpperCondChop, NormByTrace)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Breaks up a data set into "chunks" of 
    %consecutive traces, then overlays the 1D distance histograms for each 
    %chunk to see if there is any systematic drift over time
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %TracesPerChunk: number of traces to include in each chunk
    %
    %the # of horizontal resampling lines to use per unit on
    %   the y-axis
    %
    %binsper_x: how many bins to user per unit on the x-axis (Distance)
    %
    %StartTrace/EndTrace: First/last trace to include in processing
    %
    %UpperCondChop: the portions of traces with conductances above this
    %   value will be removed prior to processing. Can be set to '[]' to
    %   not use any conductance chop.  In units of G_0, NOT logged!
    %
    %NormByTrace: logical variable; whether or not to normalize counts by #
    %   of traces
    
    
    TraceStruct = LoadTraceStruct(TraceStruct);
    Ntraces = TraceStruct.Ntraces;
    
    %Default inputs
    if nargin < 8
        NormByTrace = true;
    end
    if nargin < 7
        UpperCondChop = [];
    end
    if nargin < 6 || strcmp(EndTrace, 'max')
        EndTrace = Ntraces;
    end
    if nargin < 5
        StartTrace = 1;
    end
    if nargin < 4
        binsper_x = 40;
    end
    if nargin < 3
        linesper_y = 50;
    end
    if nargin < 2
        TracesPerChunk = 250;
    end
    
    %Get list of trace structures for each chunk:
    [TS_List, chunk_names] = chunkTraceStruct(TraceStruct, TracesPerChunk, ...
        StartTrace, EndTrace);
    
    %Take advantage of previously existing program to plot 1D distance
    %histograms on top of each other:
    Plot_Overlaid_1DDistanceHistograms(TS_List, linesper_y, binsper_x,...
        UpperCondChop,NormByTrace,chunk_names);
    
    title(strcat('1D Dist. Hist. Over Time For:', {' '}, TraceStruct.name),...
        'Interpreter', 'none');

end