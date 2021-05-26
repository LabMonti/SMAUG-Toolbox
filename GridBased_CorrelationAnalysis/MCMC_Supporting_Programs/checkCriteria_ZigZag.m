function pass = checkCriteria_ZigZag(GCO, sequence, params)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: checks whether a given node-sequence meets user-
    %specified criteria on whether the sequence has two relatively flat
    %sections with a "jump" in between (to form a zig-zag shape). 
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
    %   case, the stucture array must contain three fields: "minSlope" and
    %   "maxSlope" define the range of acceptable slopes, in grid units,
    %   for the two different parts of the sequence; "minJump" defines the
    %   minimum y-jump that must occur between these two sections. The jump
    %   can occur at any point along the sequence. 
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %pass: logical variable; whether or not the node-sequence meets the
    %   best-fit slope criteria
    
    
    pass = false;

    %Extract parameters
    minJump = params.minJump;
    minSlope = params.minSlope;
    maxSlope = params.maxSlope;
    n = length(sequence);
    
    %Look for largest jump in sequence
    jumps = GCO.UniqueNodes(sequence(2:n),2) - GCO.UniqueNodes(sequence(1:n-1),2);
    [maxJump, maxIndex] = max(jumps);
    
    %Can only pass criteria if max jump is large enough
    if maxJump >= minJump
        
        %Find range slopes of first and second sections
        slope1 = range(GCO.UniqueNodes(sequence(1:maxIndex),2))/maxIndex;
        if slope1 >= minSlope && slope1 <= maxSlope
            
            slope2 = range(GCO.UniqueNodes(sequence(maxIndex+1:n),2))/(n-maxIndex);
            if slope2 >= minSlope && slope2 <= maxSlope
                pass = true;
            end
            
        end        
    end

end