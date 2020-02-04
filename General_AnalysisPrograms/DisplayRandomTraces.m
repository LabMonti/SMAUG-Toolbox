function DisplayRandomTraces(TraceStruct, nDisp, offset_nm, LinLog, ...
    StartTrace, EndTrace)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Randomly selects traces from a dataset and plots
    %them on the same plot.  
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %nDisp: the # of traces to randomly select
    %
    %offset_nm: the amount (in the units of x, typically nanometers) that
    %   each trace will be shifted to the right by relative to the previous
    %   trace
    %
    %LinLog: Whether the y-axis (Conductance) should be on a linear or
    %   logarithmic scale; acceptable values are "Lin" and "Log"
    %
    %StartTrace: the # of the first trace in the data set to use, if the
    %   user wants to only use a subset of the data
    %
    %EndTrace: the # of the last trace in the data set to use, if the
    %   user wants to only use a subset of the data
    
    
    TraceStruct = LoadTraceStruct(TraceStruct);
    Ntraces = TraceStruct.Ntraces;

    %Default inputs
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
        offset_nm = 0.25;
    end
    if nargin < 2
        nDisp = 5;
    end
    if nargin < 1 || nargin > 6
        error('Incorrect # of input parameters');
    end

    if ~strcmp(LinLog,'Log') && ~strcmp(LinLog,'Lin')
        error('The parameter "LinLog" can only have the values "Lin" or "Log"');
    end    
    
    %Get nDisp random integers between StartTraceNum and EndTraceNum
    ChosenTraceIndices = randsample((EndTrace - StartTrace + 1), nDisp);
    ChosenTraceIndices = ChosenTraceIndices + StartTrace - 1;
    ChosenTraceIndices = sort(ChosenTraceIndices);

    displayTraces(TraceStruct,ChosenTraceIndices,offset_nm,LinLog);

end