function [currentKnee, bestErrorCut] = ...
    Iterative_LMethod(EvaluationGraphData,minCutoff,EvalType,ToPlot)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Find the "best" # of segments to split a trace 
    %into by finding the "knee" of the total error/error gain vs. # of 
    %segments graph. Repeat process iteratively to correct for imbalance 
    %of lots of low-error points vs. just a few high error points
    %
    %ATTRIBUTION NOTE: Based on algorithm developed and described by 
    %Salvador & Chan 2004  in doi.org/10.1109/ICTAI.2004.50
    %
    %~~~INPUTS~~~:
    %
    %EvaluationGraphData: the data for the "evaluation graph" that we are
    %   trying to find the knee of.  The first column is # of segments, the
    %   second is the evaluation metric (either total error or error
    %   gained)
    %
    %minCutoff: smallest # of points that can be used to find the knee
    %   during the iterative process (Salvador & Chan suggest always using
    %   20)
    %
    %EvalType: a string identifying the second column of
    %   EvaluationGraphData as either the total error or the error gain
    %
    %ToPlot: logical variable, whether or not to plot the outputs
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %currentKnee: the chosen value for the knee, i.e. the "best" # of
    %   segments to use
    %
    %bestErrorCut: the value of the error metric at the optimal # of
    %   segments
    
    
    if nargin < 2
        minCutoff = 20;
    end
    if nargin < 3
        EvalType = 'ErrorGain';
    end
    if nargin < 4
        ToPlot = false;
    end

    %EvaluationGraphData = sortrows(EvaluationGraphData,1);    
    
    first_nSeg = EvaluationGraphData(1,1);

    %# of Segments at the previously determined knee
    [currentKnee,bestErrorCut] = LMethod(EvaluationGraphData,EvalType,ToPlot);
    lastKnee = currentKnee+1; %So that the while loop runs at least once
    %disp([currentKnee bestErrorCut]);
    
    while currentKnee < lastKnee
        
        %Set the cut-off to include twice as many points as are before the
        %knee
        lastKnee = currentKnee;
        lastKnee_index = lastKnee - first_nSeg + 1;
        cutoff = 2*lastKnee_index;
        
        %Impose a floor on the cutoff so that we always have enough points
        %in our fitting
        cutoff = max(cutoff, minCutoff);
        
        %Re-determine knee using only the data up to the cut-off
        [currentKnee,bestErrorCut] = LMethod(EvaluationGraphData(1:cutoff, :),EvalType,ToPlot);
        %disp([currentKnee bestErrorCut]);
        
    end   
    
end
