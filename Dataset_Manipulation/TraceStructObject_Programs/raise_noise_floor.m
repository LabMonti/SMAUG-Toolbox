%NDB 09Aug19: A program to INCREASE the noise floor of a trace struct
%object, consistent with whatever chop method is currently in use
function raise_noise_floor(TSO, new_floor)

    old_floor = TSO.NoiseFloor;
    if new_floor < old_floor
        error('Cannot decrease noise floor after initial processing');
    end
    
    %Store new noise floor
    TSO.NoiseFloor = new_floor;
    if strcmp(TSO.combo,'yes')
        for i = 1:TSO.Ncombo
            TSO.ComponentProperties.NoiseFloors{i} = new_floor;
        end
    end
    
    below_floor= new_floor/10;

    %Change noise floors into log space if traces are in log space
    if TSO.y_Log
        below_floor = log10(below_floor);
        new_floor = log10(new_floor);
    end
    
    NPoints = 0;
    if strcmp(TSO.ChopMethod,'ChopFirstCross')
        
        %Re-chop each trace the first time it passes below the NEW noise
        %floor
        for i = 1:TSO.Ntraces
            tr = TSO.Traces{i};
            n = size(tr,1);
            
            %Find last point before trace breaks off, since we only want to
            %chop AFTER there (if it dips below the noise floor before
            %fully breaking, ignore it)
            start_index = find(tr(:,2) > 0, 1, 'last');

            %Find first point below noise (as long as it is after the 1G0
            %break-off)
            end_index = find(tr(start_index:n,2) < new_floor, 1, 'first') + start_index - 1;

            %Set end to point just before that, i.e. last point
            %before first noise cross.  If there WAS no point below the
            %noise, keep the whole trace by doing nothing!
            if ~isempty(end_index)
                tr = tr(1:end_index - 1, :);
            end

            TSO.Traces{i} = tr;
            NPoints = NPoints + size(tr,1);
        end        
        
    elseif strcmp(TSO.ChopMethod,'ExcludeTrailingNoise') || ...
            strcmp(TSO.ChopMethod,'FloorBelowNoiseFloor')
        
        %Re-chop each trace the LAST time it passes below the new noise
        %floor
        for i = 1:TSO.Ntraces
            tr = TSO.Traces{i};
            
            %Find the LAST point ABOVE the noise floor
            end_index = find(tr(:,2) >= new_floor, 1, 'last');
            tr = tr(1:end_index, :);
            
            %Replace values below floor if that method is being used
            if strcmp(TSO.ChopMethod,'FloorBelowNoiseFloor')
                tr(tr(:,2) < new_floor, :) = below_floor;
            end
            
            TSO.Traces{i} = tr;
            NPoints = NPoints + size(tr,1);
            
        end
        
    end
    
    %Update total number of data points
    TSO.NumTotalPoints = NPoints;

end