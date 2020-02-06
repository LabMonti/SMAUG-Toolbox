function traceID_lists = assign_traceIDs_to_components(Ntraces_components, ...
    traceIDs)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given a list of trace IDs and a list of numbers
    %of traces in each seciton, break up the IDs into the IDs belonging to
    %each section (and re-start the numbering for each section)
    %
    %~~~INPUTS~~~:
    %
    %Ntraces_components: a vector listing the number of traces in each
    %   component of a trace structure combo
    %
    %traceIDs: a list of trace ID #s
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %traceID_lists: a cell array containing a list of trace ID #s
    %   corresponding to each component of the combo, with the ID numbering
    %   scheme re-starting for each section
    

    NC = length(Ntraces_components);
    N = length(traceIDs);
    counts = zeros(NC,1);
    
    %Make a bunch of empty lists
    traceID_lists = cell(NC,1);
    for i = 1:NC
        traceID_lists{i} = zeros(N,1);
    end
    
    %Turn Ntraces_components into a cumulative count
    for i = 2:NC
        Ntraces_components(i) = Ntraces_components(i) + Ntraces_components(i-1);
    end

    for i = 1:N    
        found = false;
        j = 0;
        while ~found
            j = j + 1;
            if traceIDs(i) <= Ntraces_components(j)
                found = true;
                counts(j) = counts(j) + 1;
                traceID_lists{j}(counts(j)) = traceIDs(i);
            end
        end  
    end
    
    %Chop off unused portions, and shift down to start at 1 for each
    %section
    traceID_lists{1} = traceID_lists{1}(1:counts(1));
    for i = 2:NC
        traceID_lists{i} = traceID_lists{i}(1:counts(i)) - Ntraces_components(i-1);
    end

end