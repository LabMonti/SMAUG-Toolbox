%11May18 NDB: Find the "best" # of segments to split a trace into by
%finding the "knee" of the total error/error gain vs. # of segments graph.
%Based on algorithm suggested by Salvador & Chan 2004 (DOI:
%10.1109/ICTAI.2004.50)
function [nSegs_knee, best_error_cutoff] = LMethod(ErrorVsSegs,EvalType,ToPlot)
    %~~~INPUTS~~~:
    %
    %ErrorVsSegs: the data for the "evaluation graph" that we are
    %   trying to find the knee of.  The first column is # of segments, the
    %   second is the evaluation metric (either total error or error
    %   gained)
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
    %nSegs_knee: the chosen value for the knee, i.e. the "best" # of
    %   segments to use
    %
    %best_error_cutoff: the value of the error metric at the optimal # of
    %   segments
    
    
    if nargin < 2
        EvalType = 'ErrorGain';
    end
    if nargin < 3
        ToPlot = false;
    end

    %ErrorVsSegs = sortrows(ErrorVsSegs,1);
    
    %Choosing which parameter to use for evaluation each # of segments:
    %either the error gained during the previous merge step (stored in the
    %second column of ErrorVsSegs) or the total error at each step (stored
    %in the third column)
    if strcmp(EvalType,'ErrorGain') == 1
        ErrorVsSegs = ErrorVsSegs(:,[true true false]);
    elseif strcmp(EvalType,'TotalError') == 1
        ErrorVsSegs = ErrorVsSegs(:,[true false true]);
    else
        error('Unrecoginized choice for EvalType');
    end

    N = length(ErrorVsSegs);
    LMethod_Error = Inf(N, 1);
    
    for i = 3:N-2
        
        %Sum of sqaured errors, and root mean square error for the first
        %line segment, extending from the first data point up to the ith
        SSE_1 = GetSegError(ErrorVsSegs(1:i,:));
        RMSE_1 = sqrt(SSE_1 / i);

        %SSE and RMSE for the second line segment, extending from the
        %(i+1)th data point until the last point, N
        SSE_2 = GetSegError(ErrorVsSegs(i:N,:));
        RMSE_2 = sqrt(SSE_2 / (N - i));
        
        %Weighted sum of RMSEs to get the total error for choosing this
        %point as the knee
        LMethod_Error(i) = i*RMSE_1 + (N-i+1)*RMSE_2;
    end
    
    [~, minError_index] = min(LMethod_Error);
    
    nSegs_knee = ErrorVsSegs(minError_index,1);
    best_error_cutoff = ErrorVsSegs(minError_index,2);
    
    
    if ToPlot
        figure();
        hold on;
        
        plot(ErrorVsSegs(:,1),ErrorVsSegs(:,2),'o');
        plot(ErrorVsSegs(minError_index,1),ErrorVsSegs(minError_index,2),...
            'o','MarkerFaceColor','r')
        
        xlabel('# of Segments');
        if strcmp(EvalType,'ErrorGain')
            ylabel('Error Gained During Previous Merge');
        elseif strcmp(EvalType,'TotalError')
            ylabel('Total Error at Current Step');
        end
        xlim([0 ErrorVsSegs(N,1)]);
        
        line1 = ErrorVsSegs(1:minError_index,:);
        line2 = ErrorVsSegs(minError_index+1:N,:);
        
        %Plot the best fit for the first line:
        covar = NathansCovariance(line1);
        m = covar(1,2)/covar(1,1);
        b = mean(line1(:,2)) - m * mean(line1(:,1));
        x1 = ErrorVsSegs(1,1);
        x2 = ErrorVsSegs(minError_index,1);
        plot([x1 x2], [m*x1+b,m*x2+b],'--');
        
        %Plot the best fit for the second line:
        covar = NathansCovariance(line2);
        m = covar(1,2)/covar(1,1);
        b = mean(line2(:,2)) - m * mean(line2(:,1));
        x1 = ErrorVsSegs(minError_index+1,1);
        x2 = ErrorVsSegs(N,1);
        plot([x1 x2], [m*x1+b,m*x2+b],'--');
        
        hold off;
    end

end
