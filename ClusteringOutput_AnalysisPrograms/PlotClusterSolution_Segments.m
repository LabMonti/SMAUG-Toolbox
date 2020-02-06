%10May18 NDB: Plots the clustering solution in the case that trace segments
%were the data that was clustered.  Plots the linear segments themselves. 
function PlotClusterSolution_Segments(OutputStruct, Y, T, eps, PlotNoise)
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
    
    
    if nargin < 5
        PlotNoise = false;
    end
    
    disp('Plotting cluster solution...');
    
    order = OutputStruct.order;

    AllSegments = OutputStruct.AllSegments;
    AllSegments = AllSegments(order,:);
    
    %get colors for each non-noise cluster
    nClust = size(T,1);
    nNonNoiseClust = nClust - 1;
    cluster_colors = distinguishable_colors(nNonNoiseClust);
    
    %If noise is being plotted, add gray color to represent noise
    if PlotNoise
        cluster_colors = [0.5 0.5 0.5; cluster_colors];
        offset = 1;
        
        %Sort so that noise is plotted first and other clusters on top:
        [Y, sortI] = sort(Y);
        AllSegments = AllSegments(sortI,:);
        
    %If noise is not being plotted, remove noise segments
    else
        AllSegments = AllSegments(Y > 0,:);
        Y = Y(Y > 0);  
        offset = 0;
    end
    nSegments = size(AllSegments,1);
    
    %Assign color to each segment being plotted
    plotting_colors = zeros(nSegments, 3);
    for i = 1:nSegments
        plotting_colors(i,:) = cluster_colors(Y(i) + offset,:);
    end
    
    %Make the plot
    figure();
    add_linearsegments_to_plot(AllSegments,plotting_colors);
    set(gca,'YScale','log');
    xlabel('Inter-Electrode Distance (nm)');
    ylabel('Conductance/G_0');
    title(strcat('Cluster solution at eps =',num2str(eps)));
    
    %If noise is not being plotted, add a white section on the color bar to
    %represent the noise (Needs to happend AFTER the plotting of segments
    %so that we don't screw up cluster_colors's indexing)
    if ~PlotNoise
        cluster_colors = [1 1 1; cluster_colors];
    end
    
    %Plot cluster colorbar with labels
    newlabels = cell(1,nClust);
    for i = 1:nClust
        percentage = T(i,3)*100;
        newlabels(i) = strcat(num2str(T(i,1)),{', '}, num2str(percentage,2),'%');
    end  
    colormap(cluster_colors);
    lcolorbar(newlabels);

end