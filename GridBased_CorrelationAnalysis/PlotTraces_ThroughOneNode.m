function PlotTraces_ThroughOneNode(GridCorrObj, StartNode, plot_type, ...
    TraceStruct)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Displays the traces in a coarsened dataset that
    %pass through the specified start node. The plot can be
    %of the coarsened traces themselves, node frequencies for the coarse 
    %traces, the original traces, or a 2D histogram of the original traces
    %can be made.
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: a GridCorrelationObject containing the coarsened traces
    %   and node information for a given dataset
    %
    %StartNode: the specified node that the traces must pass through.
    %   The node can be specified EITHER by its node ID #, or by its two
    %   node coordinates
    %
    %plot_type: string variable specifying what type of plot to make;
    %   options are "NodeFreqs" (default), "CoarseTraces", "Traces", 
    %   "2DHist". For the latter two options, a TraceStruct must also be 
    %   passed in.
    %
    %TraceStruct: the trace structure for the same dataset as the
    %   GridCorrelationObject is for; only needed as an input for the
    %   "Traces" and "2DHist" plot types.
    
    
    NUnique = GridCorrObj.NUnique;
    if nargin < 3
        plot_type = 'NodeFreqs';
    end 
    if nargin < 2
        StartNode = NUnique+1;
    end
    
    %Make sure that the plot_type input makes sense
    if ~strcmp(plot_type, 'CoarseTraces') && ~strcmp(plot_type, 'Traces') ...
            && ~strcmp(plot_type, '2DHist') && ~strcmp(plot_type, 'NodeFreqs')
        error('Unrecognized plot type!');
    end   
    if strcmp(plot_type, 'Traces') && nargin < 4
        error('TraceStruct input required for "Traces" plot type');
    end    
    
    %Get "StartNode" into format of a single number (node ID)
    StartNode = GridCorrObj.getNodeID(StartNode);
    
    %Get the indices of the start node
    UniqueNodes = GridCorrObj.UniqueNodes;
    node = UniqueNodes(StartNode,:);
    
    if isempty(GridCorrObj.NodeOccupancy)
        GridCorrObj.calculate_NodeOccupancies();
    end
    
    Ntraces = GridCorrObj.Ntraces;
    NodeOccupancy = GridCorrObj.NodeOccupancy;
    
    if strcmp(plot_type, 'CoarseTraces') || strcmp(plot_type, 'Traces')
    
        if strcmp(plot_type, 'CoarseTraces')
            AllTraces = GridCorrObj.CoarseTraces;
            pstyle = '-';
        elseif strcmp(plot_type, 'Traces')
            AllTraces = TraceStruct.Traces(GridCorrObj.OriginalTraceIDs);
            pstyle = '-';
        end

        figure();
        hold on;
        TraceCount = 0;
        for i = 1:Ntraces
            if NodeOccupancy(StartNode, i)
                tr = AllTraces{i};
                plot(tr(:,1),tr(:,2),pstyle);
                TraceCount = TraceCount + 1;
            end
        end
        if ~isempty(node)
            if strcmp(plot_type, 'CoarseTraces')
                plot(node(1),node(2),'o','Color','g');
            elseif strcmp(plot_type, 'Traces')
                xloc = node(1)*GridCorrObj.Xstep + GridCorrObj.Xstart;
                yloc = node(2)*GridCorrObj.Ystep + GridCorrObj.Ystart;
                plot(xloc,yloc,'o','Color','g');                
            end
        end
        hold off;
        xlabel('Inter-Electrode Distance Grid #');
        ylabel('Log(Conductance/G_0) Grid #');
        
        if strcmp(plot_type,'Traces')
            ylim([log10(TraceStruct.NoiseFloor) 1]);
        end
    end
    
    if strcmp(plot_type, 'NodeFreqs')
        
        UniqueNodes = GridCorrObj.UniqueNodes;
        
        %Get the node frequencies for the subset of traces passing through
        %the specified node
        [SubsetFreqs, TraceCount] = getFreqs_ThroughNode(GridCorrObj, StartNode);
        
        figure();
        hold on;
        scatter(UniqueNodes(:,1),UniqueNodes(:,2),8,SubsetFreqs/TraceCount,'filled');
        if ~isempty(node)
            plot(node(1),node(2),'o','Color','g');
        end
        colorbar();
        hold off;
        ylabel('Log(Conductance) Grid #');
        xlabel('Inter-Electrode Distance Grid #');
        
        %Label the color bar
        a = gca;
        h = a.Colorbar;
        set(get(h,'label'),'string','Node Visits per Trace',...
            'Rotation',-90,'VerticalAlignment','bottom','FontSize',14);
        cmap = importdata('cmap.mat');
        colormap(cmap);        
        
        title('Actual Distribution of Traces Through Specified Node');
    end
    
    if strcmp(plot_type, '2DHist')
        TraceStruct = LoadTraceStruct(TraceStruct);
        AllData = zeros(TraceStruct.NumTotalPoints, 2);
        counter = 0;
        TraceCount = 0;
        for i = 1:Ntraces
            if NodeOccupancy(StartNode, i)
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
        
        %Show location of node of interest if it's a real node
        if ~isempty(node)
            hold on;
            xloc = node(1)*GridCorrObj.Xstep + GridCorrObj.Xstart;
            yloc = node(2)*GridCorrObj.Ystep + GridCorrObj.Ystart;
            plot(xloc,10^yloc,'o','Color','g');
            hold off;
        end
    end
    
    NodeFreqs = GridCorrObj.NodeFreqs;
    if StartNode <= NUnique
        disp(strcat('# of Traces passing through first node: ', num2str(NodeFreqs(StartNode))));
    else
        disp(strcat('All traces pass through StartTrace and EndTrace nodes (',num2str(Ntraces),')'));
    end

end