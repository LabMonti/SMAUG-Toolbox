function [ThroughFreqs, NThrough] = getFreqs_ThroughNode(GridCorrObj, StartNode)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: For a given node in a dataset, this function
    %finds both the number of times every other node in the dataset was
    %visited by traces passing through the given node, as well as the
    %number of such traces passing through the given node
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: grid correlation object containing coarsened traces and
    %   node information for a given dataset
    %
    %StartNode: the node ID# for the chosen node
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %   
    %ThroughFreqs: a vector with length equal to the total # of nodes in
    %   the dataset, listing for each such node the # of times it was
    %   visited by traces that also pass through StartNode
    %
    %NThrough: the # of traces passing through StartNode
    
    
    NUnique = GridCorrObj.NUnique;
    AllNodeIDs = GridCorrObj.AllNodeIDs;
    
    [TracesThroughNode, NThrough] = getTraces_ThroughNode(GridCorrObj, StartNode);

    %Get the node frequencies for the subset of traces passing through
    %the specified node
    ThroughFreqs = get_node_counts_for_CoarseTraces(TracesThroughNode, NUnique,AllNodeIDs);

end