function [ClusterAssignments, ClusterSizeArray, ClusterSizeTable] = ...
    ExtractClusterSolution(RD, CD, eps, cutoff_fraction)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: extract a specific cluster solution from the 
    %reachability plot; in other words, for a given epsilon value assign 
    %each point to a cluster and output those cluster assignments and the
    %cluster populations
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
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %ClusterAssignments: column vector containing the cluster ID# that each
    %   point is assigned to, in order of the cluster order. Cluster # 0
    %   always refers to the noise cluster, all other clusters have
    %   sequential positive integers as their ID#s
    %
    %ClusterSizeArray: an array containing ClusterIDs in the first column,
    %   total # of point assigned to each cluster in the 2nd column, and
    %   fraction of all points assigned to each cluster in the 3rd column
    %
    %ClusterSizeTable: same as ClusterSizeTable but in table form with
    %   column labels

    %disp('Extracting cluster solution...');

    N = length(RD);
    ClusterAssignments = zeros(N, 1);
    
    %Maybe not best solution, but not a big deal:
    CD(1) = 0;

    %Array to hold indices of points assigned to current cluster ID
    CurrClust_indices = zeros(ceil(N * cutoff_fraction)+5, 1);
    nCurrClust = 0;
    
    %Make vector to hold # of points in each non-noise cluster (maximum #
    %of different clusters is 1/cutoff_fraction)
    ClusterSizes = zeros(ceil(1/cutoff_fraction), 1);
    
    %# of points in noise cluster
    NoiseSize = 0;
    
    %Initial assignment of clusters, keeping track of cluster sizes
    clusterid = 1;
    noise = 0;
    for i = 1:N
        if RD(i) >= eps %The equal to is very important here, it lets us extract exatly at peak heights!
            % if reachability distance is larger than eps, cluster ID is undefined 
            if CD(i) <= eps

                %If previous cluster wasn't big enough, re-assign it to
                %noise and re-use the same row of the cluster size table
                if nCurrClust < floor(N * cutoff_fraction)
                    ClusterAssignments(CurrClust_indices(1:nCurrClust)) = noise;
                    
                    %Increase # in noise cluster by amount of this cluster
                    %being re-assigned to noise
                    NoiseSize = NoiseSize + nCurrClust;
                    
                    %Set to one because this new point will go in this re-used row
                    ClusterSizes(clusterid) = 1; 
                    
                %If previous cluster WAS big enough, we need to put the new
                %cluster in a new row
                else
                    clusterid = clusterid + 1;
                    ClusterSizes(clusterid) = 1;
                end
                
                %Assign first point to the new/re-used cluster
                ClusterAssignments(i) = clusterid;
                %ClusterSizes(clusterid+1,2) = ClusterSizes(clusterid+1,2)+1;
                nCurrClust = 1;
                CurrClust_indices(1) = i;

            else
                ClusterAssignments(i) = noise;
                NoiseSize = NoiseSize + 1;
            end
        else
            %Assign point to existing cluster
            ClusterAssignments(i) = clusterid;
            nCurrClust = nCurrClust + 1;
            CurrClust_indices(nCurrClust) = i;
            ClusterSizes(clusterid) = ClusterSizes(clusterid) + 1;
        end
    end
    
    %Need to check if the last cluster should be re-assigned to noise or
    %not
    if nCurrClust < floor(N * cutoff_fraction)
        ClusterAssignments(CurrClust_indices(1:nCurrClust)) = noise;
        NoiseSize = NoiseSize + nCurrClust;
        clusterid = clusterid - 1;
    end
    ClusterSizes = ClusterSizes(1:clusterid);
    
    %The # of clusters if the number of non-noise clusters plus 1 for the
    %noise cluster (which will always be included in the table, even if it
    %is empty!)
    nClust = clusterid + 1;

    %Fill in first column of table as cluster ID and second column as
    %cluster size:
    ClusterSizeArray = zeros(nClust, 3);
    ClusterSizeArray(1,2) = NoiseSize;
    ClusterSizeArray(2:nClust,2) = ClusterSizes;
    ClusterSizeArray(2:nClust,1) = (1:nClust-1);
       
    %Fill in third column of table as % of all points in cluster:
    for i = 1:nClust
         ClusterSizeArray(i, 3) = ClusterSizeArray(i, 2) / N;
    end

    ClusterSizeTable = array2table(ClusterSizeArray,'VariableNames',...
        {'Cluster_ID','Points_in_Cluster','Fraction_Points_in_Cluster'});


end