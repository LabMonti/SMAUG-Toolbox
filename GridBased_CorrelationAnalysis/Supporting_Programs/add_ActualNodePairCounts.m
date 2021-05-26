function add_ActualNodePairCounts(GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: fills in the node pair counts property for a
    %   GridCorrelationObject. This property contains, for each unique pair
    %   of ordered nodes, how many traces passing through the first node
    %   also pass through the second node (so, it's not symmetric). 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: a GridCorrelationObject that this function will update by
    %   filling in (or updating) the node pair counts property
    
    
    Ntraces = GridCorrObj.Ntraces;
    NUnique = GridCorrObj.NUnique;
    AllNodeIDs = GridCorrObj.AllNodeIDs;
    
    %The index NUninque+1 refers to the "Start" node; the index NUnique+2
    %refers to the "End" node;
    NodePairCounts = zeros(NUnique+2);
    
    for i = 1:Ntraces
        tr = GridCorrObj.CoarseTraces{i};
        n = size(tr,1);
        
        %Get node ID for each node in the trace
        all_IDs = zeros(n,1);
        for j=1:n
            all_IDs(j) = AllNodeIDs(tr(j,1),tr(j,2));
        end
        
        %Make a vector showing which nodes are in the trace (this allows us
        %to ignore duplicated nodes!)
        nodes_in_trace = false(n,1);
        nodes_in_trace(all_IDs) = true;
        
        %Add a count for the StartNode going to each other node, and for
        %each other node going to the EndNode
        NodePairCounts(NUnique+1,nodes_in_trace) = NodePairCounts(NUnique+1,nodes_in_trace) + 1;
        NodePairCounts(nodes_in_trace,NUnique+2) = NodePairCounts(nodes_in_trace,NUnique+2) + 1;
        
        %Loop through each node in the trace...
        for j = 1:n           
            %Make a vector showing which nodes occur in the trace AFTER the
            %given node (this allows us to ignore duplicated nodes!!!)
            nodes_after = false(n-j+1,1);
            nodes_after(all_IDs(j:n)) = true;
            
            %Add a count for this node going to each node after it in the
            %trace (including itself; diagonal elements will be the same as
            %node frequencies)
            NodePairCounts(all_IDs(j), nodes_after) = NodePairCounts(all_IDs(j), nodes_after) + 1;
        end
    end
    %Set diagonal elements for start and end nodes:
    NodePairCounts(NUnique+1,NUnique+1) = Ntraces;
    NodePairCounts(NUnique+2,NUnique+2) = Ntraces;
    
    %Save node pair counts as a property of the Coarse Grid object
    GridCorrObj.ActualNodePairCounts = NodePairCounts;
    GridCorrObj.TotalNodePairCount = sum(sum(NodePairCounts));

end