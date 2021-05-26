function strength = get_connection_strength(GridCorrObj, NID1, NID2)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: calculates the quantity we call "pair strength"
    %   between two nodes in a dataset. Pair strength is based on the
    %   natural log of the different p-values for the # of traces going
    %   from the first node to the second. Positive strengths imply 
    %   positively correlated nodes, negateive strengths imply negatively
    %   correlated nodes. 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: GridCorrelationObject containing coarse traces and node
    %   information for a given dataset
    %
    %NID1/NID2: the node ID# for the first/second node in the pair (yes,
    %   order matters)
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %strength: the pair strength value calculated for this ordered pair of
    %   nodes
    
    
    %We place a floor on p-values of 1/(# of nodes)^2 = 1/(# of node
    %pairs). Bascially, the rationale is that we can't distinguish
    %probabilities that are so small that we would expect to observe them
    %less than once in the entire dataset. 
    min_p = 1/GridCorrObj.NUnique^2;            
    strength = 0;   
    
    %In all of these cases, we do nothing if the p-value matrix holds a
    %non-finite value (i.e., NaN) because that indicates that no hypothesis
    %test was conducted for that pair of nodes due to no data existing
    %(e.g., impossible to travle from node A to B). 

    %P-value for more traces than expected going from node 1 to 2
    if isfinite(GridCorrObj.PValues_above(NID1,NID2))
        p = max(min_p, GridCorrObj.PValues_above(NID1,NID2));
        strength = strength - log(p);
    end
    %P-value for more traces than expected going from node 2 to 1
    if isfinite(GridCorrObj.PValues_above(NID2,NID1))
        p = max(min_p, GridCorrObj.PValues_above(NID2,NID1));
        strength = strength - log(p);
    end
    %P-value for fewer traces than expected going from node 1 to 2
    if isfinite(GridCorrObj.PValues_below(NID1,NID2))
        p = max(min_p, GridCorrObj.PValues_below(NID1,NID2));
        strength = strength + log(p);
    end
    %P-value for fewer traces than expected going from node 2 to 1
    if isfinite(GridCorrObj.PValues_below(NID2,NID1))
        p = max(min_p, GridCorrObj.PValues_below(NID2,NID1));
        strength = strength + log(p);
    end 

end