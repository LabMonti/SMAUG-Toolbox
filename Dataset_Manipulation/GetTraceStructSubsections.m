function NewTraceStruct = GetTraceStructSubsections(TraceStruct, SectionsBounds)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: extracts one or more sub-sections from a trace
    %structure, and creates a new trace structure in which those
    %sub-section(s) are concatenated into a single block.  All fields will
    %be set to their default values if unspecified.  
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: the input trace structure (which can be a combo or
    %   subsection structure already)
    %
    %SectionsBounds: a two-column array containing the starting and ending
    %   trace numbers specifying each requested subsection
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %NewTraceStruct: a (possibly combination) TraceStruct containing all
    %   the subsection(s) specified by the user, merged together if more
    %   than one
    
    
    %Load in trace structure:
    TraceStruct = LoadTraceStruct(TraceStruct);
    
    %Get subsections:
    NewTraceStruct = TraceStruct.get_subsections(SectionsBounds);
    
    %Unload trace structure:
    NewTraceStruct = UnLoadTraceStruct(NewTraceStruct);

end