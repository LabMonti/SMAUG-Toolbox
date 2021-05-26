function add_MissingNeighbors(GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: for each node, this function determines whether
    %any of its immediate neighbors in all four directions "do not exist",
    %meaning that the node that WOULD be in that location has no traces
    %through it and so is not included in the list of possible nodes.
    %Produces a logical array with four columns for each node, indicating
    %whether each node is missing (true) or not (false). The ordering of
    %the neighbors is: south, north, west, east.
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: GridCorrelationObject that this function will fill in the
    %   MissingNeighbors property of. 
    
    
    NUnique = GridCorrObj.NUnique;
    UniqueNodes = GridCorrObj.UniqueNodes;
    AllNodeIDs = GridCorrObj.AllNodeIDs;
    maxIDs = size(AllNodeIDs);

    MissingNeighbors = true(NUnique,4);
    
    for i = 1:NUnique
        %Get coordinates for current node
        node_coords = UniqueNodes(i,:);
       
        %Check if node immediately below exists
        if node_coords(2)-1 > 0 && AllNodeIDs(node_coords(1),...
                node_coords(2)-1) > 0
            MissingNeighbors(i,1) = false;
        end          
        
        %Check if node immediately above exists
        if node_coords(2)+1 <= maxIDs(2) && AllNodeIDs(node_coords(1),...
                node_coords(2)+1) > 0
            MissingNeighbors(i,2) = false;
        end                 
        
        %Check if node immediately left exists
        if node_coords(1)-1 > 0 && AllNodeIDs(node_coords(1)-1,...
                node_coords(2)) > 0
            MissingNeighbors(i,3) = false;
        end

        %Check if node immediately right exists
        if node_coords(1)+1 <= maxIDs(1) && AllNodeIDs(node_coords(1)+1,...
                node_coords(2)) > 0
            MissingNeighbors(i,4) = false;
        end
    end

    %Add vertical neighbors to coarse grid structure
    GridCorrObj.MissingNeighbors = MissingNeighbors;

end