function ChosenTraces = MostSignificantTraces_throughMCMCNodes(...
    GridCorrObj,NodeProbs,TopPercent,Frac_of_Nodes,TraceStruct)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given relative probabilities assigned to each
    %node for a dataset (e.g. from the output of the MCMC feature-finder),
    %this function first selects the most-probable nodes that between them
    %account for Frac_of_Nodes of the total probability assigned to all
    %nodes. We then score every trace passing through any of these chosen
    %nodes, versus the node it passed through. If a trace passes through 
    %more than one of the chosen nodes, we keep its highest score versus 
    %any of them. Finally, we take the top TopPercent scoring traces 
    %passing through these chosen nodes, and plot their distribution. The
    %idea is to robustly select those traces that correspond to a
    %particular feature found by the MCMC feature-finder. If the original
    %dataset is also included as an input then we will plot distributions
    %of raw data, otherwise we will plot distributions of coarsened data. 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: grid correlation object containing the coarsened traces
    %   and node information for a given dataset. 
    %
    %NodeProbs: vector listing relative probabilities for each node in the
    %   dataset, typically coming from the output of the MCMC
    %   feature-finder. 
    %
    %TopPercent: if this is 10, for example, then the top 10% scoring
    %   traces from among all the traces passing through the chosen nodes
    %   will be selected to plot. 
    %
    %Frac_of_Nodes: if this is 0.3, for example, then we will select nodes,
    %   in decreasing order of relative probability, until the nodes we've
    %   selected account for at least 30% of all the probability assigned
    %   to all nodes. 
    %
    %TraceStruct: the trace structure for the original dataset, containing
    %   the un-coarsened breaking traces. If this is included, then we will
    %   plot distributions of these original traces; if it is missing, then
    %   the distributions will be created from the coarsened traces (and
    %   thus, themselves coarsened). 
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %ChosenTraces: If TraceStruct was included as an input, then this will
    %   be a trace structure containing the top-scoring original traces.
    %   Otherwise, this will be a cell array containing the top-scoring
    %   coarsened traces. 
    
    
    %Default inputs
    if nargin < 5
        TraceStruct = [];
    end
    if nargin < 4
        Frac_of_Nodes = 0.8;
    end
    if nargin < 3
        TopPercent = 10;
    end
    
    %First we need to choose which nodes we are going to use; these will be
    %the nodes with the highest probabilities associated with them, up
    %until we reach the user-specified fraction of the total probability
    TotFreq = sum(NodeProbs);
    [NodeProbs,sortI] = sort(NodeProbs,'descend');
    NodeProbs = NodeProbs / TotFreq;
    cum_freqs = cumsum(NodeProbs);
    last_node_included = find(cum_freqs > Frac_of_Nodes,1,'first');
    nodeIDs = sortI(1:last_node_included);
    
    %Make a plot to show how many nodes are included
    figure();
    last_non_one = find(cum_freqs < 0.99,1,'last');
    plot((0:last_non_one+1),[0; cum_freqs(1:last_non_one+1)]);
    hold on;
    plot([0, last_node_included],[Frac_of_Nodes, Frac_of_Nodes],'--',...
        'Color',[0.5 0.5 0.5]);
    plot([last_node_included, last_node_included],[0, Frac_of_Nodes],...
        '--','Color',[0.5 0.5 0.5]);
    xlabel('# of Nodes Included');
    ylabel('Cumulative Fraction of Total MCMC Probability');
    
    %Get logical matrix of which traces go through which nodes (exclude
    %start and end nodes, we only care about real nodes here)
    NUnique = GridCorrObj.NUnique;
    NodeOccupancy = GridCorrObj.NodeOccupancy(1:NUnique,:);
    
    %Get scores for all traces through chosen nodes
    IDs_and_scores = zeros(GridCorrObj.Ntraces,2);
    counter = 0;
    for i = 1:length(nodeIDs)
        %Get IDs for traces going through this node, and save those IDs
        traceIDs = find(NodeOccupancy(nodeIDs(i),:));
        n = length(traceIDs);
        IDs_and_scores(counter+1:counter+n,1) = traceIDs;
        
        %For each trace going through this node, calculate and save the
        %score of that trace versus this node
        for j = 1:n
            counter = counter + 1;
            IDs_and_scores(counter,2) = ...
                score_trace_vs_SpecificNodeDistribution(GridCorrObj,...
                nodeIDs(i),traceIDs(j));
        end      
    end
    IDs_and_scores = IDs_and_scores(1:counter,:);
    
    %We need to sort the list of IDs and scores in terms of descending
    %scores; this will ensure that when we remove duplicates using unique,
    %we will keep the instance of each trace with the highest score
    [~,sortI] = sort(IDs_and_scores(:,2),'descend');
    IDs_and_scores = IDs_and_scores(sortI,:);
    
    %Convert coarse trace ID#s to actual trace ID#s, if we are going to be
    %plotting original traces
    if ~isempty(TraceStruct)
        IDs_and_scores(:,1) = GridCorrObj.OriginalTraceIDs(IDs_and_scores(:,1));
    end
    
    %Now remove the duplicates
    [~,uniI] = unique(IDs_and_scores(:,1));
    IDs_and_scores = IDs_and_scores(uniI,:);
    
    %Re-sort by scores
    [~,sortI] = sort(IDs_and_scores(:,2),'descend');
    IDs_and_scores = IDs_and_scores(sortI,:);
    nThrough = size(IDs_and_scores,1);
    
    %Make histogram of scores
    figure();
    hold on;
    %Get # of bins using Friedman-Diaconis rule
    nBins = round(range(IDs_and_scores(:,2))*nThrough^(1/3)/...
        (2*iqr(IDs_and_scores(:,2))));
    [counts,centers] = hist(IDs_and_scores(:,2),nBins);
    [x,y] = convert_to_histogram_endpoints(centers,counts);
    plot(x,y);
    cutOff = IDs_and_scores(round(nThrough*TopPercent/100),2);
    plot([cutOff cutOff], [0 max(y)], '--');
    xlabel('Maximum Trace Score vs. Chosen Nodes');
    ylabel('# of Traces');
    
    %Get IDs for all traces through these nodes, and for the top-scoring traces
    %through these nodes
    all_ThroughIDs = IDs_and_scores(:,1);
    traceIDs = IDs_and_scores(1:round(nThrough*TopPercent/100),1); 
    
    %If original traces not passed in, make a plot of node frequencies for
    %the selected traces
    if isempty(TraceStruct)
        
        %Get node frequencies for the top 10% coarse traces passing through
        %the chosen nodes
        ChosenTraces = GridCorrObj.CoarseTraces(traceIDs);
        chosen_freqs = get_node_counts_for_CoarseTraces(ChosenTraces,...
            GridCorrObj.NUnique,GridCorrObj.AllNodeIDs);
        
        %Make node frequency plot for these chosen coarse traces
        figure();
        scatter(GridCorrObj.UniqueNodes(:,1),GridCorrObj.UniqueNodes(:,2),...
            10,chosen_freqs,'filled');
        cmap = importdata('cmap.mat');
        colormap(cmap);
        colorbar();
        f = gcf;
        f.Children(1).Label.String = '# Traces Through Node';
        f.Children(1).Label.Rotation = -90;
        f.Children(1).Label.VerticalAlignment = 'bottom';
        xlabel('Inter-Electrode Distance Grid #');
        ylabel('Log(Conductance/G_0) Grid #');
        secondary_axes_ForValues(GridCorrObj);
        
        %Also get node frequencies for all coarse traces passing through
        %the chosen nodes
        AllThroughTraces = GridCorrObj.CoarseTraces(all_ThroughIDs);
        through_freqs = get_node_counts_for_CoarseTraces(AllThroughTraces,...
            GridCorrObj.NUnique,GridCorrObj.AllNodeIDs);
        
        %Make overlaid 1D histogram of coarse trace data
        figure();
        hold on;
        cols = distinguishable_colors(3);
        
        %Add 1D histogram for all coarse traces in dataset
        [counts,centers] = NodeFreqs_to_1DHist(GridCorrObj.NodeFreqs,GridCorrObj,...
            'cond',false);
        [x,y] = convert_to_histogram_endpoints(centers,counts);
        plot(x,y/GridCorrObj.Ntraces,'Color',cols(1,:));
        
        %Add 1D histogram for all coarse traces through chosen nodes
        [counts,centers] = NodeFreqs_to_1DHist(through_freqs,GridCorrObj,...
            'cond',false);
        [x,y] = convert_to_histogram_endpoints(centers,counts);
        plot(x,y/length(AllThroughTraces),'Color',cols(2,:));      
        
        %Add 1D histogram for top-scoring traces through chosen nodes
        [counts,centers] = NodeFreqs_to_1DHist(chosen_freqs,GridCorrObj,...
            'cond',false);
        [x,y] = convert_to_histogram_endpoints(centers,counts);
        plot(x,y/length(ChosenTraces),'Color',cols(3,:));
        
        legend({'Full Dataset','Traces Through Chosen Nodes',...
            'Top 10%-Scored Traces through Chosen Nodes'});
        xlabel('Log(Conductance/G_0)');
        ylabel('Count per Trace');
        
    %If original traces WERE passed in, make a 2D histogram for the
    %selected traces
    else
        
        ChosenTraces = tracestruct_from_subset(TraceStruct,traceIDs,'');
        Make2DHist_FromTraceStructure(ChosenTraces,100,40);   
        
        AllThroughTraces = tracestruct_from_subset(TraceStruct,all_ThroughIDs,'');
        
        Plot_Overlaid_1DConductanceHistograms({TraceStruct,AllThroughTraces,...
            ChosenTraces},30,'Log',true,{'Full Dataset','Traces Through Chosen Nodes',...
            strcat('Top ',num2str(TopPercent),'%-Scored Traces through Chosen Nodes')});
        
    end

end