function PlotClusterSolution_MedianTraceSegments(OutputStruct, Y, ...
    T, eps, PlotNoise, CentralPercents)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Plot a specific clustering solution based on the
    %"Segment" format of clustering, but for the actual plotting, get the
    %original trace segments that each segment was fit and average (well,
    %median) them together at each distance point to get "median segments",
    %as well as regions containing the central X% of segments at each
    %distance
    %
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output
    %
    %Y: vector of cluster assignments for each point (in order of cluster
    %   order)
    %
    %T: array of cluster sizes (1st column: cluster ID, 2nd column: #
    %   points in cluster, 3rd column: fraction of points in cluster)
    %
    %eps: the value of epsilon at which extraction takes place; clusters
    %   will be valleys that exist below this cut-off value in the
    %   reachability plot
    %
    %PlotNoise: logical variable, whether to visibly plot the noise cluster
    %   or not
    %
    %CentralPercents: list of middle percentages that shading will be
    %   plotted around.  So, for example, including a value of 50 in this
    %   list will cause the inter-quartile range of all segments in each
    %   cluster to be included in the plot.  
    
    if nargin < 6
        CentralPercents = [50 75 90];
    end
    CentralPercents = sort(CentralPercents, 'descend');
    if nargin < 5
        PlotNoise = false;
    end
    
    disp('Averaging Segments...');
    
    order = OutputStruct.order;   
    AlignedSegments = OutputStruct.AlignedSegments;
    ActiveRegions = OutputStruct.ActiveRegions;
    Xdist = OutputStruct.Xdist;
    nXvals = size(AlignedSegments,2);
    
    %Re-sort aligned segments to have same order as Y
    AlignedSegments = AlignedSegments(order,:);
    ActiveRegions = ActiveRegions(order,:);
    
    %Account for the possiblity that the noise cluster is empty
    if T(1,2) == 0
        offset = 0;
    else
        offset = 1;
    end
    
    %Sort the aligned segments to group segments from the same cluster
    [sortedY, sortI] = sort(Y);
    AlignedSegments = AlignedSegments(sortI,:);
    ActiveRegions = ActiveRegions(sortI,:);
    
    %Get # of clusters
    nClust = length(unique(Y));

    %Get median segments and different percetile boundaries for each
    %segment
    cluster_indices = sortedY + offset;
    [ActiveBounds, MedianSegments, PercentileRegions] = ...
        prepare_AverageSegments(AlignedSegments, ActiveRegions, nClust, ...
        CentralPercents, cluster_indices);  
       
    disp('Plotting cluster solution...');
    
    nNonNoiseClust = size(T,1) - 1;    
    cluster_colors = distinguishable_colors(nNonNoiseClust);
    if PlotNoise && T(1,2) > 0
        cluster_colors = [0.5 0.5 0.5; cluster_colors];
    end
    if T(1,2) > 0 && ~PlotNoise
        ActiveBounds = ActiveBounds(:,2:nClust,:);
        MedianSegments = MedianSegments(:,2:nClust);
        PercentileRegions = PercentileRegions(:,2:nClust,:,:);
        nClust = nClust - 1;
    end
    
    figure();
    set(gca,'YScale','log');
    hold on;
    for i = 1:nClust        
        add_averagesegment_to_plot(Xdist,MedianSegments(:,i),...
            PercentileRegions(:,i,:,:),squeeze(ActiveBounds(:,i,:)),...
            cluster_colors(i,:));
    end    
    hold off;   
    
    %Account for the fact that the noise cluster may be empty
    if PlotNoise && T(1,2) == 0
        nClust = nClust + 1;
        cluster_colors = [0.5 0.5 0.5; cluster_colors];
    end
    
    %If noise is not being PLOTTED, still include it in the color bar (as
    %white)
    if ~PlotNoise
        cluster_colors = [1 1 1; cluster_colors];
        nClust = nClust + 1;
    end
    
    %Append cluster percentages to each cluster:
    newlabels = cell(1,nClust);
    for i = 1:nClust
        percentage = T(i,3)*100;
        newlabels(i) = strcat(num2str(T(i,1)),{', '}, num2str(percentage,2),'%');
    end
    
    colormap(cluster_colors);
    lcolorbar(newlabels);

    title(strcat('For eps =',{' '},num2str(eps)));
    ylim([1E-6 10]);
    xlabel('Interelectrode Distance (nm)');
    ylabel('Log(Conductance/G0)');

end