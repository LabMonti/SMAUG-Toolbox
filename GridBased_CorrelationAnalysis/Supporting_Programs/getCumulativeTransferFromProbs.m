function CumulativeTransferFROMProbs = getCumulativeTransferFromProbs(...
    GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Get's cumulative probabilities for each node for
    %directly transferring from one of its neighboring nodes to the right,
    %based on the calculated exit probabilities. Used to randomly generate
    %traces or trace sections according to the null distribution. 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: grid correlation object containing the coarse traces and
    %   node information for the given dataset
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %CumulativeTransferFROMProbs: nNodes x nNodes square matrix where the
    %   (i,j)th element minus the (i-1,j)th element gives the probability
    %   that a trace at node ID#j.
    
    
    %Get probabilities of having transferred from each node to every other
    %node
    TransferFROMProbs = get_TransferFROMProbs(GridCorrObj);
    
    nNodes = size(TransferFROMProbs,1);
    
    %Now find the CUMULATIVE probabilities by adding cumulativily down a
    %column:
    CumulativeTransferFROMProbs = zeros(nNodes);
    for i = 1:nNodes
        CumulativeTransferFROMProbs(1,i) = TransferFROMProbs(1,i);
        for j = 2:nNodes
            CumulativeTransferFROMProbs(j,i) = CumulativeTransferFROMProbs(j-1,i) + ...
                TransferFROMProbs(j,i);
        end
    end 
    
end