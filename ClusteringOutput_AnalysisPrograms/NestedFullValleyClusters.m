function [valley_bounds, valley_tops] = NestedFullValleyClusters(...
    OutputStruct, cutoff_frac, optional_save_name)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Dispay a reachability plot with each full-valley
    %cluster filled in with a different color (and nested so that
    %sub-valeys are on top of valleys)
    %
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output
    %
    %cutoff_fraction: the minimum size a valley in the reachability plot
    %   must be to be considered a true cluster, as a fraction of the total
    %   # of data points (so 0.02 means clusters must contain at least 2%
    %   of all data points). Points in valleys with fewer than this # of
    %   data points are re-assigned to the noise cluster
    %
    %optional_save_name: optional file name; if included, plot will not be
    %   visibly made but will instead be saved to variations of save_name
    %   (plus an extension). To plot figures visibly, leave this input out
    %   or set it to an empty vector
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %      
    %valley_bounds: a two-column matrix indicating the starting and ending
    %   indices for each valley in the cluster order
    %
    %valley_tops: the extraction level that aligns with the very top of
    %   each valley, which can be used to extrat each "maximum valley
    %   cluster"

    
    if nargin < 3
        optional_save_name = [];
    end
    if nargin < 2
        cutoff_frac = 0.01;
    end
    
    %Find all the valleys
    RD = OutputStruct.RD;
    [valley_bounds, valley_tops] = Find_ReachabilityValleys(RD, ...
        cutoff_frac);    
    
    %Sort valleys in decreasing order of their tops
    [valley_tops, sortI] = sort(valley_tops,'descend');
    valley_bounds = valley_bounds(sortI,:);
    
    %Exclude low-intensity valleys if using the Wu clustering method
    if strcmp(OutputStruct.Format,'Histogram')
        counts = OutputStruct.Xraw(:,3);
        counts = counts(OutputStruct.order);
        [valley_bounds,valley_tops] = excludeLowIntensityValleys(counts,...
            valley_bounds,valley_tops);
    end
    
    Nclust = size(valley_bounds,1);
    clust_colors = distinguishable_colors(Nclust);
    
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