function index_nodes(GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: given a GridCorrelationObject with a set of
    %unique nodes in it, this function creates a matrix that can be used to
    %go from a node's coordinates to its ID# and saves this matrix as a
    %property of the object.
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: a GridCorrelationObject that this function will fill in
    %   the AllNodeIDs property of by indexing all the nodes
    
    
    CoarseTraces = GridCorrObj.CoarseTraces;
    NumTotalNodes = GridCorrObj.NumTotalNodes;
    Ntraces = GridCorrObj.Ntraces;

    %Collect all nodes:
    AllNodes = zeros(NumTotalNodes, 2);
    CoarseTraceLengths = zeros(Ntraces, 1);
    counter = 0;
    for i = 1:Ntraces
        trace = CoarseTraces{i};
        n = length(trace);
        CoarseTraceLengths(i) = n;
        AllNodes(counter+1:counter+n,:) = trace;
        counter = counter + n;
    end 
    GridCorrObj.CoarseTraceLengths = CoarseTraceLengths;
    
    %Find Unique Nodes
    UniqueNodes = unique(AllNodes,'rows');
    NUnique = length(UniqueNodes);
    GridCorrObj.UniqueNodes = UniqueNodes;
    GridCorrObj.NUnique = NUnique;
    
    %Make an array that uses each node as coordinates to specify the
    %position of that node in the list
    %%disp(min(UniqueNodes));
    AllNodeIDs = zeros(max(AllNodes(:,1)), max(AllNodes(:,2)));
    for i = 1:NUnique
        AllNodeIDs(UniqueNodes(i,1),UniqueNodes(i,2)) = i;
    end
    GridCorrObj.AllNodeIDs = AllNodeIDs;
    
    %Find the frequency with which each node was visited by traces;
    NodeFreqs = zeros(NUnique, 1);
    for i = 1:Ntraces
        trace = CoarseTraces{i};
        n = length(trace);
        for j = 1:n 
            node_ID = AllNodeIDs(trace(j,1),trace(j,2));
            NodeFreqs(node_ID) = NodeFreqs(node_ID) + 1;    
        end
    end
    
    %Save node frequencies
    GridCorrObj.NodeFreqs = NodeFreqs;

end