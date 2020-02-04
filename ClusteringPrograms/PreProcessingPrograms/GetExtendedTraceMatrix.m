function [Xdist, TraceMat, OriginalTrace_Ends] = GetExtendedTraceMatrix(...
    TraceStruct, LeftChop, CondFloor, distStep, maxDist) 
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: This function reads in a trace structure, then 
    %re-samples and extends each trace so that all the traces share the 
    %same set of x-values (outputted as Xdist).  These re-sampled traces 
    %are stored in TraceMat with one raw per trace and one column per 
    %x-value. On the left side, the traces are chopped off at 'LeftChop' 
    %and thrown out if they do not reach 'LeftChop'  On the right side, 
    %each trace is extended up to the end of the longest trace by adding
    %points along 'CondFloor'.  
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a matlab structure containing log(G/G_0) vs. distance
    %   traces and associated information
    %
    %left_chop: the minimum distance value to use; traces will be
    %   chopped at this value and any distance points less than it will be
    %   discarded. Trace that don't start until after left_chop will be
    %   discarded
    %
    %CondFloor: the conductance floor (in log space) along which traces
    %   will be extended so that they all have the same length
    %
    %distStep: the distance between successive points at which the traces
    %   will be resampled.  Defaults to the median distance between
    %   adjacent points from all traces.
    %
    %maxDist: the largest distance to include in the re-sampled traces.
    %   Defaults to the largest distance value from all the traces.  
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %Xdist: the distance values at which the extended traces were
    %   re-sampled
    %
    %TraceMat: an array in which each row corresponds to a trace and each
    %   column corresponds to one of the distances in Xdist, holding the
    %   re-sampled and extended traces
    %
    %OriginalTrace_Ends: the index, for each trace, of the last distance
    %   point for that trace that is NOT an extension point


    if nargin < 5
        maxDist = Inf;
    end
    if nargin < 4
        distStep = 'median';
    end
    
    %Load trace structure and convert traces:
    TraceStruct = LoadTraceStruct(TraceStruct);
    TraceStruct.convertTraces('Lin', 'Log');
    
    %First, let's remove traces that don't start before LeftChop:
    Ntraces = TraceStruct.Ntraces;
    TracesToUse = cell(Ntraces, 1);
    counter = 0;
    min_value = Inf;
    for i = 1:Ntraces
        %%%trace = TraceStruct.(strcat('Trace',num2str(i)));
        trace = TraceStruct.Traces{i};
        if trace(1,1) < LeftChop
            counter = counter + 1;
            TracesToUse{counter} = trace;
        end
        if trace(1,1) < min_value
            min_value = trace(1,1);
        end
    end
    disp('# of traces removed:');
    disp(Ntraces - counter);
    Ntraces = counter;
    
    %Throw error if all traces removed!
    if Ntraces == 0
        disp('Error: all traces removed!');
        disp(strcat('Left chop is set to:',{' '},num2str(LeftChop)));
        disp('But...');
        disp(strcat('Smallest distance in all traces:',{' '},num2str(min_value)));
        error('STOPPING');
    end

    %If no traces extend as far as the input maxDist, shrink maxDist to be
    %the largest actual distance observed
    all_dists = TraceStruct.getAllData('d');
    maxActualDist = max(all_dists); 
    maxDist = min(maxActualDist, maxDist);
    
    %If requested, go through all the traces to find the median step
    %size along the x-axis
    if strcmp(distStep, 'median')
        AllDistDiffs = zeros(TraceStruct.NumTotalPoints - TraceStruct.Ntraces, 1);
        counter = 0;
        for i = 1:Ntraces
            trace = TracesToUse{i};
            n = length(trace);

            diffs = trace(2:n,1) - trace(1:n-1,1);
            AllDistDiffs(counter+1:counter+n-1) = diffs;
            counter = counter + n-1;
        end
        AllDistDiffs = AllDistDiffs(1:counter);
        distStep = median(AllDistDiffs);
        stdStep = std(AllDistDiffs);
        disp('median step, step stand. dev.:');
        disp([distStep stdStep]);    
    end
    
    %Now create the new list of x-values at which to re-sample every trace:
    Xdist = (LeftChop:distStep:maxDist);
    
    %Make a matrix to hold the re-sampled traces (one row per trace, one
    %column per x-value at which every trace is re-sampled)
    TraceMat = zeros(Ntraces, length(Xdist));
    
    %For each trace, keep track of the farthest point that is NOT part of
    %an extension
    OriginalTrace_Ends = zeros(Ntraces,1);
    
    %Now we need to go through and re-sample each trace (and also extend
    %each trace if necessary);
    disp('Re-sampling traces:');
    for i = 1:Ntraces
        if mod(i, 256) == 0
            disp([i Ntraces]);
        end
        trace = TracesToUse{i};
        
        %If any points fall below the conductance floor, shift them up to
        %the conductance floor
        trace(trace(:,2) < CondFloor, 2) = CondFloor;
        n = length(trace);
        
        %Create flag so we know the FIRST time we see an extension point
        %for each trace
        first_extension_points_flag = false;
        
        %Loop through each new x-value and use linear interpolation to find
        %conductance value of trace at that x-value
        for j = 1:length(Xdist)
            
            %If the current x-value is beyond the end of the trace, use the
            %conductance floor as the y-value
            if Xdist(j) > trace(n, 1)
                TraceMat(i,j) = CondFloor;
                
                %The FIRST time we see a point past the end of the trace,
                %keep track of it as the length of the un-extended trace
                if ~first_extension_points_flag
                    first_extension_points_flag = true;
                    OriginalTrace_Ends(i) = j-1;
                end
            else
                
                %Find index of last point before Xdist(j) using binary
                %search (I had this in a separate function but it was too
                %slow!)
                a = 1;
                b = n;
                if Xdist(j) >= trace(b,1)
                    StartIndex = b;
                else
                    while b > a + 1
                        mid = ceil( (a+b)/2 );
                        if trace(mid,1) > Xdist(j)
                            b = mid;
                        else
                            a = mid;
                        end
                    end
                    StartIndex = a;
                end                

                %Find index of first point after Xdist(j) 
                a = 1;
                b = n;
                if Xdist(j) <= trace(a,1)
                    EndIndex = a;
                else
                    while b > a + 1
                        mid = ceil( (a+b)/2 );
                        if trace(mid,1) >= Xdist(j)
                            b = mid;
                        else
                            a = mid;
                        end
                    end
                    EndIndex = b;
                end
                
                
                %Find the indices of the two points in the original trace
                %that bracket the x-value we want to re-sample at
                %StartIndex = LastBefore(Xdist(j), trace(:,1));
                %EndIndex = FirstAfter(Xdist(j), trace(:,1));
                
                %Get (x,y) values of those two bracketing points:
                x1 = trace(StartIndex,1);
                y1 = trace(StartIndex,2);
                x2 = trace(EndIndex,1);
                y2 = trace(EndIndex,2);    
                
                %Find slope:
                m = (y2 - y1)/(x2 - x1);
                
                if isfinite(m)
                    %Calculate y-value at Xdist(j) by linear interpolation:
                    TraceMat(i,j) = y1 + m*(Xdist(j) - x1);
                else
                    TraceMat(i,j) = (y2 + y1) / 2;
                end
                
            end
            
        end
        if ~first_extension_points_flag
            OriginalTrace_Ends(i) = j;
        end
    end
    
end

% %Given a list of numbers in ascending order, finds the index of the last
% %number in the list less than or equal to 'value'
% function index = LastBefore(value, list)
% 
%     a = 1;
%     b = length(list);
%     
%     if value >= list(b)
%         index = b;
%     else
%     
%         %Use binary search, son!
%         while b > a + 1
% 
%             mid = ceil( (a+b)/2 );
%             if list(mid) > value
%                 b = mid;
%             else
%                 a = mid;
%             end
% 
%         end
%         index = a;
%     end
% 
% end
% 
% %Given a list of numbers in ascending order, finds the index of the first
% %number in the list greater than or equal to 'value'
% function index = FirstAfter(value, list)
% 
%     a = 1;
%     b = length(list);
%     
%     if value <= list(a)
%         index = a;
%     else
%     
%         %Use binary search, son!
%         while b > a + 1
% 
%             mid = ceil( (a+b)/2 );
%             if list(mid) >= value
%                 b = mid;
%             else
%                 a = mid;
%             end
% 
%         end
%         index = b;
%     end
% 
% end
