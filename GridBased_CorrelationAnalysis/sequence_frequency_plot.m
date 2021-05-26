function sequence_frequency_plot(GCO,NodeFreqs,normalization_constant,...
    title_string)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: makes a 2D plot showing the frequency with which
    %each node appeared in an MCMC distribution. The MCMC distribution is
    %actually a distribution of node sequences, but such a distribution is
    %hard to visualize, so for each individual node we just add up the
    %total probability of it being included in any node sequence and plot
    %that. 
    %
    %~~~INPUTS~~~:
    %
    %GCO: the GridCorrelationObject with the node information for the
    %   dataset that the MCMC simulation was run on 
    %
    %NodeFreqs: a vector listing the frequency with which each node in the
    %   dataset appeared in the MCMC results
    %
    %normalization_constant: a constant that the node frequencies will be
    %   divided by before their values are displayed in the plot (e.g., #
    %   of MCMC steps)
    %
    %title_string: string to use as the title of the plot
    
    
    if nargin < 4
        title_string = 'Node Frequencies';
    end
    if nargin < 3
        normalization_constant = 1;
    end
    
    cmap = importdata('cmap.mat');

    %Plot all the color-coded nodes
    figure();
    hold on;
    scatter(GCO.UniqueNodes(:,1),GCO.UniqueNodes(:,2),9,[0.5 0.5 0.5]);
    scatter(GCO.UniqueNodes(:,1),GCO.UniqueNodes(:,2),8,...
        NodeFreqs/(normalization_constant),'filled');
    colormap(cmap);
    colorbar();

    %Add labeled colorbar
    title(title_string);
    xlabel('Inter-Electrode Distance Grid #');
    ylabel('Log(Conductance) Grid #');
    f = gcf;
    f.Children(1).Label.String = 'Probability Node is Included in Sequence';
    f.Children(1).Label.Rotation = 270;
    f.Children(1).Label.VerticalAlignment = 'bottom';
end