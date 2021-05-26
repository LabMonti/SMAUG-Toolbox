function GCO = Create_StandardGCO(TraceStruct, grids_perX, grids_perY)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Starting from the Trace Structure for a dataset,
    %creates a GridCorrelationObject in the "standard" way, which involves
    %chopping at -0.05 nm and removing dangling nodes, then filling in the
    %connecion strength values and everything needed to calculate them. 
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: the trace structure for a given dataset of breaking
    %   traces
    %
    %grids_perX: number of grid units per nm of inter-electrode distance to
    %   be used during coarse-gridding; default is 25
    %
    %grids_perY: number of grid units per decade of log(G/G0) to be used
    %   during coarse-gridding; default is 10
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %GCO: grid correlation object containing the coarse traces for the
    %   input dataset and information about the nodes
    
    
    %Default inputs
    if nargin < 2
        grids_perX = 25;
    end
    if nargin < 3
        grids_perY = 10;
    end

    %Trim off most of the pre-rupture part of the trace
    TraceStruct = LoadTraceStruct(TraceStruct);
    TraceStruct.apply_LeftChop(-0.05);
    
    %Perform coarse gridding
    GCO = GridCorrelationObject(TraceStruct,grids_perX,grids_perY,true);
    
    %Removing "dangling" nodes
    GCO.remove_dangling_nodes();

    %Calculate all connection strengths (and thus all things needed in
    %order to calculate those, such as transfer probabilities)
    GCO.calculate_ConnectionStrengths;

end