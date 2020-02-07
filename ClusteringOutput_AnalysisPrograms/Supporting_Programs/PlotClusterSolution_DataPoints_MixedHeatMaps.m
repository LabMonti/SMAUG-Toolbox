function PlotClusterSolution_DataPoints_MixedHeatMaps(data, order, Y, T, eps, nbinsX1, ...
    nbinsX2, PlotNoise)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Plots the clustering solution in the case that
    %2d data points (distance, log(G/G_0)) were the data that was clustered
    %In order to plot lots of 2D data points, a 2D histogram is actually
    %plotted, with the color of each bin representing a weighted average 
    %of the cluster IDs of all the raw data points inside that bin
    %(weighting depends on ABSOLUTE number of points in each cluster)
    %
    %~~~INPUTS~~~:
    %
    %data: array of raw data, with 1st column being distance and 2nd column
    %   being log(G/G_0)
    %
    %order: vector containing cluster order; if order(5) = 12 that means
    %the 5th point in the cluster order is the 12th raw of data
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
    %nbinsX1/nbinsX2: total # of bins to use when plotting data in the x
    %   and y dimensions, respectively
    %
    %PlotNoise: logical variable, whether to visibly plot the noise cluster
    %   or not
    
    
    %Default inputs
    if nargin < 8
        PlotNoise = false;
    end
    if nargin < 7
        nbinsX2 = 150;
    end
    if nargin < 6
        nbinsX1 = 150;
    end
       
    %Sort data to line up with RD, Y, etc.
    data = data(order, :);

    %Get colors for all non-noise clusters
    nClust = max(Y);
    labels = (0:nClust);
    cluster_colors = distinguishable_colors(nClust);    
    
    %Either remove noise points or add a gray color to represent them
    if PlotNoise
        offset = 1;
        nClust = nClust + 1;
        cluster_colors = [0.5 0.5 0.5; cluster_colors];
    else
        offset = 0;
        data = data(Y > 0, :);
        Y = Y(Y > 0);
    end    
        
    N = length(Y);
       
    BigHistogram = zeros(nbinsX1, nbinsX2, nClust);

    minX1 = min(data(:,1));
    minX2 = min(data(:,2));
    rangeX1 = range(data(:,1));
    rangeX2 = range(data(:,2));
    
    disp('Binning data...');
    
    %Make a three dimensional histogram, third dimension has one box for
    %each cluster
    for i = 1:N
         
        binX1 = round((data(i,1) - minX1) * nbinsX1/rangeX1 + 0.5);
        binX2 = round((data(i,2) - minX2) * nbinsX2/rangeX2 + 0.5);
        binX1 = min(binX1, nbinsX1);
        binX1 = max(1, binX1);
        binX2 = min(binX2, nbinsX2);   
        binX2 = max(1, binX2);
        
        %Add 1 if noise is included because noise is ID# 0
        binY = Y(i) + offset;

        BigHistogram(binX1, binX2, binY) = BigHistogram(binX1, binX2, binY) + 1;
        
    end
    
    %For each cluster, find the most # of points in a single bin:
    ClustMaxCounts = max(max(BigHistogram));
    
    %Find whether each bin has any points in it or not
    BiggestCounts = max(BigHistogram,[],3);
    
    %Choose a color for each bin by first assigning a color intensity to
    %each cluster represented in that bin, then taking a simple average of
    %all those clusters
    ColorHist = zeros(nbinsX1,nbinsX2,3);
    for i = 1:nbinsX1
        for j = 1:nbinsX2

            color = [0 0 0];
            points_in_bin = 0;
            
            for k = 1:nClust
                if BigHistogram(i,j,k) > 0
                    points_in_bin =  points_in_bin + BigHistogram(i,j,k);
                    
                    %Take the color of this cluster, and mix in more white
                    %the fewer points from the cluster are in the bin
                    cc = BigHistogram(i,j,k)/ClustMaxCounts(k) * (cluster_colors(k,:) - [1 1 1]) + [1 1 1];
                    
                    %Scale color by # of points in cluster
                    color = color + cc * BigHistogram(i,j,k);
                end
            end
            
            %Divide by total # of points in cluster so that the mixture of
            %cluster colors is weighted by # of points
            ColorHist(i,j,:) = color ./ points_in_bin;            
            
        end
    end

    %Make columns for plotting
    PlottingColumns = zeros(nbinsX1*nbinsX2, 5);
    X1step = rangeX1 / nbinsX1;
    X2step = rangeX2 / nbinsX2;
    counter = 0;
    for i = 1:nbinsX1
        for j = 1:nbinsX2
            if BiggestCounts(i,j) > 0 %Don't need to plot empty bins
                counter = counter + 1;
                PlottingColumns(counter, 1) = minX1 + X1step/2 + (i-1)*X1step;
                PlottingColumns(counter, 2) = minX2 + X2step/2 + (j-1)*X2step;
                PlottingColumns(counter, 3:5) = ColorHist(i,j,:);
            end
        end
    end
    PlottingColumns = PlottingColumns(1:counter,:);
    
    disp('Plotting cluster solution...');
    
    %Find bounds of data
    MIN(1) = min(data(:,1));
    MIN(2) = min(data(:,2));
    MAX(1) = max(data(:,1));
    MAX(2) = max(data(:,2));   
    RANGE(1) = range(data(:,1));
    RANGE(2) = range(data(:,2));
    
    %Make cluster labels:
    newlabels = cell(1,length(labels));
    for i = 1:length(labels)
        percentage = T(i,3)*100;
        newlabels(i) = strcat(num2str(labels(i)),{', '}, num2str(percentage,2),'%');        
    end
    
    %If noise is not being plotted, still include it on the color bar (as
    %white) so that we can easily see the percentage of points in the noise
    %cluster
    if ~PlotNoise
        cluster_colors = [1 1 1; cluster_colors];
    end
    
    figure();
    hold on;
    add_histcolumndata_to_plot(PlottingColumns(:,1:2),PlottingColumns(:,3:5));
    set(gca,'YScale','log');
    title(strcat('For eps =',{' '},num2str(eps)));
    colormap(cluster_colors);
    lcolorbar(newlabels);
    xlabel('Interelectrode Distance (nm)');
    ylabel('Conductance/G_0');
    
    xlim([MIN(1) - 0.05*RANGE(1), MAX(1) + 0.05*RANGE(1)]);
    ylim([10^(MIN(2) - 0.05*RANGE(2)), 10^(MAX(2) + 0.05*RANGE(2))]);

end