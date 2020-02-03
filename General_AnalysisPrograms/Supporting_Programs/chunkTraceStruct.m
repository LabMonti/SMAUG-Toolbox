%14Sep18 NDB: Given a trace structure, produce a list of trace structures
%corresponding to consecutive "chunks" of the same number of traces from
%that structure
function [TS_List, chunk_names] = chunkTraceStruct(TraceStruct, ...
    TracesPerChunk, StartTrace, EndTrace)
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %TracesPerChunk: number of traces to include in each chunk
    %
    %StartTrace/EndTrace: First/last trace to include in the chunked output
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %TS_List: a 1D cell array containing a TraceStruct in each cell
    %   corresponding to the consecutive chunks of the input TraceStruct
    %
    %chunk_names: a 1D cell array with the names of the traces included in
    %   each chunk
    
    
    TraceStruct = LoadTraceStruct(TraceStruct);
    Ntraces = TraceStruct.Ntraces;
    
    if nargin < 4
        EndTrace = Ntraces;
    end
    if nargin < 3
        StartTrace = 1;
    end
    
    if EndTrace > Ntraces || StartTrace < 1 || StartTrace > EndTrace
        error('Start and End Trace ID#s do not make sense!');
    end
    if TracesPerChunk + 1 > Ntraces
        error('Chunk size too large');
    end
    
    %Extract the subsection to be used, if not the whole data set:
    if EndTrace ~= Ntraces || StartTrace ~= 1
        TraceStruct = GetTraceStructSubsections(TraceStruct, [StartTrace EndTrace]);
        Ntraces = TraceStruct.Ntraces;
    end
    
    %Get boundaries of each chunk, in Trace ID #s:
    StartingPoints = (1:TracesPerChunk:Ntraces)';
    EndingPoints = (TracesPerChunk:TracesPerChunk:Ntraces)';
    
    if EndingPoints(length(EndingPoints)) ~= Ntraces
        EndingPoints = [EndingPoints; Ntraces];
    end
    
    Bounds = [StartingPoints, EndingPoints];
    nBounds = size(Bounds,1);
    
    %Construct names for each chunk:
    chunk_names = cell(nBounds,1);
    for i = 1:nBounds
        a = strcat('Traces',{' '},num2str(Bounds(i,1) + StartTrace - 1),...
            '-',num2str(Bounds(i,2) + StartTrace - 1));
        chunk_names{i} = a{1};
    end
    
    %Kind of a kludge; even if the trace structure IS a combo, I need to
    %pretend that it's not so that the GetTraceStructSubsections program
    %doesn't split up subsections at combo bounds.  Since TraceStruct isn't
    %being saved out from this program, this shouldn't be a big deal.  
    TraceStruct.combo = 'no';
    
    %Now, take advantage of programs that already exist to get a trace
    %structure for each chunk:
    SubSections = GetTraceStructSubsections(TraceStruct, Bounds);
    SubSections = LoadTraceStruct(SubSections);
    TS_List = get_TSO_combo_components(SubSections);

end