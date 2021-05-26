function NullNodeFreqs = GetNullDistributionThroughNode(GridCorrObj, ...
    StartNode, NumRand, ToPlot)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: generates a "null distribution" of traces
    %through a given node, i.e., random walk traces started at that trace.
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: the GridCorrelationObject containing information on a
    %   given dataset and its nodes
    %
    %StartNode: the node that the null distribution will be generated
    %   starting from; can be specified either by its ID# or by a 2x1 vector
    %   of its grid coordinates
    %
    %NumRand: how many random walk traces through the specified node to
    %   generate
    %
    %ToPlot: logical variable: whether or not to show a plot of the
    %   generated traces when done
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %  
    %NullNodeFreqs: vector counting the number of traces in the generated
    %   null distribution that pass through each node
    
    
    if nargin < 4
        ToPlot = true;
    end
    if nargin < 3
        NumRand = 500;
    end

    %StartNode can be EITHER a tuple of the coordinates of the node, or the
    %node's ID#
    
    NUnique = GridCorrObj.NUnique;
    if nargin < 2
        StartNode = NUnique+1;
    end
    
    %Get "StartNode" into format of a single number (node ID)
    if length(StartNode) == 2
        AllNodeIDs = GridCorrObj.AllNodeIDs;
        StartNode = AllNodeIDs(StartNode(1),StartNode(2));
    elseif length(StartNode) == 1
        %Nothing to do, just leave it
    else
        error('StartNode value has incorrect format');
    end
    
    %We will need the probabilities of having transferred FROM different
    %nodes in order to generate the traces:
    CumulativeTransferFROMProbs = getCumulativeTransferFromProbs(GridCorrObj);

    %Generate NumRand different random traces throught the specified node
    NullTraces = cell(NumRand,1);
    for i = 1:NumRand
        NullTraces{i} = generate_randomtrace_throughnode(GridCorrObj, ...
            CumulativeTransferFROMProbs, StartNode, 0);
        %%%disp([i NumRand]);
    end
    
    %Get the node frequencies for the set of NullTraces:
    NullNodeFreqs = get_node_counts_for_CoarseTraces(NullTraces, NUnique);

    if ToPlot
        UniqueNodes = GridCorrObj.UniqueNodes;
        
        figure();
        hold on;
        scatter(UniqueNodes(:,1),UniqueNodes(:,2),8,NullNodeFreqs/NumRand,'filled');
        if StartNode <= NUnique
            plot(UniqueNodes(StartNode,1),UniqueNodes(StartNode,2),'o','Color','g');
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
        
        title('Null Distribution of Traces Through Specified Node');
    end



end