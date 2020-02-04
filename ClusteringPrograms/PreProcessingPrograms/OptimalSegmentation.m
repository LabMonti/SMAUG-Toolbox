function [final_segs, final_bounds, TotalError, ErrorGained] = ...
    OptimalSegmentation(trace,EvalType,ToPlot)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Segments a trace in the "optimal" way by using 
    %the Iterative L-Method to find a target # of segments to use and the
    %bottom-up-segmentation algorithm to segment the trace
    %
    %~~~INPUTS~~~:
    %
    %trace: a two-column array with distances in the first column and
    %   log(G/G_0) in the second column
    %
    %EvalType: a string choosing the error metric to be used by the
    %   iterative L-Method; either "TotalError" or "ErrorGain"
    %
    %ToPlot: logical variable, whether or not to plot the final
    %   segmentation solution.  If it is set to 2 or higher, the iterative
    %   L-method plots will also be plotted
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %final_segs: an array holding the x- and y- endpoint values for each 
    %   segment
    %
    %final_bounds: an array listing the starting and ending trace-point 
    %   indices for each segment
    %
    %TotalError: the total error at the optimal solution
    %
    %ErrorGained: the error gained in the last merge step to arrive at the
    %   optimal solution
    
    
    if nargin < 2
        EvalType = 'ErrorGain';
    end
    if nargin < 3
        ToPlot = false;
    end

    minSegs = 2;
    maxSegs = 10;
    
    %Segment trace, and merge segments all the way up to only 2 remaining.
    %Store the error gained for each merge step, and store the final
    %segments for minSegs through maxSegs
    [segment_solutions,errorData] = SegmentTrace_SpecifyNSegs(trace,...
        [minSegs,maxSegs],2,0);

    
    errorData = sortrows(errorData,1);
    
%     [t1, t2] = KneedleAlgorithm(errorData,1);
%     disp(t1);
%     disp(t2);

    %Only use the first 500 elements of the evaluation graph data,
    %since we know the optimal # of segments has always been < 10 and
    %so it won't matter in the iteration anyway (save some time)
    upBound = min(500,size(errorData,1));
    errorData = errorData(1:upBound,:);

    if ToPlot >= 2
        ToPlot_LMethod = true;
    else
        ToPlot_LMethod = false;
    end
    [optimalNseg, ~] = Iterative_LMethod(errorData,20,EvalType,ToPlot_LMethod);

    %If the optimal choice was already store, we just need to retrieve the
    %data
    if optimalNseg <= maxSegs && optimalNseg >= minSegs
        %The order of the solutions in the segment_solutions cell array
        %will be from maxSegs down to minSegs
        solution_index = maxSegs - optimalNseg + 1;
        final_segs = segment_solutions{solution_index,1};
        final_bounds = segment_solutions{solution_index,2};
        TotalError = segment_solutions{solution_index,3};
        ErrorGained = segment_solutions{solution_index,4};
    %If the opitmal choice was not stored, we need to re-run the trace
    %segmentation algorithm
    else
        [output,~] = SegmentTrace_SpecifyNSegs(trace,optimalNseg,2,0); 
        final_segs = output{1};
        final_bounds = output{2};
        TotalError = output{3};
        ErrorGained = output{4};
    end

    %Plot optimal segmentation solution
    if ToPlot
        for_plotting = final_segs;
        nSegs = optimalNseg;

        figure();
        hold on;
        plot(trace(:,1),trace(:,2),'.');
        for i = 1:nSegs
            line(for_plotting(i,1:2),for_plotting(i,3:4),'LineWidth',2,...
                'Color',[0 0 0]);
        end
        xlabel('Inter-Electrode Distance (nm)');
        ylabel('Log(Conductance/G_0)');
        hold off;
    end

end
