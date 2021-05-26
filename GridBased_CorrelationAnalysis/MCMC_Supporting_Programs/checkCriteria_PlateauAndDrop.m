function pass = checkCriteria_PlateauAndDrop(GCO, sequence, params)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: checks whether a given node-sequence meets user-
    %specified criteria of having a flat plateua-like section followed by a
    %sharp, mostly linear drop.
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
    %   case, the stucture array must contain three fields: "plateuaLength"
    %   gives the length, in nodes, of the first section of the node-chain,
    %   which will be required to be plateau-like; "maxRange" gives the
    %   maximum y-range, in grid units, that this plateau-like section can
    %   have to be considered plateau-like, which will ALSO be used as the
    %   maximum y-range that the drop section can deviate from linearity
    %   by; and "maxDropSlope" gives the maximum slope that will be used to
    %   try to unrotate the drop section. 
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %pass: logical variable; whether or not the node-sequence meets the
    %   best-fit slope criteria
    
    
    %Extract parameters
    maxRange = params.maxRange;
    plateauLength = params.plateauLength;
    maxDropSlope = params.maxDropSlope;
    n = length(sequence);
    
    %First check that the first part of the sequence is flat enough
    pass = (range(GCO.UniqueNodes(sequence(1:plateauLength),2)) <= maxRange);
    
    %Now we need to also check that the second part of the sequence is steep
    %enough
    if pass
        nodes = GCO.UniqueNodes(sequence(plateauLength:n),:);
        c = NathansCovariance(nodes);
        DropSlope = c(1,2)/c(1,1);
        
        %Find target slope to un-rotate by
        if DropSlope < maxDropSlope
            TargetSlope = DropSlope;
        else
            TargetSlope = maxDropSlope;
        end
        
        %"Unrotate" the nodes using the target slope
        avg = mean(nodes);
        shift = (nodes(:,1) - avg(1)) * TargetSlope;
        newY = nodes(:,2) - shift;
        
        pass = (range(newY) <= maxRange);
    end

end