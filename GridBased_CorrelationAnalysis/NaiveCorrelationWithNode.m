function NaiveCorrelationWithNode(GridCorrObj, StartNode)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: For the purposes of making a point only, 
    %calculate correlations with a given node by comparing the probability
    %that a trace passes through some other node conditional on it passing
    %through the node in question with the unconditional probability of a
    %trace passing through a node.  
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: a GridCorrelationObject containing the coarse traces for
    %   a given dataset
    %
    %StartNode: the node of interest that correlations will be computed
    %   against; can be specified EITHER as a node ID # or as a 2x1 vector
    %   of node coordinates. 
    
    
    %Get node occupancy matrix showing which traces go through which nodes
    if isempty(GridCorrObj.NodeOccupancy)
        GridCorrObj.calculate_NodeOccupancies();
    end
    NUnique = GridCorrObj.NUnique;
    NodeOccupancies = GridCorrObj.NodeOccupancy;
    
    %Find traces passing through start node
    StartNode = GridCorrObj.getNodeID(StartNode);
    X = NodeOccupancies(StartNode,:);
    
    %Calculate the correlations using the node occupancy matrix
    corrWithNode = zeros(NUnique,1);
    for i = 1:NUnique
        Y = NodeOccupancies(i,:);
        cc = cov(X,Y);
        if cc(1,1) > 0 && cc(2,2) > 0
            corrWithNode(i) = cc(1,2)/sqrt(cc(1,1)*cc(2,2));
        end
    end
    
    UniqueNodes = GridCorrObj.UniqueNodes;
    
    %Make the figure
    figure();
    scatter(UniqueNodes(:,1),UniqueNodes(:,2),10,corrWithNode,'filled');
    cmap = importdata('hot_cold_cmap.mat');
    colormap(cmap);
    colorbar();
    caxis([-1 1]);
    xlabel('InterElectrode Distance Grid #');
    ylabel('Log(Conductance) Grid #');
    title('"Naive" Correlation With Circled Node');
    
    %Add green circle around the node that correlations are being computed
    %against
    hold on;
    plot(UniqueNodes(StartNode,1),UniqueNodes(StartNode,2),'o',...
        'MarkerSize',6,'Color','g');
    
end