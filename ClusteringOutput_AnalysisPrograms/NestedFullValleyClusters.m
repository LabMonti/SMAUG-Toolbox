function [valley_bounds, valley_tops] = NestedFullValleyClusters(RD,...
    cutoff_frac,optional_save_name)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: 
    %
    %~~~INPUTS~~~:
    %
    %
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    

    if nargin < 3
        optional_save_name = [];
    end
    if nargin < 2
        cutoff_frac = 0.01;
    end
    
    %Find all the valleys
    [valley_bounds, valley_tops] = Find_ReachabilityValleys(RD, ...
        cutoff_frac);    
    
    Nclust = size(valley_bounds,1);
    clust_colors = distinguishable_colors(Nclust);
    
    %Sort valleys in decreasing order of their tops
    [valley_tops, sortI] = sort(valley_tops,'descend');
    valley_bounds = valley_bounds(sortI,:);

    %Make the reachability plot figure
    if isempty(optional_save_name)
        figure();
    else
        %If the figure is getting saved, we won't visibly plot it (great
        %for running on a cluster)
        figure('visible','off');
    end
    plot(RD,'Color',[0 0 0]);
    ylim([0 max(valley_tops)*1.5]);
    xlabel('Cluster Order');
    ylabel('Reachability Distance');
    
    %Add each valley to the reachability plot figure
    hold on;
    for i = 1:Nclust
        xdata = (valley_bounds(i,1):valley_bounds(i,2))';
        ydata = RD(valley_bounds(i,1):valley_bounds(i,2));%% + nested(i) * adjustment;
        
        ydata = min(ydata, valley_tops(i));
        
        n = length(ydata);
        ydata(1) = valley_tops(i);
        ydata(n) = valley_tops(i);
        
        fill(xdata,ydata,clust_colors(i,:),'LineStyle','none');
    end
    hold off;
    
    %Save the figure and close it, if requested
    if ~isempty(optional_save_name)
        print(strcat(optional_save_name,'_ReachabilityPlot'),'-dpng');
        close;
    end
    
end