function [trueIDs_top,trueIDs_bot] = TopScoringTraces_ThroughNode(...
    GridCorrObj, ChosenNode, TopBottomPercent, OptionalTraceStruct, ToPlot)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Assigns a score to each trace going through the
    %chosen node based on the average conneciton strength between all of the
    %other nodes visited by that trace and the chosen node. Then create a
    %plot of the top (and bottom) x% of those traces based on their scores. 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: grid correlation object containing the coarsened traces
    %   and all node information for a given dataset
    %
    %ChosenNode: we will look at just the traces passing through this node,
    %   and we will score them versus this node, in order to select the
    %   top-scoring traces. Can be specified as EITHER the node ID#, or as
    %   a 2x1 vector the node's grid coordinates. 
    %
    %TopBottomPercent: What top- (and bottom-) percent of traces will be
    %   plotted; e.g., if this is 10, then the top 10%-scoring traces (and
    %   the bottom 10%) will have plots made of them. 
    %
    %OptionalTraceStruct: a trace structure containing the original
    %   (un-coarsened) traces for the dataset being analyzed. If this is
    %   included, then the plots will be made using these original traces.
    %   If it is not included (can be set to []), then the plots will be
    %   made just using the coarse traces.
    %
    %ToPlot: logical input; whether or not to display output plots
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %trueIDs_top/bot: the ID#s of the original traces passing through the
    %   chosen node that fall within the top/bottom percent of all such
    %   traces, score-wise
    
    
    %Default inputs
    if nargin < 5
        ToPlot = true;
    end
    if nargin < 4
        OptionalTraceStruct = [];
    end
    if nargin < 3
        TopBottomPercent = 10;
    end

    %Get node in format of a node id:
    NodeID = GridCorrObj.getNodeID(ChosenNode);

    if isempty(GridCorrObj.NodeOccupancy)
        GridCorrObj.calculate_NodeOccupancies;
    end
    
    Ntraces = GridCorrObj.Ntraces;
    UniqueNodes = GridCorrObj.UniqueNodes;
    
    throughNode = zeros(Ntraces,1);
    scores = zeros(Ntraces,1);
    counter = 0;
    
    %Find all traces passing through the given node, and score them
    for i = 1:Ntraces
        if GridCorrObj.NodeOccupancy(NodeID,i)
            counter = counter + 1;
            throughNode(counter) = i;
            scores(counter) = score_trace_vs_SpecificNodeDistribution(GridCorrObj,...
                NodeID,i);   
        end
    end
    throughNode = throughNode(1:counter);
    scores = scores(1:counter);
    
    %Determine cutoffs
    bottom = prctile(scores,TopBottomPercent);
    top = prctile(scores,100 - TopBottomPercent);
    
    %Make histogram
    if ToPlot
        figure();
        nbins = round(range(scores)*length(scores)^(1/3)/(2*iqr(scores)));
        [counts, centers] = hist(scores,nbins);
        [x,y] = convert_to_histogram_endpoints(centers', counts');
        plot(x,y);
        hold on;
        plot([bottom bottom], [0 max(counts)], '--', 'Color', [0 0 1]);
        plot([top top], [0 max(counts)], '--', 'Color', [1 0 0]);
        xlabel('Trace "Significance" Score');
        ylabel('# of Traces');
    end
    
    %Get IDs for traces in the top and bottom
    traceIDs_bot = throughNode(scores <= bottom);
    traceIDs_top = throughNode(scores >= top);
    
    %Convert trace IDs to space of original trace ID numbers
    trueIDs_top = GridCorrObj.OriginalTraceIDs(traceIDs_top);
    trueIDs_bot = GridCorrObj.OriginalTraceIDs(traceIDs_bot);
    
    %Make the plots
    if ToPlot
        if isempty(OptionalTraceStruct)
            cmap = importdata('cmap.mat');
            NUnique = GridCorrObj.NUnique;

            figure();
            node_counts = sum(GridCorrObj.NodeOccupancy(1:NUnique,traceIDs_bot),2);
            scatter(UniqueNodes(:,1),UniqueNodes(:,2),10,node_counts/...
                length(traceIDs_bot),'filled');
            colormap(cmap);
            colorbar();
            title('Lowest Scoring Traces');

            figure();
            node_counts = sum(GridCorrObj.NodeOccupancy(1:NUnique,traceIDs_top),2);
            scatter(UniqueNodes(:,1),UniqueNodes(:,2),10,node_counts/...
                length(traceIDs_top),'filled');
            colormap(cmap);
            colorbar();
            title('Highest Scoring Traces');
        else
            %Get 1D histogram data for all traces passing through the node
            TracesThruNode = tracestruct_from_subset(OptionalTraceStruct,...
                GridCorrObj.OriginalTraceIDs(throughNode),'');
            T = LoadTraceStruct(TracesThruNode);
            cond = T.getAllData('c');
            bin_width = 2*iqr(cond)/length(cond)^(1/3);
            [counts,centers] = hist(cond,round(range(cond)/bin_width));
            counts = counts / T.Ntraces;
            [xn,yn] = convert_to_histogram_endpoints(centers,counts);

            %Get 1D histogram data for entire, raw dataset:
            T = LoadTraceStruct(OptionalTraceStruct);
            cond = T.getAllData('c');
            [counts,centers] = hist(cond,round(range(cond)/bin_width));
            counts = counts / T.Ntraces;
            [x0,y0] = convert_to_histogram_endpoints(centers,counts);

            Traces2Plot = tracestruct_from_subset(OptionalTraceStruct,trueIDs_bot,'');
            Make2DHist_FromTraceStructure(Traces2Plot,100,40);
            title(strcat(num2str(TopBottomPercent),'% Lowest Scoring Traces'));

            %Get and bin conductance values:
            T = LoadTraceStruct(Traces2Plot);
            cond = T.getAllData('c');
            [counts,centers] = hist(cond,round(range(cond)/bin_width));
            counts = counts/T.Ntraces;
            [xl,yl] = convert_to_histogram_endpoints(centers,counts);

            %Add circle around node of interest
            hold on;
            plot(UniqueNodes(NodeID,1)*GridCorrObj.Xstep + GridCorrObj.Xstart,...
                10^(UniqueNodes(NodeID,2)*GridCorrObj.Ystep + GridCorrObj.Ystart),'o',...
                'Color',[0 0 0],'LineWidth',2,'MarkerFaceColor',[1 0 0]);

            Traces2Plot = tracestruct_from_subset(OptionalTraceStruct,trueIDs_top,'');
            Make2DHist_FromTraceStructure(Traces2Plot,100,40);
            title(strcat(num2str(TopBottomPercent),'% Highest Scoring Traces'));

            %Get and bin conductance values:
            T = LoadTraceStruct(Traces2Plot);
            cond = T.getAllData('c');
            [counts,centers] = hist(cond,round(range(cond)/bin_width));
            counts = counts/T.Ntraces;
            [xh,yh] = convert_to_histogram_endpoints(centers,counts);

            %Add circle around node of interest
            hold on;
            plot(UniqueNodes(NodeID,1)*GridCorrObj.Xstep + GridCorrObj.Xstart,...
                10^(UniqueNodes(NodeID,2)*GridCorrObj.Ystep + GridCorrObj.Ystart),'o',...
                'Color',[0 0 0],'LineWidth',2,'MarkerFaceColor',[1 0 0]);

            %Compare both histograms:
            figure();
            hold on;
            plot(xl,yl);
            plot(xh,yh);
            plot(xn,yn,'Color',[0 0 0]);
            plot(x0,y0,'--','Color',[0.5 0.5 0.5]);
            legend({strcat(num2str(TopBottomPercent),'% Lowest Scoring Traces Through Node'),...
                strcat(num2str(TopBottomPercent),'% Highest Scoring Traces Through Node'),...
                'All Traces Through Node','All Traces in Dataset'});
            xlabel('Log(Conductance/G_0)');
            ylabel('Counts per Trace');
            xlim([log10(T.NoiseFloor), 1]);
        end
    end

end