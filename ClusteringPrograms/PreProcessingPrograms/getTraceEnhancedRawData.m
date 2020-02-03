%04May18 NDB: this program takes in a trace structure and cretaes a single
%array of all data points which also includes a third column with, for each
%point, the best-fit slope of the points to either side of that point in
%the trace it comes from (thus adding in a dash of 'non-local' information
%to the raw data points)
function Xdata = getTraceEnhancedRawData(TraceStruct, slope_window, ...
    left_chop)
    %~~~INPUTS~~~:
    %
    %TraceStruct: a matlab structure containing log(G/G_0) vs. distance
    %   traces and associated information
    %
    %slope_window: the # of points to be used when calculating the local
    %   slope of each trace at each data point
    %
    %left_chop: the minimum distance value to use; traces will be
    %   chopped at this value and any distance points less than it will be
    %   discarded
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %Xdata: a 3-column array containing all data points from all traces,
    %   with distance in the first column and log(G/G_0) in the second, and
    %   an estimate of the local slope of the trace at each data point in
    %   the third column
    
    
    window_half_width = floor(slope_window / 2);
    Ntraces = TraceStruct.Ntraces;
    
    %Find total # of data points
    N = TraceStruct.NumTotalPoints;
    
    %Now create data set that will be used (dist, cond,
    %slope estimate)
    Xdata = zeros(N, 3);
    counter = 0;
    for i = 1:Ntraces
        %%%tr = TraceStruct.(strcat('Trace',num2str(i)));
        tr = TraceStruct.Traces{i};
        M = length(tr);

        for j = 1+window_half_width:M - window_half_width
            counter = counter + 1;
            Xdata(counter, 1) = tr(j,1);
            Xdata(counter, 2) = tr(j,2);

            %Find slope of best-fit line through neighboring data
            temp_data = tr(j-window_half_width:j+window_half_width, :);
            temp_covar = cov(temp_data(:,1),temp_data(:,2));
            Xdata(counter,3) = temp_covar(1,2)/temp_covar(1,1);
        end

    end
    clear tr temp_data temp_covar
    Xdata = Xdata(1:counter, :);

    %Cut off data with distances less than left_chop
    Xdata = Xdata(Xdata(:,1) > left_chop, :);

    %Remove points below noise floor
    if isfield(TraceStruct,'NoiseFloor')
        nf = log10(TraceStruct.NoiseFloor);
    else
        nf = -6; %default value
    end
    Xdata = Xdata(Xdata(:,2) > nf, :);

    %Remove data with undefined slope dimension
    Xdata = Xdata(isfinite(Xdata(:,3)), :);

end
