%NDB 16Aug18: Finds the total # of data points in a trace structure by
%adding up the # of points in each trace
function NumTotalPoints = getNumPoints(TraceStruct)
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %NumTotalPoints: the total # of data points in all the traces within
    %   the trace structure
    
    
    Ntraces = TraceStruct.Ntraces;
    NumTotalPoints = 0;
    
    for i = 1:Ntraces
        tr = TraceStruct.Traces{i};
        %%%tr = TraceStruct.(strcat('Trace',num2str(i)));
        NumTotalPoints = NumTotalPoints + size(tr,1);
    end

end