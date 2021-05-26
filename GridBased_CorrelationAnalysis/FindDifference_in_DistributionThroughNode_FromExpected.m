function RMSDiff = FindDifference_in_DistributionThroughNode_FromExpected(...
    GridCorrObj, StartNode, NumRand, ToPlot)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: This function makes a bunch of random walk traces
    %from a given starting node, and then compares the distribution of
    %where they go with where the ACTUAL traces through that node went. The
    %differences end up being very similar to connection strength, but what
    %they add is more quantitative intuition about what the values mean,
    %since in this case they are the difference in node visits per traces.
    %
    %~~~INPUTS~~~: 
    %
    %GridCorrObj: a GridCorrelationObject containing information on a set
    %of coarse traces, the nodes they visited, and the correlations between
    %them
    %
    %StartNode: the node that the distributions of this function will be
    %   relative to; can be specified either by its ID# or by a 2x1 vector
    %   of its grid coordinates
    %
    %NumRand: how many random traces will be generated through the starting
    %   node
    %
    %ToPlot: logical variable; whether or not to make a plot to display the
    %   results
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %RMSDiff: rms value for the difference in node visits for every node;
    %   an attempt to measure how "significant" the current node is
    

    %StartNode can be EITHER a tuple of the coordinates of the node, or the
    %node's ID#
    %Get "StartNode" into format of a single number (node ID)
    StartNode = GridCorrObj.getNodeID(StartNode);    
    NUnique = GridCorrObj.NUnique;
    
    if nargin < 4
        ToPlot = true;
    end
    if nargin < 3
        NumRand = 500*GridCorrObj.NodeFreqs(StartNode);
    end
    if nargin < 2
        StartNode = NUnique+1;
    end
    
    %Get node frequencies from actual traces, and normalize:
    [ActualFreqs, NThrough] = getFreqs_ThroughNode(GridCorrObj, StartNode);
    ActualFreqs = ActualFreqs / NThrough;
    
    disp(strcat('# of Observed Traces passing through node: ',num2str(NThrough)));
    
    %Get expected frequenceis and normalize:
    ExpectedFreqs = GetNullDistributionThroughNode(GridCorrObj,StartNode,NumRand,0);
    ExpectedFreqs = ExpectedFreqs / NumRand;
    
    %Find the difference, Actual minus Expected
    FreqDiffs = ActualFreqs - ExpectedFreqs;
    
    %Plot the differences:
    if ToPlot
        UniqueNodes = GridCorrObj.UniqueNodes;
        figure();
        scatter(UniqueNodes(:,1),UniqueNodes(:,2),8,FreqDiffs,'filled');
        colorbar();
        ylabel('Log(Conductance) Grid #');
        xlabel('Inter-Electrode Distance Grid #');
    
        %Make color scale symmetric:
        maxDiff = max(abs(FreqDiffs));
        caxis([-maxDiff maxDiff]);

        %Show the node through which we are looking
        if StartNode <= NUnique
            hold on;
            plot(UniqueNodes(StartNode,1),UniqueNodes(StartNode,2),'o','Color','g');
            hold off;
        end  
        
        %Label the color bar
        a = gca;
        h = a.Colorbar;
        set(get(h,'label'),'string','\DeltaNode Visits per Trace',...
            'Rotation',-90,'VerticalAlignment','bottom','FontSize',14);
        cmap = importdata('hot_cold_cmap.mat');
        colormap(cmap);
        
        %Add secondary axis
        secondary_axes_ForValues(GridCorrObj);
    end
    
    RMSDiff = sqrt(sum(FreqDiffs.^2)/length(FreqDiffs));
end