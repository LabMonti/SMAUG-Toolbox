function pass = checkCriteria_BestFitSlope(GCO, sequence, params)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: checks whether a given node-chain meets user-
    %specified criteria on the value of its best-fit slope or not. By
    %best-fit slope, I mean the slope of a linear regression line fit to
    %the node-chain. The slope can therefore be positive or negative. 
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
    %   "maxSlope", giving the minimum and maximum best-fit slope for the
    %   node-chain in grid units
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %pass: logical variable; whether or not the node-sequence meets the
    %   best-fit slope criteria
    
    
    %Calculate best-fit slope for nodes in sequence
    c = NathansCovariance(GCO.UniqueNodes(sequence,:));
    slopeFit = c(1,2)/c(1,1);
    
    %Extract minimum and maximum slope
    minSlope = params.minSlope;
    maxSlope = params.maxSlope;
    
    %Determine whether sequence meets criteria or not
    if slopeFit <= maxSlope && slopeFit >= minSlope
        pass = true;
    else
        pass = false;
    end

end