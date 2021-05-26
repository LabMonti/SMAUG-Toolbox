function pass = checkCriteria_SteadySlope(GCO, sequence, params)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: checks whether a given node-sequence meets user-
    %specified criteria on whether the sequence closely-enough follows a
    %"steady" (i.e. linear) slope within a specified range. This is checked
    %by "unrotating" the node sequence using its best fit slope and the
    %closest allowable slope in the specified range. Then the maximum
    %y-range of the nodes are checked as a measure of how "steady" the
    %sequence matches the slope it was unrotated by. 
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
    %   case, the stucture array must contain three fields:
    %   "targetSlopeMax" and "targetSlopeMin" define the range of slopes
    %   (in grid units) that we can try to unrotate a sequence by;
    %   "maxRange" specificies the maximum y-range, in grid-units, of the
    %   sequence once it's been unrotated. 
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %pass: logical variable; whether or not the node-sequence meets the
    %   best-fit slope criteria
    
    
    %Extract parameters
    targetSlopeMax = params.targetSlopeMax;
    targetSlopeMin = params.targetSlopeMin;
    maxRange = params.maxRange;
    
    %Find average x- and y- of sequence
    nodes = GCO.UniqueNodes(sequence,:);
    avg = mean(nodes);
    
    %Find best-fit slope of data
    c = NathansCovariance(nodes);
    bestFitSlope = c(1,2)/c(1,1);
    
    %Determine the target slope in the range which is closest to the
    %best-fit slope of the data
    if bestFitSlope > targetSlopeMax
        targetSlope = targetSlopeMax;
    elseif bestFitSlope < targetSlopeMin
        targetSlope = targetSlopeMin;
    else
        targetSlope = bestFitSlope;
    end
    
    %"Unrotate" the nodes using the target slope
    shift = (nodes(:,1) - avg(1)) * targetSlope;
    newY = nodes(:,2) - shift;
    
    %Check if the range of unrotated nodes passes the criteria or not
    if range(newY) <= maxRange
        pass = true;
    else
        pass = false;
    end

end