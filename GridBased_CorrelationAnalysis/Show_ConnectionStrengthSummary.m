function Show_ConnectionStrengthSummary(GridCorrObj, axes_type, ...
    SmoothStrengths)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: For each node in a dataset, this function takes
    %the RMS of the connection strengths of all other nodes with that node,
    %and assigns that value to the original node. It then makes a plot to
    %show the distribution of these values in 2D. The idea is that
    %"significant" nodes will have large connection strengths with lots of
    %other nodes and hence can be identified by larger RMS values.
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: GridCorrelationObject containing coarsened traces and
    %   connection strength information for a given dataset
    %
    %axes_type: string variable to indicate how the data should be plotted;
    %   can be set to "grid" (default) to plot grid #s in x and y, "values"
    %   to plot the actual x and y values (in nm and Log(G0), say) of each
    %   node, or to plot both grid #s and values, with values on a set of
    %   secondary axes
    %
    %SmoothStrengths: logical variable; whether or not to "smooth" the
    %   connection strength distribution, by averaging each node with its 8
    %   nearest neighbors, before computing the RMS
    
    
    if nargin < 3
        SmoothStrengths = true;
    end
    if nargin < 2
        axes_type = 'grid';
    end
    
    if ~any(strcmp(axes_type,{'values','grid','both'}))
        disp('Unrecognized axes type, defaulting to "grid"');
        axes_type = 'grid';
    end

    MinThrough = 1;

    NUnique = GridCorrObj.NUnique;
    NodeFreqs = GridCorrObj.NodeFreqs;
    UniqueNodes = GridCorrObj.UniqueNodes;
    AllNodeIDs = GridCorrObj.AllNodeIDs;
    
    AllRMSStrengths = zeros(NUnique,1);

    %For each node, find the RMS of the
    %connection strength between that node and all others
    for i = 1:NUnique
        if NodeFreqs(i) >= MinThrough
            %Sum the probability of going to or from each other node from
            %the curent node
            to_or_from = GridCorrObj.ExpectedNodePairProbs(i,1:NUnique) + ...
                GridCorrObj.ExpectedNodePairProbs(1:NUnique,i)';
            
            %If requested, first "smooth" the distribution of pair
            %strengths for each node by averaging with its 8 nearest
            %neighbors (this helps accentuate regions of correlation versus
            %random correlations)
            pair_strengths = GridCorrObj.ConnectionStrengths(i,1:NUnique);
            if SmoothStrengths
                pair_strengths = twoD_nodeSmooth(UniqueNodes, AllNodeIDs, ...
                    pair_strengths, false);
            end
            
            %For normalization of RMS strength, only include # of nodes
            %that could possibly be gone to or from
            AllRMSStrengths(i) = sqrt(sum(pair_strengths.^2)/...
                sum(to_or_from ~=0 ));
        end
    end
    
    %Get x- and y-values for nodes in appropriate units
    if strcmp(axes_type,'values')
        UniqueNodes(:,1) = UniqueNodes(:,1)*GridCorrObj.Xstep + GridCorrObj.Xstart;
        UniqueNodes(:,2) = UniqueNodes(:,2)*GridCorrObj.Ystep + GridCorrObj.Ystart;
    end
    
    figure();
    ss = 10;
    scatter(UniqueNodes(:,1),UniqueNodes(:,2),ss,AllRMSStrengths,'filled');
    if strcmp(axes_type,'values')
        ylabel('Log(Conductance/G_0)');
        xlabel('Inter-Electrode Distance (nm)');
    else
        ylabel('Log(Conductance) Grid #');
        xlabel('Inter-Electrode Distance Grid #');
    end

    %Create and Label the color bar
    colorbar();
    a = gca;
    h = a.Colorbar;
    if SmoothStrengths
        set(get(h,'label'),'string','RMS Smoothed Connection Strength RMS with All Other Nodes',...
            'Rotation',-90,'VerticalAlignment','bottom','FontSize',8);
    else
        set(get(h,'label'),'string','RMS Connection Strength with All Other Nodes',...
            'Rotation',-90,'VerticalAlignment','bottom','FontSize',8);
    end
    cmap = importdata('cmap.mat');
    colormap(cmap);

    %Add secondary axes if requested
    if strcmp(axes_type,'both')
        secondary_axes_ForValues(GridCorrObj);
    else
        a.Box = 'on';
    end
    
end