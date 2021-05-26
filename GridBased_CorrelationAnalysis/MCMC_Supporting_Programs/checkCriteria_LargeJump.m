function pass = checkCriteria_LargeJump(GCO, sequence, params)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: checks whether a given node-sequence meets user-
    %specified criteria of having a large-enough jump either up or down
    %associated with a single step to the right.
    %
    %~~~INPUTS~~~:
    %
    %GCO: the GridCorrelationObject containing information on the nodes in
    %   the dataset that an MCMC simulation is being run on
    %
    %sequence: vector listing the node ID #s for the nodes in the
    %   node-sequence for the current step in the MCMC simulation
    %
    %params: structure array containing the criteria parameters. In this
    %   case, the stucture array must contain two fields: "JumpUp" is a
    %   logical variable that is true if the jump need to go up, and false
    %   if it needs to go down; and "minJumpMag" is the minimum size of the
    %   required jump, in grid units.
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %pass: logical variable; whether or not the node-sequence meets the
    %   best-fit slope criteria
    
    
    pass = false;

    %Extract parameters
    minJumpMag = params.minJumpMag;
    JumpUp = params.JumpUp;
    n = length(sequence);
    
    if ~JumpUp
        sign_flip = -1;
    else
        sign_flip = 1;
    end
    
    %Look for most positive or negative jump in sequence
    jumps = sign_flip*GCO.UniqueNodes(sequence(2:n),2) - GCO.UniqueNodes(sequence(1:n-1),2);
    maxJump = max(jumps);
    
    %Can only pass criteria if max jump is large enough
    if maxJump >= minJumpMag        
        pass = true;
    end

end