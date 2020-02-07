function [Y, T] = excludeLowIntensityPoints(X, order, Y)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: In accordance with Ben's paper, for histogram
    %clustering results this program finds clusters in which ALL the data
    %points correspond to bins with counts less than or equal to 5, and
    %re-assigns these clusters to the noise cluster
    %
    %~~~INPUTS~~~:
    %
    %X: data points being clustered as a 3-column array; distance in 1st
    %   column, log(conductance) in 2nd, bin count in 3rd
    %
    %order: the cluster order; if order(5) = 11 then the 5th point in the
    %   cluster order is the 11th data point in the original data array
    %
    %Y: column vector containing the cluster ID# that each point is 
    %   assigned to, in order of the cluster order. Cluster # 0
    %   always refers to the noise cluster, all other clusters have
    %   sequential positive integers as their ID#s
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %Y: Same as input Y except updated so that clusters consisting entirely
    %   of low-count bins have been re-assigned to the noise cluster
    %
    %T: an array containing ClusterIDs in the first column,
    %   total # of point assigned to each cluster in the 2nd column, and
    %   fraction of all points assigned to each cluster in the 3rd column
    %   (updated to account for changes made by this program!)
    
    
    disp('Excluding low-count clusters...');

    %Put data points in the same order as Y 
    orderedX = X(order,:);

    [idx,cnames] = grp2idx(Y);
    n = length(idx);
    k = length(cnames);
    mbrs = (repmat(1:k,n,1) == repmat(idx,1,k));
    
    %Make new cluster population array; account for the possibility that Y
    %may contain no noise points at the moment
    if str2double(cnames{1}) == 0
        T = zeros(k, 3);
        T(1,2) = sum(mbrs(:,1));
    else
        T = zeros(k+1,3);
    end
        
    cluster_num = 0;
    for i = 1:k
        %Don't need to do anything to points already in the noise cluster
        if str2double(cnames{i}) > 0
            if orderedX(mbrs(:,i),3) < 6
                Y(mbrs(:,i)) = 0;
                T(1,2) = T(1,2) + sum(mbrs(:,i));
            else
                cluster_num = cluster_num+1;
                Y(mbrs(:,i)) = cluster_num;
                T(cluster_num + 1, 2) = sum(mbrs(:,i));
                T(cluster_num + 1, 1) = cluster_num;
            end
        end
    end
    T = T(1:cluster_num+1,:);
    Tot = sum(T(:,2));
    
    for i = 1:cluster_num+1
        T(i,3) = T(i,2) / Tot;
    end
    
end