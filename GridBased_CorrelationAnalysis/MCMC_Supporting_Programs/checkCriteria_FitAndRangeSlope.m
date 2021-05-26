function pass = checkCriteria_FitAndRangeSlope(GCO, sequence, params)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: checks whether a given node-sequence meets user-
    %specified criteria on the value of BOTH its "best-fit slope" (the
    %slope of a linear regression line fit to the node-chain) AND its
    %"range slope" (the node-chain's range in y divided by its range in x).
    %The sign (positive or negative) from the best-fit slope will also be
    %applied to the range slope, so both slopes can be either positive or
    %negative.
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
    %   "maxSlope", giving the minimum and maximum for both the best-fit
    %   and range slopes, in grid units.
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

    %Calculate the "range slope" of the sequence
    n = length(sequence);
    slopeRange = range(GCO.UniqueNodes(sequence,2))/n;
    
    %Apply sign from fit slope to range slope
    if slopeFit ~= 0
        slopeRange = slopeRange * sign(slopeFit);
    end
    
    %Determine which slope is relevant for each bound
    slopeLow = min([slopeRange slopeFit]);
    slopeHigh = max([slopeRange slopeFit]);
    
    %Extract minimum and maximum slope
    minSlope = params.minSlope;
    maxSlope = params.maxSlope;
    
    %Determine whether sequence meets criteria or not
    if slopeHigh <= maxSlope && slopeLow >= minSlope
        pass = true;
    else
        pass = false;
    end

end