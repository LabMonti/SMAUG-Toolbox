function TraceStruct = AlignAllTraces(TraceStruct,GAlign)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: aligns BREAKING traces so that all their 1G0
    %drop-offs occur at zero distance.  This is accomplished by shifting
    %each trace so that the LAST time it crosses a given conductance value
    %(determined via linear interpolation) is shifted to zero
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: trace structure containing all traces in dataset to be
    %   aligned
    %
    %GAlign: a conductance value in units of G0 (NOT logged).  The last
    %   time each trace crosses this conductance value will be shifted to
    %   zero distance
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %TraceStruct: Same as input trace structure but with all traces
    %   re-aligned
    
    
    TraceStruct = LoadTraceStruct(TraceStruct);
    Ntraces = TraceStruct.Ntraces;
    
    if TraceStruct.y_Log
        GAlign = log10(GAlign);
    end
    
    %Keep track of which traces to keep
    keep = true(Ntraces,1);

    for i = 1:Ntraces
        
        trace = TraceStruct.Traces{i};
        n = size(trace,1);
        
        %Frist, find the LAST point in the trace that is above G_Align
        index = n;
        above = false;
        while ~above && index > 1
            
            value = trace(index,2);
            if value > GAlign
                above = true;
            else
                index = index - 1;
            end
            
        end
        
        if index == 0 || index == n
            keep(i) = false;
        else
            %Use linear interpolation to get x-value at which trace crosses
            %G_Align after index
            slope = (trace(index+1,2) - trace(index,2)) / (trace(index+1,1) - trace(index,1));
            x_cross = (GAlign - trace(index,2)) / slope + trace(index,1);

            %Shift all x-values in trace and re-save:
            trace(:,1) = trace(:,1) - x_cross;
            TraceStruct.Traces{i} = trace; 
        end
        
    end
    
    %Remove traces if necessary
    if sum(keep) < Ntraces
        disp(strcat(num2str(Ntraces - sum(keep)), ' traces removed b/c unable to align'));
        TraceStruct = LoadTraceStruct(TraceStruct);
        TraceStruct.removeTraces(find(~keep));
        TraceStruct = UnLoadTraceStruct(TraceStruct);
    end

end