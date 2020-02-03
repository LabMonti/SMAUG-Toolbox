%22Feb2018 NDB: The purpose of this function is to extract a subsection of
%traces from a Trace Structure file and make a new trace structure for just
%that subsection
%21Jun2018 NDB: New version that is able to pull out multiple subsections
%16Aug2018 NDB: Updated to be cleaner and take advantage of new combo
%programs.  Can even take subsections of combos!
%05Oct2018 NDB: Load and unload structs to make sure all empty fields get
%filled with default values
function NewTraceStruct = GetTraceStructSubsections(TraceStruct, SectionsBounds)
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