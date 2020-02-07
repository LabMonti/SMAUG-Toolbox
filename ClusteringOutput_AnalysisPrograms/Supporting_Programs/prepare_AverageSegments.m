function [ActiveBounds, MedianSegments, PercentileRegions] = ...
    prepare_AverageSegments(AlignedSegments, ActiveRegions, nClust, ...
    CentralPercents, cluster_indices)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: 
    %
    %~~~INPUTS~~~:
    %
    %
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    
    
    nPercentiles = length(CentralPercents);
    nSegs = length(cluster_indices);
    nXvals = size(AlignedSegments,2);
    
    %Find # of segments at each xDist for each cluster:
    SegmentCounts = zeros(nXvals, nClust);

    %The ActivityMatrix says which segments exist at which x-values in
    %which clusters
    ActivityMatrix = false(nSegs, nXvals, nClust);
    AverageRegions = zeros(nClust, 2, nPercentiles);
    AverageRegions(:,1,1) = Inf;
    AverageRegions(:,2,1) = -Inf;
    
    %Find sum of conductance and # of conductance points in each cluster at
    %each x-distance.  Also get maximum extent of conductance points for
    %each cluster
    for i = 1:nSegs
        ActivityMatrix(i,ActiveRegions(i,1):ActiveRegions(i,2),cluster_indices(i)) = true;
        
        SegmentCounts(ActiveRegions(i,1):ActiveRegions(i,2),cluster_indices(i)) = ...
            SegmentCounts(ActiveRegions(i,1):ActiveRegions(i,2),cluster_indices(i)) + 1;
        
        for j = ActiveRegions(i,1):ActiveRegions(i,2)

            %Get maximum extent of all active regions in the same cluster
            if ActiveRegions(i,1) < AverageRegions(cluster_indices(i),1,1)
                AverageRegions(cluster_indices(i),1,1) = ActiveRegions(i,1);
            end
            if ActiveRegions(i,2) > AverageRegions(cluster_indices(i),2,1)
                AverageRegions(cluster_indices(i),2,1) = ActiveRegions(i,2);
            end

        end
    end
    
    %Make an array to hold the median segment for each region, and an array
    %to hold the percentile bounds for the different regions
    MedianSegments = Inf(nXvals, nClust);
    PercentileRegions = Inf(nXvals, nClust, nPercentiles, 2);
    
    %The index bounds for each percentile region plus the median, for each
    %cluster
    ActiveBounds = zeros(nPercentiles + 1, nClust, 2);
    
    %Calculate median segment in each cluster at each x-value
    for j = 1:nClust  
        first_flag = true;
        last_flag = false;
        
        for i = 1:nXvals         
            if SegmentCounts(i,j) > 1
                %Get the conductances at the ith x-value for all segments
                %in the jth cluster, and take their median
                MedianSegments(i,j) = median(...
                    AlignedSegments(ActivityMatrix(:,i,j), i));
                
                %The first x-value for which we calculated a median
                if first_flag
                    ActiveBounds(1,j,1) = i;
                    first_flag = false;
                    last_flag = true;
                end
            else
                %The last x-value for which we calculated a median
                if last_flag
                    ActiveBounds(1,j,2) = i - 1;
                    last_flag = false;
                end
            end
        end
    end
    
    %Calculate bounds of central region for each percentile
    for k = 1:nPercentiles
        minNumPts = 100/(100 - CentralPercents(k)) * 4;

        low_prctile = (100 - CentralPercents(k))/2;
        high_prctile = 100 - low_prctile;        
        for j = 1:nClust
            first_flag = true;
            last_flag = false;
            
            for i = 1:nXvals
            
                
                if SegmentCounts(i,j) >= minNumPts
                    
                    data = AlignedSegments(ActivityMatrix(:,i,j), i);
                    
                    %Get lower bound:
                    PercentileRegions(i,j,k,1) = prctile(data,low_prctile);
                    
                    %Get upper bound:
                    PercentileRegions(i,j,k,2) = prctile(data,high_prctile);
                    
                    %The first x-value for which we calculated this region
                    if first_flag
                        ActiveBounds(k+1,j,1) = i;
                        first_flag = false;
                        last_flag = true;
                    end
                    
                else
                    %The last x-value for which we calculated a median
                    if last_flag
                        ActiveBounds(k+1,j,2) = i - 1;
                        last_flag = false;
                    end                    
                end
                
            end              
        end
    end        

end