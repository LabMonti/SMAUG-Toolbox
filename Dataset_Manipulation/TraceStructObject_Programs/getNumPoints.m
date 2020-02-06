function NumTotalPoints = getNumPoints(TraceStruct)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Finds the total # of data points in a trace 
    %structure by adding up the # of points in each trace
    %
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