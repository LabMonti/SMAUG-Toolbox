function add_averagesegment_to_plot(Xdist, MedianSegment, ...
    PercentileRegions, ActiveBounds, cluster_color)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: adds pre-calculated "average segments" (with
    %percentile bounds) to an already existing figure
    %
    %~~~INPUTS~~~:
    %
    %Xdist: a vector containing x-values corresponding to the y-values in
    %   MedianSegment and PercentileRegions
    %
    %MedianSegment: a vector containing the median value of all segments
    %   belonging to a given cluster 
    %
    %PercentileRegions: a matrix containing  the bounds of different
    %   percentile regions (e.g., the region containing the middle 80% of
    %   all segments at a given distance).  Third dimension is indexed to
    %   different percentiles, 4th dimension contains top and bottom in
    %   indices 1 and 2.  
    %
    %ActiveBounds: a matrix indicating which regions of MedianSegment and
    %   PerctileRegions have enough points to be meaningful.  MedianSegment
    %   comes first, then each PercentileRegion in order.  
    %
    %cluster_color: the color that should be used for the average segment

        
    %Plot the median as a single black line:
    xdata = Xdist(ActiveBounds(1,1):ActiveBounds(1,2));
    ydata = MedianSegment(ActiveBounds(1,1):ActiveBounds(1,2));
    line(xdata,10.^ydata,'Color',[0 0 0],'LineWidth',1.5);

    for j = 1:size(PercentileRegions,3)
        %If there were never enough points, ActiveBounds will be empty
        %for given percentile, in which case don't plot
        if ActiveBounds(j+1,1) > 0 && ActiveBounds(j+1,2) > 0

            xdata = Xdist(ActiveBounds(j+1,1):ActiveBounds(j+1,2));

            y_top = PercentileRegions(ActiveBounds(j+1,1):ActiveBounds(j+1,2),1,j,2);
            y_bottom = PercentileRegions(ActiveBounds(j+1,1):ActiveBounds(j+1,2),1,j,1);

            Xperim = [xdata; flipud(xdata)];
            Yperim = [y_top; flipud(y_bottom)];

            fill(Xperim,10.^Yperim,cluster_color,'FaceAlpha',0.4,'LineStyle','none');
        end
    end

end