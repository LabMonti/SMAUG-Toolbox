function add_NodeOccupancies(GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: fills in the "NodeOCcupancies" property of a
    %GridCorrelationObject. This property will contain an nNodesxnTraces
    %logical array, with each element true iff that trace passes through
    %that node
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: the GridCorrelationObject that this function will fill in
    %   the NodeOccupancies property of
    
    
    NUnique = GridCorrObj.NUnique;
    Ntraces = GridCorrObj.Ntraces;

    %Make arrays showing for each trace which nodes it
    %goes through
    %NUnique+1 means the "StartTrace" node, NUnique+2 means the "EndTrace"
    %node
    NodeOccupancy = false(NUnique+2, Ntraces);
    
    %All traces pass through the startTrace and endTrace nodes
    NodeOccupancy(NUnique+1:NUnique+2,:) = true;
    
    CoarseTraces = GridCorrObj.CoarseTraces;
    AllNodeIDs = GridCorrObj.AllNodeIDs;
    
    %Fill up those arrays by going through every trace and every node
    for i = 1:Ntraces
        trace = CoarseTraces{i};
        n = length(trace);

        %Go through each node in trace:
        for j = 1:n
            
            node_ID = AllNodeIDs(trace(j,1),trace(j,2));
            NodeOccupancy(node_ID, i) = true;
      
        end
    end
    GridCorrObj.NodeOccupancy = NodeOccupancy;

end