%12Sep18 NDB: Chop all traces before the last time they cross below the
%conductance value G_ChopValue (assumed to be in the same units at the
%conductance values in the traces)
function Traces = choptraces_aboveCondValue(Traces, G_ChopValue,ToPlot)
    %~~~INPUTS~~~:
    %
    %Traces: a 1D cell array containing one trace (2D array) per cell
    %
    %G_ChopValue: the points in each trace up until the last time the trace
    %   crosses below this value will be removed.  Is assummed to be in the
    %   same units/space (e.g. linear vs. logarithmic) as the traces
    %
    %ToPlot: logical variable, whether or not to make a plot showing the
    %   percentage of points removed from each trace

    if nargin < 3
        ToPlot = false;
    end
    
    Ntraces = length(Traces);
    percentage_removed = zeros(Ntraces, 1);
    
    %Go through and chop all traces
    for i = 1:Ntraces
        trace = Traces{i};
        n = size(trace,1);
        
        %Walk through the trace backwards, looking for the first time (i.e
        %the last time) there is a conductance value above G_chopValue
        found_last_cross = false;
        j = n;
        while j >= 1 && ~found_last_cross
            if trace(j,2) > G_ChopValue
                found_last_cross = true;
            else
                j = j - 1;
            end
        end
        percentage_removed(i) = j/n * 100;
        
        %If the trace crossed above G_chop, remove those values
        if found_last_cross
            trace = trace(j+1:n,:);
            Traces{i} = trace;
        end
         
    end
    
    if ToPlot
        figure();
        plot(percentage_removed);
        xlabel('Trace #');
        ylabel('%-age of Points Removed');
        title('Points Removed by Conductance Ceiling Chop:');
    end

end