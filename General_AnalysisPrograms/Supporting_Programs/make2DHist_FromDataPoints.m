%Creates a 2D histogram using a matrix of 2D points as input
%Last Modified: 15Dec2017 NDB
function make2DHist_FromDataPoints(DataPoints2D, binsPer_x, binsPer_y, ...
    LinLog_x, LinLog_y, noise_floor, CountScalar)
    %~~~INPUTS~~~:
    %
    %DataPoints2D: a two-column matrix representing data points in 2D to be
    %   turned into a 2D histogram
    %
    %binsPer_x: the # of bins per unit along the x-axis
    %
    %binsPer_y: the # of bins per unit along the y-axis
    %
    %LinLog_x/LinLog_y: string equal to 'Lin' or 'Log' depending on whether
    %   the x-axis/y-axis should be plotted linearly or logarithmically
    %
    %noise_floor: the smallest meaningful conductance (in units of G_0)
    %
    %CountScalar: a scalar that will be applied to the count values (e.g.
    %   the number of traces contributing to the histogram)
    

    %Set default values for input variables
    if nargin < 7
        CountScalar = 1;
    end
    if nargin < 6
        noise_floor = 1E-6;
    end
    if nargin < 5
        LinLog_y = 'Log';
    end
    if nargin < 4
        LinLog_x = 'Lin';
    end
    if nargin < 3
        binsPer_y = 30;
    end
    if nargin < 2
        binsPer_x = 30;
    end
    if nargin < 1 || nargin > 7
        error('Invalid number of input variables for "make2DHist_FromDataPoints"');
    end
    
    if ~strcmp(LinLog_x,'Log') && ~strcmp(LinLog_x,'Lin')
        error('The parameter "LinLog_x" can only have the values "Lin" or "Log"');
    end    
    if ~strcmp(LinLog_y,'Log') && ~strcmp(LinLog_y,'Lin')
        error('The parameter "LinLog_y" can only have the values "Lin" or "Log"');
    end   
    
    %Transform data if required: input data is assummed to be linear in
    %first column but logarithmic in second
    if strcmp(LinLog_x, 'Log')
        %We'll need to get rid of negative distances in this case!
        DataPoints2D = DataPoints2D(DataPoints2D(:,1) > 0, :);
        DataPoints2D(:,1) = log10(DataPoints2D(:,1));
    end
    if strcmp(LinLog_y, 'Lin')
        DataPoints2D(:,2) = 10 .^ DataPoints2D(:,2);
    end
    
    %Determine number of bins in x and y directions:
    nbinsX1 = round(binsPer_x * range(DataPoints2D(:,1)));
    nbinsX2 = round(binsPer_y * range(DataPoints2D(:,2)));
    
    if nbinsX1 == 0 || nbinsX2 == 0
        error('Error: zero total bins requested!');
    end
    
    %Make the 2D histogram
    make2DHistogram_fromArbitraryData(DataPoints2D,[nbinsX1,nbinsX2],...
        {LinLog_x LinLog_y},CountScalar);
    
    %Set x-axis limits
    xlim([prctile(DataPoints2D(:,1),2), prctile(DataPoints2D(:,1),98)]);
    
    %Get maximum conductance to plot:
    max_cond_4plot = prctile(DataPoints2D(:,2),98);
    if strcmp(LinLog_y, 'Log')
        ylim([noise_floor 10^max_cond_4plot]);
    elseif strcmp(LinLog_y, 'Lin')
        ylim([0, max_cond_4plot]);
    end

end