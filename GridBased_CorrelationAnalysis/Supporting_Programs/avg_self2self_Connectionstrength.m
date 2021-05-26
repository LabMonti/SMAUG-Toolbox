function strength = avg_self2self_Connectionstrength(nodes, n, GCO)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: calculates the self-to-self average pair
    %   strength for a sequence of nodes. That is, averages together the
    %   pair strengths for all possible pairwise combinations of nodes from
    %   the given list of nodes.
    %
    %~~~INPUTS~~~:
    %
    %nodes: a vector containing a list of node ID #s
    %
    %n: the number of nodes in the sequence
    %
    %GCO: the GridCorrelationObject for the dataset that the nodes belong
    %   to
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %strength: the averaged self-to-self pair strength for the sequence of
    %   nodes
    
    
    %Now we have to calculate the average pair strength between all
    %nodes in the sequence. 
    strength = 0;
    counter = max([n*(n-1)/2, 1]);
    for j = 1:n
        for k = j+1:n
            strength = strength + GCO.ConnectionStrengths(nodes(j),nodes(k));
        end
    end
    strength = strength/counter;

end