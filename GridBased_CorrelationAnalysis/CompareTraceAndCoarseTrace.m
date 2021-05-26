function CompareTraceAndCoarseTrace(TraceStruct, TraceNums, gridsper_x, ...
    gridsper_y, multiple_sections)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: compares one or more raw breaking traces with
    %their coarse approximations for a given grid size (and overlays that
    %grid). 
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing a dataset of breaking traces
    %
    %TraceNums: a vector containing the trace ID#s that the user wishes to
    %   view
    %
    %gridsper_x: the number of grid nodes per unit on the x-axis, in 
    %   whatever units the TraceStruct uses (so default is nodes/nm)
    %
    %gridsper_y: the number of grid nodes per unit on the y-axis, in
    %   whatever units the TraceStruct uses (so default is nodes/Log(G0))
    %
    %multiple_sections: logical variable; whether or not a trace should be
    %   broken into multiple independent coarse trace sections if/when it
    %   dips below the noise floor but then comes back up
    
    
    if nargin < 5
        multiple_sections = true;
    end
    if nargin < 4
        gridsper_y = 10;
    end
    if nargin < 3
        gridsper_x = 20;
    end

    %First go through and collect all trace data to calculate standard
    %deviations in distance and log(conductance)
    Ntraces = TraceStruct.Ntraces;
    TotalPoints = TraceStruct.NumTotalPoints;
    AllPoints = zeros(TotalPoints, 2);
    counter = 0;
    for i = 1:Ntraces
        trace = TraceStruct.Traces{i};
        n = length(trace);
        AllPoints(counter+1:counter+n,:) = trace;
        counter = counter + n;
    end
    
    %Calculate grid starting point and step size
    Xstart = min(AllPoints(:,1)) - 1;
    Ystart = min(AllPoints(:,2)) - 1;
    Xstep = 1/gridsper_x;
    Ystep = 1/gridsper_y;
    
    %Find ending point (only need for plotting grid lines)
    Xend = max(AllPoints(:,1)) + 1;
    Yend = max(AllPoints(:,2)) + 1;
    
    %Get Original traces and coarsened traces:
    nT = length(TraceNums);
    OG_traces = cell(nT,1);
    CoarseTraces = cell(nT*5,1);
    traceIDs = zeros(nT*5,1);
    counter = 0;
    for i = 1:nT
        OG_trace = TraceStruct.Traces{TraceNums(i)};
        
        if multiple_sections
            [sections, n] = coarseGridSingleTrace_multiplesections(OG_trace,...
                Xstart,Ystart,Xstep,Ystep,log10(TraceStruct.NoiseFloor),...
                2,false);
        else
            %In the case of NOT multiple sections, we will make the single
            %coarse trace "look" like a set of multiple sections so that
            %the rest of this function only needs one case
            coarse_tr = coarseGridSingleTrace(OG_trace,Xstart,Ystart,...
                Xstep,Ystep,false); 
            sections = cell(1);
            sections{1} = coarse_tr;
            n = 1;
        end
        
        %Transform coarse trace back to original coordinate system
        for j = 1:n
            sections{j}(:,1) = sections{j}(:,1)*Xstep+Xstart;
            sections{j}(:,2) = sections{j}(:,2)*Ystep+Ystart;
        end
  
        %Add trace (or trace sections) to list
        OG_traces{i} = OG_trace;
        for j = 1:n
            counter = counter + 1;
            CoarseTraces{counter} = sections{j};
            traceIDs(counter) = i;
        end
    end
    CoarseTraces = CoarseTraces(1:counter);
    
    figure();
    hold on;
    XL = [prctile(AllPoints(:,1),5) prctile(AllPoints(:,1),95)];
    YL = [-6 1];
    xlim(XL);
    ylim(YL);
    
    %Add grid lines
    for i = Xstart:Xstep:Xend
        plot([i i], YL, 'Color', [0.75 0.75 0.75], 'LineWidth',0.25);
    end
    for i = Ystart:Ystep:Yend
        plot(XL, [i i], 'Color', [0.75 0.75 0.75], 'LineWidth',0.25);
    end
    set(gca,'ColorOrderIndex',1);
    
    %Plot the original traces and then the coarse pieces
    cols = distinguishable_colors(nT);
    for i = 1:nT
        plot(OG_traces{i}(:,1),OG_traces{i}(:,2),'LineWidth',0.5,'Color',...
            cols(i,:));
    end
    for i = 1:counter
        plot(CoarseTraces{i}(:,1),CoarseTraces{i}(:,2),'--o','Color',...
            cols(traceIDs(i),:));
    end
    hold off;

    xlabel('Inter-Electrode Distance (nm)');
    ylabel('Log(Conductance/G_0)');

end