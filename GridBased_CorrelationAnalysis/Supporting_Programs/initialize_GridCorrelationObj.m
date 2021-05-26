function initialize_GridCorrelationObj(GridCorrObj, TraceStruct, Xstep,...
    Ystep, multiple_sections)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given both a (new, empty) grid correlation
    %object as well as a TraceStruct containing breaking traces, this
    %function creates "coarse traces" from each original traces by forcing
    %them onto the same grid of nodes, then stores those coarse traces in
    %the grid correlation object. 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: an object of the GridCorrelationObject class, for storing
    %   coarse traces and information about their nodes
    %
    %TraceStruct: a trace structure containing a set of breaking traces and
    %   their associated information
    %
    %Xstep: the distance between grid nodes on the x-axis, in whatever
    %   units the TraceStruct uses (default is nm)
    %
    %Ystep: the distance between grid nodes on the y-axis, in whatever
    %   units the TraceStruct uses (default is log(G_0))
    %
    %multiple_sections: logical variable; if true (default), then a single
    %   breaking trace will be turned into multiple separate coarse traces
    %   if it dips below the noise floor but then comes back up.
    
    
    if nargin < 5
        multiple_sections = true;
    end
   
    %Load the trace structure and make sure it's in the default linear-x &
    %logarithmic-y space
    TSO = LoadTraceStruct(TraceStruct);
    TSO.convertTraces('Lin', 'Log');
    clear TraceStruct;

    %First go through and collect all trace data to calculate standard
    %deviations in distance and log(conductance)
    AllPoints = TSO.getAllData('both');

    %Make sure to grid so that the origin, (0,0), falls exactly on a
    %grid point. This makes our starting point non-arbitrary (or at
    %least non-random). 
    Xstart = floor(min(AllPoints(:,1))/Xstep)*Xstep - Xstep;
    Ystart = floor(min(AllPoints(:,2))/Ystep)*Ystep - Ystep;        
    GridCorrObj.Xstart = Xstart;
    GridCorrObj.Ystart = Ystart;
    
    %Get all coarse traces
    disp('Coarse gridding all traces...');
    Ntraces = TSO.Ntraces;
    NumTotalNodes = 0;
        
    %Hard-coded for now!
    minSectionLength = 2;

    CoarseTraces = cell(Ntraces*5,1);
    OG_traceIDs = zeros(Ntraces*5,1);
    counter = 0;
    for i = 1:Ntraces

        %Get coarse trace sections for trace
        trace = TSO.Traces{i};
        if multiple_sections
            [sections, n] = coarseGridSingleTrace_multiplesections(trace,...
                Xstart,Ystart,Xstep,Ystep,log10(TSO.NoiseFloor),...
                minSectionLength,false);
        else
            %In the case of NOT multiple sections, we will make the single
            %coarse trace "look" like a set of multiple sections so that
            %the rest of this function only needs one case
            coarse_tr = coarseGridSingleTrace(trace,Xstart,Ystart,Xstep,...
                Ystep,false);
            sections = cell(1);
            sections{1} = coarse_tr;
            n = 1;
        end

        %Save each section as a separate coarse trace
        CoarseTraces(counter+1:counter+n) = sections;

        %Save the original trace ID that each section comes from
        OG_traceIDs(counter+1:counter+n) = i;

        %Update number of coarse traces saved so far
        counter = counter + n;

        %Update number of total nodes from all sections
        for j = 1:n
            NumTotalNodes = NumTotalNodes + size(sections{j},1);
        end

        if mod(i, 1024) == 0
            disp([i Ntraces]);
        end            
    end
    CoarseTraces = CoarseTraces(1:counter);
    OG_traceIDs = OG_traceIDs(1:counter);
    GridCorrObj.Ntraces = counter;

    %Save new info to coarse trace object
    GridCorrObj.CoarseTraces = CoarseTraces;
    GridCorrObj.NumTotalNodes = NumTotalNodes;
    GridCorrObj.OriginalTraceIDs = OG_traceIDs;

end