%04Jun19 NDB: Given a segment structure and a list of trace IDs, create a
%new segment structure containing only the segments from the specified
%traces
function SubStr = pull_segment_subset(SegStr, IDs_to_pull)

    %Create ID library and nSegs
    nTraces = length(SegStr.TracesUsed);
    nSegs = histc(SegStr.TraceIDs,(1:nTraces));
    IDlibrary = cell(nTraces,1);
    counter = 0;
    ints = (1:length(SegStr.TraceIDs));
    for j = 1:nTraces
        IDlibrary{j} = ints(counter+1:counter+nSegs(j));
        counter = counter + nSegs(j);
    end

    %New number of traces and of segments
    n = length(IDs_to_pull);
    N = sum(nSegs(IDs_to_pull));
    
    SubStr = struct();
    %Array to hold info for subset structure
    AllSegments = zeros(N,4);
    AllBounds = zeros(N,2);
    TraceIDs = zeros(N,1);
    TracesUsed = cell(n,1);
    
    counter = 0;
    for i = 1:n
        TracesUsed{i} = SegStr.TracesUsed{IDs_to_pull(i)};
        ns = nSegs(IDs_to_pull(i));
        
        AllSegments(counter+1:counter+ns,:) = SegStr.AllSegments(IDlibrary{IDs_to_pull(i)},:);
        AllBounds(counter+1:counter+ns,:) = SegStr.AllBounds(IDlibrary{IDs_to_pull(i)},:);
        
        TraceIDs(counter+1:counter+ns) = i;
        
        counter = counter + ns;        
    end
    
    SubStr.AllSegments = AllSegments;
    SubStr.AllBounds = AllBounds;
    SubStr.TraceIDs = TraceIDs;
    SubStr.TracesUsed = TracesUsed;

end