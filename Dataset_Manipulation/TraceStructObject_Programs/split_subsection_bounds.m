%18Aug2018 NDB: When you want to take subsections from a combination
%structure, this function splits the subsection bounds whenever they
%overlap a merge-bound from the combo so that each final subsection does
%not span more than one section from the combo. Not intended for direct
%call by user.  
function [ComponentBounds,NTotSubSections] = split_subsection_bounds(SectionsBounds, ...
    Ntraces_components)
    %~~~INPUTS~~~:
    %
    %SectionsBounds: a two-column array in which each row contains the
    %   trace #s of the first and last trace for a requested subsection
    %
    %Ntraces_components: a vector with the number of traces in each
    %   component of the combination structure in each element
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %ComponentBounds: a two-column array listing the starting and ending
    %   trace #s for each subsection, with the subsections split up so that
    %   they don't overlap multiple components of the original combo, AND
    %   re-indexed relative to the component they live in
    
    
    Ncombo = length(Ntraces_components);
    Nsubsections = size(SectionsBounds,1);

    %Find the first trace in each component of the combo
    break_points = zeros(Ncombo - 1, 1);
    counter = 0;
    for i = 1:Ncombo - 1
        counter = counter + Ntraces_components(i);
        break_points(i) = counter + 1;
    end

    %Make new array of subsection bounds, fill in with the original bounds
    NewBounds = zeros(Ncombo*Nsubsections, 2);
    NewBounds(1:Nsubsections,:) = SectionsBounds;
    NTotSubSections = Nsubsections;

    %Any time a break point falls within a subsection, break that
    %subsection into two new subsections that don't span the break point
    for i = 1:Ncombo - 1
        for j = 1:Ncombo*Nsubsections

            if NewBounds(j,1) < break_points(i) && NewBounds(j,2) >= break_points(i)
                [b1, b2] = split_bounds(NewBounds(j,:),break_points(i));
                NewBounds(j,:) = b1;
                NTotSubSections = NTotSubSections + 1;
                NewBounds(NTotSubSections,:) = b2;
            end

        end
    end
    NewBounds = NewBounds(1:NTotSubSections,:);
    NewBounds = sortrows(NewBounds);
    
    %Make cell array to hold the bounds which belong to each component of
    %the combo
    ComponentBounds = cell(Ncombo,1);
    for i = 1:Ncombo
        ComponentBounds{i} = zeros(NTotSubSections,2);
    end
    component_counts = zeros(Ncombo,1);
    
    %Add "break points" for the first trace number in the first component
    %and the first trace after the last component (which would be the first
    %trace of a non-existent next component)
    break_points = [1; break_points; sum(Ntraces_components + 1)];
    for i = 1:NTotSubSections
        for j = 1:Ncombo
            
            %If the subsection falls between the appropriate break points,
            %apportion it to the correct component of the combo
            if NewBounds(i,1) >= break_points(j) && NewBounds(i,2) < break_points(j+1)
                component_counts(j) = component_counts(j) + 1;
                ComponentBounds{j}(component_counts(j),:) = NewBounds(i,:);
            end
        end
    end
    
    %Remove unused portions of arrays
    for i = 1:Ncombo
        ComponentBounds{i} = ComponentBounds{i}(1:component_counts(i),:);
    end
    
    %Re-index bounds for each component so that they match that component
    %starting at trace #1
    for i = 1:Ncombo - 1
        for j = i+1:Ncombo
            ComponentBounds{j} = ComponentBounds{j} - Ntraces_components(i);
        end
    end

end



function [NewBound1, NewBound2] = split_bounds(Bounds, break_point)

    NewBound1 = [Bounds(1), break_point - 1];
    NewBound2 = [break_point, Bounds(2)];

end
