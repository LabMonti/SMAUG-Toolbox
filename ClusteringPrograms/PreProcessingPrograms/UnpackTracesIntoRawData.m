%04May2018 NDB: The program takes in a trace structure and "unpacks" all
%the traces to combine their data into a single array. If a noise floor is
%defined in the trace structure then points below it will be thrown out;
%points left of the left_chop value will also be thrown out.  
function Xdata = UnpackTracesIntoRawData(TraceStruct, left_chop)
    %~~~INPUTS~~~:
    %
    %TraceStruct: a matlab structure containing log(G/G_0) vs. distance
    %   traces and associated information
    %
    %left_chop_nm: the minimum distance value to use; traces will be
    %   chopped at this value and any distance points less than it will be
    %   discarded
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %Xdata: a two-column array containing all data points from all traces,
    %with distance in the first column and log(G/G_0) in the second

    Ntraces = TraceStruct.Ntraces;

    %Get total # of data points
    NumTotalPoints = TraceStruct.NumTotalPoints;

    %Make array for all data points and fill it up
    Xdata = zeros(NumTotalPoints, 2);
    counter = 0;
    for i = 1:Ntraces
        %%%tr = TraceStruct.(strcat('Trace',num2str(i)));
        tr = TraceStruct.Traces{i};
        ncurr = size(tr,1);
        Xdata(counter + 1:counter + ncurr, :) = tr;
        counter = counter + ncurr;
    end

    %Chop below noise floor, if it is defined
    if isfield(TraceStruct,'NoiseFloor')
        nf = log10(TraceStruct.NoiseFloor);
        Xdata = Xdata(Xdata(:,2) > nf, :);
    end
    
    %Chop distance values less than left_chop
    Xdata = Xdata(Xdata(:,1) > left_chop, :); 

end
