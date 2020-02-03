%NDB 18Dec19: Function to re-sample all traces in a dataset at evenly space
%points along the distance axis
function TraceStruct = EvenlyResampleTraces(TraceStruct, new_deltaX)

    TraceStruct = LoadTraceStruct(TraceStruct);
    Ntraces = TraceStruct.Ntraces;
    
    new_TotalPoints = 0;
    for i = 1:Ntraces
        t = TraceStruct.Traces{i};
        
        %We need to remove duplicate x-values from the trace
        [Xold,iX,~] = unique(t(:,1));
        Yold = t(iX,2);
        n = length(Xold);
        
        %Re-sample at evenly spaced x-values
        newX = (Xold(1):new_deltaX:Xold(n))';
        newY = interp1(Xold,Yold,newX);
        
        %Save new trace and update # of total points
        TraceStruct.Traces{i} = [newX,newY];
        new_TotalPoints = new_TotalPoints + length(newX);
    end
    TraceStruct.NumTotalPoints = new_TotalPoints;

    TraceStruct = UnLoadTraceStruct(TraceStruct);
end