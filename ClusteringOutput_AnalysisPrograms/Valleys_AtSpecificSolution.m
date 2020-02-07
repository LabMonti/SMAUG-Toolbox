%NDB 22May19: Makes a reachability plot with the valleys filled in in
%colors to show where the different clusters are
function Valleys_AtSpecificSolution(RD, CD, eps, cutoff_frac)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Makes a reachability plot with the valleys 
    %filled in in colors to show where the different clusters are for a
    %specific clusteirng solution (extraction level)
    %
    %~~~INPUTS~~~:
    %
    %RD: column vector of reachability distances for each data point (in
    %   the order of the cluster order)
    %
    %CD: column vector of core distances for each data point (in the order
    %   of the cluster order)
    %
    %eps: the value of epsilon at which extraction takes place; clusters
    %   will be valleys that exist below this cut-off value in the
    %   reachability plot
    %
    %cutoff_fraction: the minimum size a valley in the reachability plot
    %   must be to be considered a true cluster, as a fraction of the total
    %   # of data points (so 0.02 means clusters must contain at least 2%
    %   of all data points). Points in valleys with fewer than this # of
    %   data points are re-assigned to the noise cluster 
    
    
    %Assign each point to a cluster
    [Y,T,~] = ExtractClusterSolution(RD,CD,eps,cutoff_frac);
    
    %Get number of non-noise clusters
    nClust = size(T,1) - 1;
    
    %We're going to find the staring and ending cluster order numbers of
    %each cluster (b/c each cluster must be contiguous in the cluster
    %order)
    cluster_sections = zeros(nClust,2);
    begun = false(nClust);
    
    %Now go through and find the extent of each cluster.  Yes, this could
    %be accomplished with much less code by using "find", but that would be
    %more inefficient.  This way, we only need to walk through Y once.  
    i = 1;
    while i < length(Y)   
        if Y(i) > 0
            if ~begun(Y(i))
                current_clust = Y(i);
                begun(current_clust) = true;
                cluster_sections(current_clust,1) = i;
                while Y(i) == current_clust && i <= length(Y)
                    i = i + 1;
                end
                if i == length(Y)
                    cluster_sections(current_clust,2) = i;
                else
                    cluster_sections(current_clust,2) = i-1;
                end
            end
        else
            i = i + 1;
        end
    end
    
    %Make the reachability plot
    figure();
    plot(RD,'color',[0 0 0]);
    hold on;
    
    %Get the same colors as are used in clustering solutions
    clust_colors = distinguishable_colors(nClust);
    
    %Fill in each cluster valley with the appropriate color
    for i = 1:nClust
        %Get border of cluster valley
        xdata = (cluster_sections(i,1):cluster_sections(i,2))';
        ydata = RD(cluster_sections(i,1):cluster_sections(i,2));
        
        %Set top of colored in valley to the extraction epsilon
        n = length(ydata);
        ydata(1) = eps;
        ydata(n) = eps;
        
        fill(xdata,ydata,clust_colors(i,:),'LineStyle','none');
    end

    xlabel('Cluster Order');
    ylabel('Reachability Distance');
    title(strcat('Extraction at epsilon =', {' '}, num2str(eps)));


end