function add_HorizontalNeighbors(GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Create a matrix that lists, for each node, the
    %IDs of the nodes immediately left and right (in that order) of the 
    %node. IMPORTANT: if no node exists immediately left or right of a 
    %node, list the node's own ID number in that slot. 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: the GridCorrelationObject that this function will fill in
    %   the horizontal neighbors property of
    
    
    NUnique = GridCorrObj.NUnique;
    UniqueNodes = GridCorrObj.UniqueNodes;
    AllNodeIDs = GridCorrObj.AllNodeIDs;
    maxIDs = size(AllNodeIDs);

    HorizontalNeighbors = zeros(NUnique,2);
    
    for i = 1:NUnique
        %Get coordinates for current node
        node_coords = UniqueNodes(i,:);
        
        %Check if node immediately left exists
        if node_coords(1)-1 > 0 && AllNodeIDs(node_coords(1)-1,...
                node_coords(2)) > 0
            HorizontalNeighbors(i,1) = AllNodeIDs(node_coords(1)-1,...
                node_coords(2));
        else
            %If not, just fill in the current node's ID as its lower
            %neighbor
            HorizontalNeighbors(i,1) = i;
        end
        
        %Now do the same thing for the right neighbor:
        if node_coords(1)+1 <= maxIDs(1) && AllNodeIDs(node_coords(1)+1,...
                node_coords(2)) > 0
            HorizontalNeighbors(i,2) = AllNodeIDs(node_coords(1)+1,...
                node_coords(2));
        else
            %If upper neighbor doesn't exist, fill in current node ID
            HorizontalNeighbors(i,2) = i;
        end              
    end

    %Add vertical neighbors to coarse grid structure
    GridCorrObj.HorizontalNeighbors = HorizontalNeighbors;

end