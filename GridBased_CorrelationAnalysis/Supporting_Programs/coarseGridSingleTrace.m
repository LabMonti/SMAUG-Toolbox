function CoarseTrace = coarseGridSingleTrace(Trace, Xstart, Ystart, ...
    Xstep, Ystep, ToPlot)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Converts a breaking trace into a series of nodes
    %such that each successive node in the trace is exacly one grid-step to
    %the right on the x-axis of the previous node, but can move any amount
    %of grid-steps up and down on the y-axis. 
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
    %ToPlot: logical variable; whether or not to create a plot comparing
    %   the original and coarsened trace
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %   
    %CoarseTrace: a two-column matrix holding the coordinates of each node
    %   in the coarsened trace.
    
    
    if nargin < 6
        ToPlot = 0;
    end

    %Figure out how many nodes we expect this trace to need
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
    
    if ToPlot == 1
        %Put back into original coordinates for plotting
        CoarseTraceToPlot = CoarseTrace;
        CoarseTraceToPlot(:,1) = CoarseTraceToPlot(:,1)*Xstep + Xstart;
        CoarseTraceToPlot(:,2) = CoarseTraceToPlot(:,2)*Ystep + Ystart;
        figure();
        plot(CoarseTraceToPlot(:,1),CoarseTraceToPlot(:,2),'--o');
        hold on;
        plot(Trace(:,1), Trace(:,2));
        hold off;
    end

end