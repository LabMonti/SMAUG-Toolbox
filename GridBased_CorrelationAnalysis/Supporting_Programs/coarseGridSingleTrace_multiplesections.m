function [CoarseSections, nSections] = ...
    coarseGridSingleTrace_multiplesections(Trace, Xstart, Ystart, Xstep, ...
    Ystep, NoiseFloor, minSectionLength, ToPlot)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Converts a breaking trace into a series of nodes
    %such that each successive node in the trace is exacly one grid-step to
    %the right on the x-axis of the previous node, but can move any amount
    %of grid-steps up and down on the y-axis. If the original trace dips
    %below the datset's noise floor but then comes back up, this function
    %will create multiple different coarse trace sections to correspond to
    %the different above-noise sections of the trace.
    %
    %~~~INPUTS~~~:
    %
    %Trace: two-column matrix holding a single breaking trace
    %
    %Xstart/Ystart: the x/y coordinate that will be assigned to the node
    %   coordinate zero along the x/y axis (in whatever the units of Trace
    %   are; default is nm for x and Log(G0) for y).
    %
    %Xstep/Ystep: the distance between neighboring nodes along the x/y axis
    %   (in whatever the units of Trace are; default is nm for x and 
    %   Log(G0) for y).
    %
    %NoiseFloor: the noise floor of the dataset. Must be in the same units
    %   as the y-values of Trace (so, default is log(G0)).
    %
    %minSectionLength: the minimum # of nodes that a coarse section must
    %   have in order to be included in the output; if a section is shorter
    %   than this then it will be thrown out.
    %
    %ToPlot: logical variable; whether or not to create a plot comparing
    %   the original and coarsened trace
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %   
    %CoarseSections: a cell array with each element holding a two-column 
    %   matrix with the coordinates of each node in the coarsened section.
    %
    %nSections: the number of separate coarse sections created for the
    %   trace (i.e. the length of the CoarseSections cell array)
    
    
    if nargin < 8
        ToPlot = 0;
    end
    if nargin < 7
        minSectionLength = 4;
    end
    if nargin < 6
        NoiseFloor = -6;
    end

    N = length(Trace);
    expected_nodes = ceil((Trace(N,1) - Trace(1,1))/Xstep) + 10;
    CoarseTrace = zeros(expected_nodes, 2);
    counter = 0;
    
    %Find the first rounded x-value
    Xnode = round((Trace(1,1) - Xstart)/Xstep);
    Xswitch = Xnode*Xstep + Xstart + Xstep/2;
    index = 1;
    
    Ysum = 0;
    nPoints = 0;
    while index <= N
                
        xVal = Trace(index,1);
        if xVal <= Xswitch
            %Point belongs in same bin, add to sum
            Ysum = Ysum + Trace(index,2);
            nPoints = nPoints + 1;
            
            index = index + 1;
        else
            Ynode = round((Ysum/nPoints - Ystart)/Ystep);
            
            %Add the new node:
            counter = counter + 1;
            CoarseTrace(counter,:) = [Xnode, Ynode];
            
            %Re-set counters:
            Ysum = 0;
            nPoints = 0;
            
            %Update Xnode and Xswitch:
            Xnode = Xnode + 1;
            Xswitch = Xswitch + Xstep;
        end
        
    end
    %Finish the last node:
    if nPoints > 0
        Ynode = round((Ysum/nPoints - Ystart)/Ystep);
        
        %Add the new node:
        counter = counter + 1;
        CoarseTrace(counter,:) = [Xnode, Ynode];        
    end        
    CoarseTrace = CoarseTrace(1:counter,:);
        
    %OK, now we need to potentially split up the coarse trace into multiple
    %sections
    gridNoiseFloor = (NoiseFloor - Ystart)/Ystep;
    [bounds, sectLengths] = splitup_YnodeList(CoarseTrace(:,2),gridNoiseFloor);
    bounds = bounds(sectLengths >= minSectionLength,:);
    nSections = size(bounds,1);
    CoarseSections = cell(nSections,1);
    for i = 1:nSections
        CoarseSections{i} = CoarseTrace(bounds(i,1):bounds(i,2),:);
    end   
    
    if ToPlot == 1
        figure();
        hold on;
        plot(Trace(:,1), Trace(:,2));
        
        %Plot the entire coarse trace in gray
        CoarseTraceToPlot = CoarseTrace;
        CoarseTraceToPlot(:,1) = CoarseTraceToPlot(:,1)*Xstep + Xstart;
        CoarseTraceToPlot(:,2) = CoarseTraceToPlot(:,2)*Ystep + Ystart;        
        plot(CoarseTraceToPlot(:,1),CoarseTraceToPlot(:,2),'o',...
            'Color',[0.5 0.5 0.5]);

        %Plot each kept section in red
        for i = 1:nSections
            plot(CoarseTraceToPlot(bounds(i,1):bounds(i,2),1),...
                CoarseTraceToPlot(bounds(i,1):bounds(i,2),2),'--o',...
                'Color',[1 0 0]);
        end
    end

end