function NewTSO = get_TSO_subsections(TSO, SectionsBounds)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Pulls one or more subsections from a trace 
    %struct object (TSO), and returns a TSO of the combination of those
    %subsections.  Original TSO can be any type of combo! Not intended for
    %direct call by user.  
    %
    %~~~INPUTS~~~:
    %
    %TSO: the input trace structure object (which can be a combo or
    %   subsection structure already)
    %
    %SectionsBounds: a two-column array containing the starting and ending
    %   trace numbers specifying each requested subsection
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %NewTSO: a (possibly combination) TSO containing all the subsection(s) 
    %   specified by the user, merged together if more  than one
    
    
    Ntraces = TSO.Ntraces;
    
    %# of different subsections to extract
    Nsubsections = size(SectionsBounds,1);
    
    %Allow user to input "max" for the end of a section bound
    if strcmp(SectionsBounds(Nsubsections, 2), 'max')
        SectionsBounds(Nsubsections, 2) = Ntraces;
    end
    
    %Make sure subsections do not overlap!
    for i = 2:Nsubsections
        if SectionsBounds(i,1) <= SectionsBounds(i-1,2)
            error('Requested subsections overlap!!!');
        end
    end
    
    %Make sure the requested first trace and last trace of each subsection
    %make sense!
    for i = 1:Nsubsections
        if SectionsBounds(i,2) > Ntraces || SectionsBounds(i,2) <= SectionsBounds(i,1) || SectionsBounds(i,1) < 1
            error('Requested first and last trace are impossible');
        end
        if SectionsBounds(i,2) == Ntraces && SectionsBounds(i,1) == 1
            error('Dude, why are you using this program if its not going to do anything???');
        end
    end
    
    
    %If the TSO is not a combo, set up variables to represent a combo of 1
    if strcmp(TSO.combo,'yes')
        Ncombo = TSO.Ncombo;
        NT_comp = TSO.Ntraces_components;
    elseif strcmp(TSO.combo,'no')
        Ncombo = 1;
        NT_comp = [TSO.Ntraces];
    else
        error('Unrecognized combo type');
    end

    %Update section bounds so that they don't span combo components.
    %ComponentSectBounds will now be a cell array of bounds for each
    %component, indexed relative to that component alone (also works if TSO
    %is not a combo!)
    [ComponentSectBounds, Nsubsections] = split_subsection_bounds(...
        SectionsBounds, NT_comp);    
    
    %Make list for all subsections
    SectionList = cell(Nsubsections,1);
    counter = 0;

    %Break combo structure into its components
    Components = TSO.get_combo_components();

    %Loop over each component of the combo, pulling the relavent
    %subsections from that component and adding them to the subsections
    %list
    for i = 1:Ncombo

        SectBounds = ComponentSectBounds{i};
        for j = 1:size(SectBounds,1)

            counter = counter + 1;
            SectionList{counter} = Components{i}.get_simple_subsection(...
                SectBounds(j,1),SectBounds(j,2));

        end 
    end

    %Now take advantage of the combination program that already exists
    %to stitch those subsections together (will work even if SectionList
    %only has one component)
    NewTSO = combine_TSOs(SectionList,strcat(TSO.name,'_subsections'));     
    
    %Update date made and file made by
    NewTSO.date_made = date();
    NewTSO.file_made_by = mfilename();

end