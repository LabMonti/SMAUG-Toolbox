%10May18 NDB: plots the clustering solution in the case that extended
%traces were what was clustered
function PlotClusterSolution_Traces(OutputStruct,Y,T,eps,PlotNoise)
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
    
    if nargin < 5
        PlotNoise = false;
    end

    data = OutputStruct.Xraw(OutputStruct.order, :);

    nNonNoiseClust = size(T,1) - 1;
    cluster_colors = distinguishable_colors(nNonNoiseClust);
    
    %Remove noise traces if applicable, set total # of clusters
    if PlotNoise
        nClust = nNonNoiseClust + 1;
        cluster_colors = [0.5 0.5 0.5; cluster_colors];
        offset = 1;
    else
        data = data(Y > 0, :);
        Y = Y(Y > 0);
        T = T(2:nNonNoiseClust+1,:);
        nClust = nNonNoiseClust;
        offset = 0;
    end
    N = length(Y);
       
    TrCols = zeros(N, 3);
    for i = 1:N
        TrCols(i, :) = cluster_colors(Y(i)+offset, :);
    end

    %Make the plot
    figure();   
    hold on;
    Xdist = OutputStruct.Xdist;   
    add_extendedtraces_to_plot(Xdist,data,TrCols);
    hold off;
    
    set(gca,'yscale','log');
    
    %Append cluster percentages to each cluster:
    newlabels = cell(1,nClust);
    for i = 1:nClust
        percentage = T(i,3)*100;
        newlabels(i) = strcat(num2str(T(i,1)),{', '}, num2str(percentage,2),'%');
    end    
    
    %plot(Xdist, data, 'LineWidth', 0.1);
    colormap(cluster_colors);
    lcolorbar(newlabels);
    title(strcat('For eps =',{' '},num2str(eps)));
    ylim([10^(-6) 10]);
    xlabel('Interelectrode Distance (nm)');
    ylabel('Conductance/G0');

end