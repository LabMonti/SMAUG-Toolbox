%05Oct18 NDB: Chop each trace the FIRST time it passes below the noise
%floor
function chop_TSO_first_cross(TSO)

    if strcmp(TSO.ChopMethod, 'ChopFirstCross')
        disp('Chop Method is already "ChopFirstCross", no need to alter it');
    elseif strcmp(TSO.ChopMethod, 'FloorBelowNoiseFloor') || strcmp(TSO.ChopMethod, 'ExcludeTrailingNoise')

        if TSO.y_Log
            nf = log10(TSO.NoiseFloor);
        else
            nf = TSO.NoiseFloor;
        end

        NPoints = 0;
        for i = 1:TSO.Ntraces

            tr = TSO.Traces{i};
            n = size(tr,1);
            
            %Find last point before trace breaks off, since we only want to
            %chop AFTER there (if it dips below the noise floor before
            %fully breaking, ignore it)
            start_index = find(tr(:,2) > 0, 1, 'last');

            %Find first point below noise (as long as it is after the 1G0
            %break-off)
            end_index = find(tr(start_index:n,2) < nf, 1, 'first') + start_index - 1;

            %Set end to point just before that, i.e. last point
            %before first noise cross.  If there WAS no point below the
            %noise, keep the whole trace by doing nothing!
            if ~isempty(end_index)
                tr = tr(1:end_index - 1, :);
            end

            TSO.Traces{i} = tr;
            NPoints = NPoints + size(tr,1);

        end
        TSO.NumTotalPoints = NPoints;

        %Update chop method
        TSO.ChopMethod = 'ChopFirstCross';
    else
        warning('Unrecognized current ChopMethod, doing nothing');
    end


end