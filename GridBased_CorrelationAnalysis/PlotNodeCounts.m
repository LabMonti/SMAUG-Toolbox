function PlotNodeCounts(GridCorrObj, axes_type)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: makes a plot showing the # of coarsened traces
    %that passed through each node in the dataset
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: GridCorrelationObject containing coarsened traces for a
    %   given dataset
    %
    %axes_type: string variable to indicate how the data should be plotted;
    %   can be set to "grid" (default) to plot grid #s in x and y, "values"
    %   to plot the actual x and y values (in nm and Log(G0), say) of each
    %   node, or to plot both grid #s and values, with values on a set of
    %   secondary axes

    
    if nargin < 2
        axes_type = 'grid';
    end
    
    if ~any(strcmp(axes_type,{'values','grid','both'}))
        disp('Unrecognized axes type, defaulting to "grid"');
        axes_type = 'grid';
    end

    NodeFreqs = GridCorrObj.NodeFreqs;
    UniqueNodes = GridCorrObj.UniqueNodes;
    
    %Get x- and y-values; if needed, convert them from grid units to "real"
    %units
    xValues = UniqueNodes(:,1);
    yValues = UniqueNodes(:,2);
    if strcmp(axes_type,'values')
        xValues = xValues*GridCorrObj.Xstep + GridCorrObj.Xstart;
        yValues = yValues*GridCorrObj.Ystep + GridCorrObj.Ystart;
    end
    
    %Make the plot
    figure();
    scatter(xValues, yValues, 10, NodeFreqs, 'o', 'filled');
    cmap = importdata('cmap.mat');
    colormap(cmap);
    colorbar();
    
    %Label the axes
    if strcmp(axes_type,'values')
        xlabel('Inter-Electrode Distance (nm)');
        ylabel('Log(Conductance/G_0)');    
    else
        xlabel('Inter-Electrode Distance Grid #');
        ylabel('Log(Conductance/G_0) Grid #');
    end
    
    %Label color bar
    f = gcf;
    f.Children(1).Label.String = '# of Traces Through Node';
    f.Children(1).Label.VerticalAlignment = 'bottom';
    f.Children(1).Label.Rotation = 270;
    
    %Add secondary axes if requested
    if strcmp(axes_type,'both')
        secondary_axes_ForValues(GridCorrObj);
    else
        a = gca;
        a.Box = 'on';
    end
end