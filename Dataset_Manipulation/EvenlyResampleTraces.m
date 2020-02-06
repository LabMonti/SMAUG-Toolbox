function TraceStruct = EvenlyResampleTraces(TraceStruct, new_deltaX)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: re-samples all traces in a dataset at evenly 
    %spaced points along the distance axis (using linear interpolation)
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing a set of traces and all
    %   associated information
    %
    %new_deltaX: the interval along the inter-electrode distance axis that
    %   will separate each point in the newly re-sampled traces.  Should be
    %   in the same units as the trace distance values are in (typically
    %   nm)
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %TraceStruct: output trace structure in which each trace has been
    %   re-sampled at evenly spaced points
    
    
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