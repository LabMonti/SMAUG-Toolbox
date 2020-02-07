function [SizeArray, SizeTable] = GetPopulationTables(Y)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Create a table showing how many points are
    %assigned to each cluster for a given cluster solution
    %
    %~~~INPUTS~~~:
    %
    %Y: column vector containing the cluster ID# that each
    %   point is assigned to, in order of the cluster order. Cluster # 0
    %   always refers to the noise cluster, all other clusters have
    %   sequential positive integers as their ID#s
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %ClusterSizeArray: an array containing ClusterIDs in the first column,
    %   total # of point assigned to each cluster in the 2nd column, and
    %   fraction of all points assigned to each cluster in the 3rd column
    %
    %ClusterSizeTable: same as ClusterSizeTable but in table form with
    %   column labels    
    
    
    clustID = unique(Y);
    %If there are no noise points, still add an extra row to the size
    %tables for the noise cluster
    if clustID(1) > 0
        nClust = length(clustID) + 1;
    else
        nClust = length(clustID);
    end
    
    SizeArray = zeros(nClust, 3);
    SizeArray(2:nClust,1) = (1:nClust-1);
    
    %Get # of points in each cluster
    N = length(Y);
    for i = 1:N
        SizeArray(Y(i) + 1, 2) = SizeArray(Y(i) + 1, 2) + 1;
    end
    
    %Get population of each cluster as fraction of total points
    TotPoints = sum(SizeArray(:,2));
    for i = 1:nClust
        SizeArray(i,3) = SizeArray(i,2) / TotPoints;
    end
    
   SizeTable = array2table(SizeArray,'VariableNames',...
       {'Cluster_ID','Points_in_Cluster','Fraction_Points_in_Cluster'});


end