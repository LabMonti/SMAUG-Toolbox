function score = score_trace_vs_SpecificNodeDistribution(GCO,Node,TraceID)  
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: For the connection strength distribution through
    %a given node, and given a specific trace, give the trace a "score"
    %indicating how much it contributes to or detracts from that particular
    %distribution. The way we calculate this score: just average together
    %the connection strengths of each node the trace passes through vs. the
    %selected node.
    %
    %~~~INPUTS~~~:
    %
    %GCO: GridCorrelationObject containing the coarse traces and node
    %   information for a given dataset
    %
    %Node: the node whose pair strength distribution we will score against.
    %   Can be specified either as a single node ID number, or as a 2x1
    %   vector of node coordinates. 
    %
    %TraceID: the ID# of the coarse trace that will be scored
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %score: the average connection strength of all nodes in the trace vs.
    %   "Node"
    
    
    %Make sure Node is in the form of the node's ID#, rather than the node
    %coordinates
    Node = GCO.getNodeID(Node);
    
    %Add up connection strengths of each node in the trace vs. the selected
    %node
    score = 0;
    n = GCO.CoarseTraceLengths(TraceID);
    for i = 1:n
        id = GCO.AllNodeIDs(GCO.CoarseTraces{TraceID}(i,1),GCO.CoarseTraces{TraceID}(i,2));
        score = score + GCO.ConnectionStrengths(Node,id);
    end
    
    %Divide by the number of nodes in the trace
    score = score/n;
    
end