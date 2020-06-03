function displayTraces(TraceStruct,ChosenTraceIndices,offset_nm,LinLog)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Plot selected traces from a TraceStruct; not 
    %intended for direct call by user
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %ChosenTraceIndices: a vector containing the indices of the traces to
    %   be plotted
    %
    %offset_nm: the amount (in the units of x, typically nanometers) that
    %   each trace will be shifted to the right by relative to the previous
    %   trace
    %
    %LinLog: Whether the y-axis (Conductance) should be on a linear or
    %   logarithmic scale; acceptable values are "Lin" and "Log"
    

    %Default inputs
    if nargin < 4
        LinLog = 'Log';
    end
    if nargin < 3
        offset_nm = 0.25;
    end
    
    if ~strcmp(LinLog,'Log') && ~strcmp(LinLog,'Lin')
        error('The parameter "LinLog" can only have the values "Lin" or "Log"');
    end
    
    %Load in the trace structure
    TraceStruct = LoadTraceStruct(TraceStruct);
    
    %Make sure y-data are in log-space, as expected (and x-data in linear
    %space)
    TraceStruct.convertTraces('Lin','Log');
    
    nDisp = length(ChosenTraceIndices);
    form = TraceStruct.Format;

    figure();
    hold on;
    xmin = Inf;
    xmax = -Inf;
    for i = 1:nDisp
        %%%tr = TraceStruct.(strcat('Trace',num2str(ChosenTraceIndices(i))));
        tr = TraceStruct.Traces{ChosenTraceIndices(i)};
        if strcmp(form, 'CondOnlyTraces') 
            Xdist = TraceStruct.Xdist;
        elseif strcmp(form, 'FullTraces') || strcmp(form, 'ConductanceTraces')
            Xdist = tr(:,1);
        end
        
        %Plot trace shifted by appropriate amount
        plot(Xdist + (i-1)*offset_nm, 10.^tr(:,2));     
        
        %Find min and max of all traces by checking the first and last
        %distance of each trace being plotted (including shift);
        if Xdist(1) + (i-1)*offset_nm < xmin
            xmin = Xdist(1);
        end
        if Xdist(length(Xdist)) + (i-1)*offset_nm > xmax
            xmax = Xdist(length(Xdist)) + (i-1)*offset_nm;
        end
    end   
    
    %Plot gray lines at each zero
    if offset_nm > 0
        ymin = TraceStruct.NoiseFloor;
        for i = 1:nDisp
            zero_x = (i-1)*offset_nm;
            plot([zero_x, zero_x], [ymin, 1], '--', 'Color', [0.8 0.8 0.8]);
        end
    end
    
    hold off;
    if strcmp(LinLog, 'Log')
        set(gca,'yscale','log');
    end
    
    %Choose appropriate label for x-axis
    if abs(TraceStruct.attenuation_ratio - 1) < 0.1
        distance_type = 'Piezo Distance';
    else
        distance_type = 'Inter-Electrode Distance';
    end
    xlabel(strcat(distance_type,' (', TraceStruct.x_units,')'),'FontSize',14);
    diff = xmax - (nDisp-1)*offset_nm;
    xlim([-diff, xmax]);
    
    %Set Title;
    title(strcat(num2str(nDisp),{' '},'Traces Offset By',{' '},...
        num2str(offset_nm),TraceStruct.x_units)); 
    
    %Set y-axis label:
    ylabel(strcat('Condutance/',TraceStruct.y_units));
    ylim([TraceStruct.NoiseFloor 10]);
    
    %Make legend listing each trace index:
    names = cell(nDisp,1);
    for i = 1:nDisp
        names{i} = strcat('Trace #',num2str(ChosenTraceIndices(i)));
    end
    legend(names);

end