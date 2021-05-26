function pass = checkCriteria_RangeSlope(GCO, sequence, params)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: checks whether a given node-sequence meets user-
    %specified criteria on the value of its "range slope" or not. By
    %range slope, I mean the grid-range of the node-chain in y divided by
    %its grid-range in x. The range slope is thus always a positive number.
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
    %   case, the stucture array must contain two fields: "minSlope" and
    %   "maxSlope", giving the minimum and maximum range slope for the
    %   node-chain in grid units
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %pass: logical variable; whether or not the node-sequence meets the
    %   best-fit slope criteria
    
    
    %Calculate the "range slope" of the seqeunce
    n = length(sequence);
    slopeRange = range(GCO.UniqueNodes(sequence,2))/n;
    
    %Extract minimum and maximum slope
    minSlope = params.minSlope;
    maxSlope = params.maxSlope;
    
    %Determine whether sequence meets criteria or not
    if slopeRange <= maxSlope && slopeRange >= minSlope
        pass = true;
    else
        pass = false;
    end

end