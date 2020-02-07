%04May18 NDB: Plots the clustering solution in the case that histogram data
%(dist, log(G), counts) was the data that was clustered
function PlotClusterSolution_Histogram(OutputStruct, Y, T, eps, PlotNoise)
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

    disp('Plotting cluster solution...');
    
    %Default is to NOT plot noise
    if nargin < 5
        PlotNoise = false;
    end
    
    %If there are no noise points, then don't plot them!
    if T(1,2) == 0
        PlotNoise = false;
    end
    
    %If the noise is plotted, it will be as a neutral gray color
    noise_color = [0.5 0.5 0.5];
       
    data = OutputStruct.Xraw;
    order = OutputStruct.order;

    %Sort data to line up with Y (i.e, put in cluster order)
    data = data(order, :);
    
    %Find bounds of data
    MIN(1) = min(data(:,1));
    MIN(2) = min(data(:,2));
    MAX(1) = max(data(:,1));
    MAX(2) = max(data(:,2));   
    RANGE(1) = range(data(:,1));
    RANGE(2) = range(data(:,2));
    
    %Get colors for all non-noise clusters
    nNonNoiseClust = size(T, 1) - 1;
    cluster_colors = distinguishable_colors(nNonNoiseClust);
    
    %If the noise is being plotted, add noise color to front of color array
    if PlotNoise
        nClust = nNonNoiseClust + 1;
        cluster_colors = [noise_color ; cluster_colors];
        labels = (0:nClust-1);
        offset = 1;
    %If noise is not being plotted, remove it from data array
    else
        data = data(Y > 0,:);
        Y = Y(Y > 0);       
        nClust = nNonNoiseClust;
        T = T(2:nClust+1,:);
        labels = (1:nClust);
        offset = 0;
    end
    N = length(Y);
   
    %Make vector of cluster IDs to decide color of each point
    point_colors = zeros(N,1);
    for i = 1:N
        point_colors(i) = Y(i) + offset;
    end
    
    disp('Creating plot...');
    
    %Append cluster percentages to each cluster:
    newlabels = cell(1,nClust);
    for i = 1:nClust
        percentage = T(i,3)*100;
        newlabels(i) = strcat(num2str(labels(i)),{', '}, num2str(percentage,2),'%');        
    end
    
    figure();
    hold on;
    add_histcolumndata_to_plot(data,point_colors);
    set(gca,'YScale','log');
    title(strcat('For eps =',{' '},num2str(eps)));
    colormap(cluster_colors);
    lcolorbar(newlabels);
    xlabel('Interelectrode Distance (nm)');
    ylabel('Conductance/G_0');
    
    xlim([MIN(1) - 0.05*RANGE(1), MAX(1) + 0.05*RANGE(1)]);
    ylim([10^(MIN(2) - 0.05*RANGE(2)), 10^(MAX(2) + 0.05*RANGE(2))]);
    
    disp('Plotting Complete');

end