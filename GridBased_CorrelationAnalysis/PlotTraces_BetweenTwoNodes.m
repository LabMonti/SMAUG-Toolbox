function PlotTraces_BetweenTwoNodes(GridCorrObj, Node1, Node2, plot_type, ...
    TraceStruct)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Displays the traces in a coarsened dataset that
    %pass through Node1 and then pass through Node2. The plot can either be
    %of the coarsened traces themselves, the original traces, or a 2D
    %histogram of the original traces can be made.
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: a GridCorrelationObject containing the coarsened traces
    %   and node information for a given dataset
    %
    %Node1/Node2: the first/second node that the traces must pass through.
    %   Each node can be specified EITHER by its node ID #, or by its two
    %   node coordinates
    %
    %plot_type: string variable specifying what type of plot to make;
    %   options are "CoarseTraces" (default), "Traces", "2DHist". For the
    %   latter two options, a TraceStruct must also be passed in.
    %
    %TraceStruct: the trace structure for the same dataset as the
    %   GridCorrelationObject is for; only needed as an input for the
    %   "Traces" and "2DHist" plot types.
    

    if nargin < 4
        plot_type = 'CoarseTraces';
    end
    
    %Make sure inputs make sense
    if ~strcmp(plot_type, 'CoarseTraces') && ~strcmp(plot_type, 'Traces') ...
            && ~strcmp(plot_type, '2DHist')
        error('Unrecognized plot type!');
    end
    if strcmp(plot_type, 'Traces') && nargin < 5
        error('TraceStruct input required for "Traces" plot type');
    end

    if isempty(GridCorrObj.NodeOccupancy)
        GridCorrObj.calculate_NodeOccupancies();
    end
    
    Ntraces = GridCorrObj.Ntraces;
    NodeOccupancy = GridCorrObj.NodeOccupancy;
    UniqueNodes = GridCorrObj.UniqueNodes;
    
    %Make sure both nodes are specified by their node ID
    Node1 = GridCorrObj.getNodeID(Node1);
    Node2 = GridCorrObj.getNodeID(Node2);
    
    if strcmp(plot_type, 'CoarseTraces') || strcmp(plot_type, 'Traces')
    
        if strcmp(plot_type, 'CoarseTraces')
            AllTraces = GridCorrObj.CoarseTraces;
            pstyle = '-';
        elseif strcmp(plot_type, 'Traces')
            AllTraces = TraceStruct.Traces(GridCorrObj.OriginalTraceIDs);
            pstyle = '-';
        end

        %Plot either the raw or the coarsened traces
        figure();
        hold on;
        TraceCount = 0;
        for i = 1:Ntraces
            if NodeOccupancy(Node1, i) && NodeOccupancy(Node2, i)
                tr = AllTraces{i};
                plot(tr(:,1),tr(:,2),pstyle);
                TraceCount = TraceCount + 1;
            end
        end
        
        %Get vectors of x and y coordinates from both nodes
        x_coords = [UniqueNodes(Node1,1), UniqueNodes(Node2,1)];
        y_coords = [UniqueNodes(Node1,2), UniqueNodes(Node2,2)];
        
        if strcmp(plot_type, 'Traces')
            x_coords = x_coords*GridCorrObj.Xstep+GridCorrObj.Xstart;
            y_coords = y_coords*GridCorrObj.Ystep+GridCorrObj.Ystart;
            ylim([log10(TraceStruct.NoiseFloor), 1]);
        end
        
        plot(x_coords(1),y_coords(1),'o','Color','g','MarkerFaceColor','g');
        plot(x_coords(2),y_coords(2),'o','Color','r','MarkerFaceColor','r');
        hold off;
        xlabel('Inter-Electrode Distance Grid #');
        ylabel('Log(Conductance/G_0) Grid #');
    end
    
    %Make a 2D histogram using just the data from the traces that pass
    %through both nodes
    if strcmp(plot_type, '2DHist')
        TraceStruct = LoadTraceStruct(TraceStruct);
        AllData = zeros(TraceStruct.NumTotalPoints, 2);
        counter = 0;
        TraceCount = 0;
        for i = 1:Ntraces
            if NodeOccupancy(Node1, i) && NodeOccupancy(Node2, i)
                tr = TraceStruct.Traces{GridCorrObj.OriginalTraceIDs(i)};
                n = size(tr,1);
                AllData(counter+1:counter+n,:) = tr;
                counter = counter + n;
                TraceCount = TraceCount + 1;
            end
        end
        AllData = AllData(1:counter, :);
        
        make2DHist_FromDataPoints(AllData, 100, 40, 'Lin', 'Log', ...
            TraceStruct.NoiseFloor, 1/TraceCount)      
        
        %Get x- and y-coordinates of the two nodes (and convert y-coords to
        %linear values from log values)
        x_coords = [UniqueNodes(Node1,1), UniqueNodes(Node2,1)];
        y_coords = [UniqueNodes(Node1,2), UniqueNodes(Node2,2)];
        x_coords = x_coords*GridCorrObj.Xstep+GridCorrObj.Xstart;
        y_coords = 10.^(y_coords*GridCorrObj.Ystep+GridCorrObj.Ystart);
        
        %Overlay the two nodes on the plot as circles
        hold on;
        plot(x_coords(1),y_coords(1),'o','Color','g');
        plot(x_coords(2),y_coords(2),'o','Color','r');
    end
    
    %Print information about the number of traces going through these nodes
    NodeFreqs = GridCorrObj.NodeFreqs;
    disp(strcat('# of Traces passing through first node: ', num2str(NodeFreqs(Node1))));
    disp(strcat('# of those traces passing through second node: ', num2str(TraceCount)));
    if ~isempty(GridCorrObj.ExpectedNodePairProbs)
        disp(strcat('Expected # of those traces passing through second node: ', ...
            num2str(NodeFreqs(Node1)*GridCorrObj.ExpectedNodePairProbs(Node1, Node2))));
    end

end