%13Sep18 NDB: Breaks up a data set into "chunks" of consecutive traces,
%then overlays the 1D conductance histograms for each chunk to see if there
%is any systematic drift over time
function Conductance1DHist_OverTime(TraceStruct, TracesPerChunk, binsper_x, ...
    LinLog, StartTrace, EndTrace, NormByTrace)
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %TracesPerChunk: number of traces to include in each chunk
    %
    %binsper_x: how many bins to user per unit on the x-axis (Conductance)
    %
    %LinLog: Whether the x-axis (Conductance) should be on a linear or
    %   logarithmic scale; acceptable values are "Lin" and "Log"
    %
    %StartTrace/EndTrace: First/last trace to include in processing
    %
    %NormByTrace: logical variable; whether or not to normalize counts by #
    %   of traces


    Ntraces = TraceStruct.Ntraces;
    
    if nargin < 7
        NormByTrace = true;
    end
    if nargin < 6
        EndTrace = Ntraces;
    end
    if nargin < 5
        StartTrace = 1;
    end
    if nargin < 4
        LinLog = 'Log';
    end
    if nargin < 3
        binsper_x = 40;
    end
    if nargin < 2
        TracesPerChunk = 250;
    end
    
    if EndTrace > Ntraces || StartTrace < 1 || StartTrace > EndTrace
        error('Start and End Trace ID#s do not make sense!');
    end
    if TracesPerChunk + 1 > Ntraces
        error('Chunk size too large');
    end
    
    %Get a list of trace structs corresponding to each chunk
    [TS_List, chunk_names] = chunkTraceStruct(TraceStruct, ...
        TracesPerChunk, StartTrace, EndTrace);
    
    %Take advantage of previously existing program to plot 1D conductance
    %histograms on top of each other:
    Plot_Overlaid_1DConductanceHistograms(TS_List, binsper_x, LinLog, ...
        NormByTrace, chunk_names);
    
    title(strcat('1D Cond. Hist. Over Time For:', {' '}, TraceStruct.name),...
        'Interpreter', 'none');

end