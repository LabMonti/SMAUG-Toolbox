function [counts, centers] = DisplacementHistogram_AtCut(TraceStruct, ...
    CondCut, binsper_x, StartTrace, EndTrace, Normalize, ToPlot)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Makes a histogram of the distances at which each
    %   trace LAST reaches a particular conductance
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %CondCut: the conductance value (NOT on a logarithmic scale!) at which
    %   to find trace distances
    %
    %binsper_x: how many bins to use per unit on the x-axis (i.e.
    %   inter-electrode distance)
    %
    %StartTrace/EndTrace: First/last trace to include in processing
    %
    %Normalize: logical variable; whether or not to normalize # of traces
    %   to probability density
    %
    %ToPlot: logical variable; whether or not to make a visible plot
    
    
    %Load in trace structure
    TraceStruct = LoadTraceStruct(TraceStruct);
    
    Ntraces = TraceStruct.Ntraces;
    if nargin < 7
        ToPlot = true;
    end
    if nargin < 6
        Normalize = false;
    end
    if nargin < 5 || strcmp(EndTrace,'max')
        EndTrace = Ntraces;
    end
    if nargin < 4
        StartTrace = 1;
    end
    if nargin < 3
        binsper_x = 'algorithm';
    end
    if nargin < 2
        CondCut = 10^(-5.75);
    end
    
    
    %Convert CondCut to logarithmic scale
    CondCut = log10(CondCut);
    
    %Make sure distance is in linear space and
    %conductance is in logarithmic space
    TraceStruct.convertTraces('Lin', 'Log');

    Ntraces_used = EndTrace - StartTrace + 1;
    
    cross_distances = zeros(Ntraces_used, 1);
    counter = 0;
    
    %Go through all traces and find where the trace cross the conductance
    %cut
    for i = StartTrace:EndTrace
        
        trace = TraceStruct.Traces{i};
        
        %Find the first time the trace passes below the conductance cut
        a = find(trace(:,2) < CondCut, 1, 'first');
        
        %If the trace truly did pass below the conductance cut, interpolate
        %to find the distance at which it crossed
        if ~isempty(a)
            counter = counter + 1;
            
            %Get bracketing x-values
            x1 = trace(a-1,1);
            x2 = trace(a,1);
            
            %Get bracketing y-values
            y1 = trace(a-1,2);
            y2 = trace(a,2);
            
            %Linearly interpolate
            if y2 == y1
                cross_distances(counter) = (x1 + x2)/2;
            else
                cross_distances(counter) = (x1*(y2 - CondCut) + x2*(CondCut-y1))/(y2 - y1);
            end
        end
        
    end
    cross_distances = cross_distances(1:counter);
    
    %Report if any trace never crossed
    n_missing = Ntraces_used - counter;
    if n_missing > 0
        disp(strcat(num2str(n_missing), ' traces (',num2str(n_missing/...
            Ntraces_used * 100),'%) never crossed conductance cut'));
    end
    
    %Default # of bins based on "IQR rule"
    if strcmp(binsper_x, 'algorithm')
        width = 2 * iqr(cross_distances) * size(cross_distances,1)^(-1/3);
        binsper_x = 1/width;
        disp(strcat('Using',{' '},num2str(binsper_x),' bins per x-unit'));
    end
    
    nbins = round(range(cross_distances)*binsper_x);
       
    [counts, centers] = hist(cross_distances, nbins);
    
    %Normalize # of traces to probability density
    if Normalize
        counts = binsper_x * counts/sum(counts);
    end
    
    if ToPlot
        figure();
        [x,y] = convert_to_histogram_endpoints(centers, counts);
        plot(x,y);

        xlabel('Inter-Electrode Distance (nm)');
        if Normalize
            ylabel('Probability Density');
        else
            ylabel('# of Traces');
        end
        title(strcat('Position of Last Cross of', {' '}, num2str(10^CondCut),...
            ' G_0'));
    end

end