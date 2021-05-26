function Show_ConnectionStrength_WithSpecificNode(GCO, ...
    ChosenNode, axes_type, SmoothStrengths)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: for a specified node in a dataset, displays the
    %   connection strength of every other node in the dataset compared to
    %   this node
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: GridCorrelationObject containing coarsened traces and
    %   connection strength information for a given dataset
    %
    %ChosenNode: the node that all connection strengths will be relative
    %   to; can be specified EITHER by its node ID # or by a 2x1 vector of
    %   its node coordinates
    %
    %axes_type: string variable to indicate how the data should be plotted;
    %   can be set to "grid" to plot grid #s in x and y, "values" to plot
    %   the actual x and y values (in nm and Log(G0), say) of each
    %   node, or "both" (default) to plot both grid #s and values, with
    %   values on a set of  secondary axes
    %
    %SmoothStrengths: logical variable; whether or not to "smooth" the
    %   connection strength distribution, by averaging each node with its 8
    %   nearest neighbors
    
    
    if nargin < 3
        axes_type = 'both';
    end
    if nargin < 4
        SmoothStrengths = false;
    end
    
    if ~any(strcmp(axes_type,{'values','grid','both'}))
        error('Unrecognized input for "axes type": valid options are "values", "grid", or "both"');
    end
    
    
    %Get node ID #
    nodeID = GCO.getNodeID(ChosenNode);
    
    UniqueNodes = GCO.UniqueNodes;
    strengths = GCO.ConnectionStrengths(nodeID,:);
    
    %Trim off the last two strength values because they correspond to
    %strengths with the StartTrace and EndTrace nodes, which are not real
    %nodes and so cannot be plotted
    NUnique = GCO.NUnique;
    strengths = strengths(1:NUnique);
    
    %Smooth strengths by averaging with neighbors, if requested
    if SmoothStrengths
        strengths = twoD_nodeSmooth(UniqueNodes,GCO.AllNodeIDs,...
            strengths,false);
    end
    
    figure();
    hold on;
    if strcmp(axes_type,'values')
        scatter(UniqueNodes(:,1)*GCO.Xstep+GCO.Xstart, UniqueNodes(:,2)*...
            GCO.Ystep+GCO.Ystart, 8, strengths, 'o', 'filled');    
        plot(UniqueNodes(nodeID,1)*GCO.Xstep+GCO.Xstart, ...
            UniqueNodes(nodeID,2)*GCO.Ystep+GCO.Ystart, 'o', 'MarkerSize',...
            12, 'Color', 'g');
    elseif strcmp(axes_type,'grid') || strcmp(axes_type,'both')
        scatter(UniqueNodes(:,1), UniqueNodes(:,2), 8, strengths, 'o',...
            'filled');    
        plot(UniqueNodes(nodeID,1), UniqueNodes(nodeID,2), 'o', 'MarkerSize', 12, 'Color', 'g');
    end    
    hold off;
    colorbar();
    lim = max(max(strengths), -min(strengths));
    caxis([-lim lim]);
    
    %Label the colorbar
    a = gca;
    h = a.Colorbar;
    if SmoothStrengths
        clabel = 'Smoothed Connection Strength with Circled Node';
    else
        clabel = 'Connection Strength with Circled Node';
    end
    set(get(h,'label'),'string',clabel,...
        'Rotation',-90,'VerticalAlignment','bottom','FontSize',10);
    cmap = importdata('hot_cold_cmap.mat');
    colormap(cmap);
    
    if strcmp(axes_type,'values')
        xlabel('Inter-Electrode Distance (nm)');
        ylabel('Log(Conductance/G_0)'); 
        a.Box = 'on';
    elseif strcmp(axes_type,'grid') || strcmp(axes_type,'both')
        xlabel('Inter-Electrode Distance Grid #');
        ylabel('Log(Conductance/G_0) Grid #'); 
        
        %Add secondary axes if requested
        if strcmp(axes_type,'both')
            secondary_axes_ForValues(GCO);
        else
            a.Box = 'on';
        end
    end
    
end