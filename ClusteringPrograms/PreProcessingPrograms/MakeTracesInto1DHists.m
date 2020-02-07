function [OG_Traces, trace_1dhist_matrix, bin_centers] = ...
    MakeTracesInto1DHists(TraceStruct, binsper, minCond, maxCond, left_chop)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: takes a trace structure and turns it into a
    %matrix of 1d histograms for each individual trace.  
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a matlab structure containing log(G/G_0) vs. distance
    %   traces and associated information
    %
    %binsper: # of bins per to use per unit of log(G/G_0) (i.e. bins per
    %   decade)
    %
    %minCond/maxCond: minimum and maximum log(G/G_0) values to use; values
    %   outside this range will be discarded
    %
    %left_chop: the minimum distance value to use; traces will be
    %   chopped at this value and any distance points less than it will be
    %   discarded
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %OG_Traces: a cell array containing the original traces from the trace
    %   structure
    %
    %trace_1dhist_matrix: array of trace 1d histogram data; each row
    %   corresponds to a trace, each column corresponds to a specific bin, 
    %   and the elements correspond to bin counts
    %
    %bin_centers: vector containing the center value for each bin
    
    
    %First, lets collect all the original traces to store in the
    %output structure (so that they can be displayed in the clustering
    %solutions easily)
    TraceStruct = LoadTraceStruct(TraceStruct);
    Ntraces = TraceStruct.Ntraces;
    OG_Traces = TraceStruct.Traces;

    %Get # of bins to use:
    nBins = ceil((maxCond - minCond)*binsper); 
    
    %Make vector of bin centers:
    bin_centers = zeros(nBins, 1);
    stepSize = 1/binsper;
    bin_centers(1) = minCond + stepSize/2;
    for i = 2:nBins
        bin_centers(i) = bin_centers(i-1) + stepSize;
    end
    
    trace_1dhist_matrix = zeros(Ntraces, nBins);
    
    %Loop through each trace
    for i = 1:Ntraces
        %%%trace = TraceStruct.(strcat('Trace',num2str(i)));
        trace = TraceStruct.Traces{i};
        n = length(trace);
        %disp(n);
        
        %Loop through each conductance value in the trace and bin it
        for j = 1:n
            %Apply chop to points below a certain distance:
            if trace(j,1) > left_chop
                condValue = trace(j,2);
                binIndex = ceil((condValue - minCond)/(maxCond - minCond) * nBins);

                %disp([binIndex nBins]);
                %Count the bin if it falls within our range!
                if binIndex > 0 && binIndex < nBins + 1
                    trace_1dhist_matrix(i,binIndex) = trace_1dhist_matrix(i,binIndex) + 1;
                end
            end            
        end
    end

end
