%10May18 NDB: Plots the clustering solution in the case that 2d data points
%(distance, log(G/G_0)) were the data that was clustered
%In order to plot lots of 2D data points, a 2D histogram is actually
%plotted, with the color of each bin representing a weighted average of the
%cluster IDs of all the raw data points inside that bin
function PlotClusterSolution_DataPoints_ColorMix(data, order, Y, T, eps, nbinsX1, ...
    nbinsX2, PlotNoise)
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

    if PlotNoise
        noise_is_white = false;
    else
        noise_is_white = true; %Can be toggled!
    end
        
    %Sort data to line up with RD, Y, etc.
    data = data(order, :);
    
    N = length(Y);
    nbinsY = size(T,1);
    
    %Get colors for all non-noise clusters
    cluster_colors = distinguishable_colors(nbinsY - 1,{'w','k'});
    
    %Add color for noise, either white or gray:
    if noise_is_white
        cluster_colors = [1 1 1; cluster_colors];
    else
        cluster_colors = [0.5 0.5 0.5; cluster_colors];
    end
       
    BigHistogram = zeros(nbinsX1, nbinsX2, nbinsY);

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
        
        %Add 1 because the noise cluster is ID#1
        binY = Y(i) + 1;

        BigHistogram(binX1, binX2, binY) = BigHistogram(binX1, binX2, binY) + 1;
        
    end
    
    %Find number of data points in each bin
    MatCounts = max(BigHistogram,[],3);
    
    %Choose a color for each bin using a weighted average of points
    %assigned to each cluster
    ColorHist = zeros(nbinsX1,nbinsX2,3);
    for i = 1:nbinsX1
        for j = 1:nbinsX2
            
            if MatCounts(i,j) > 0
                color = [0 0 0];
                total_points = 0;
                for k = 1:nbinsY
                    color = color + BigHistogram(i,j,k)*cluster_colors(k,:);
                    total_points = total_points + BigHistogram(i,j,k);
                end
                ColorHist(i,j,:) = color ./ total_points;
            end
            
        end
    end

    %Make columns for plotting
    PlottingColumns = zeros(nbinsX1*nbinsX2, 5);
    X1step = rangeX1 / nbinsX1;
    X2step = rangeX2 / nbinsX2;
    counter = 0;
    for i = 1:nbinsX1
        for j = 1:nbinsX2
            if MatCounts(i,j) > 0 %Don't need to plot empty bins
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
    labels = (0:nbinsY - 1);
    newlabels = cell(1,nbinsY);
    for i = 1:nbinsY
        percentage = T(i,3)*100;
        newlabels(i) = strcat(num2str(labels(i)),{', '}, num2str(percentage,2),'%');        
    end
    
    figure();
    scatter(PlottingColumns(:,1), 10.^PlottingColumns(:,2), 100, PlottingColumns(:,3:5), 'filled', 's');
    set(gca,'YScale','log');
    title(strcat('For eps =',{' '},num2str(eps)));
    colormap(cluster_colors);
    lcolorbar(newlabels);
    xlabel('Interelectrode Distance (nm)');
    ylabel('Conductance/G_0');
    
    xlim([MIN(1) - 0.05*RANGE(1), MAX(1) + 0.05*RANGE(1)]);
    ylim([10^(MIN(2) - 0.05*RANGE(2)), 10^(MAX(2) + 0.05*RANGE(2))]);

end