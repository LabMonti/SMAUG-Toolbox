%15Mar19 NDB: Given two data sets, create a 2D histogram of the difference
%in counts per trace between the two (first minus second)
function Difference_of_2DHists(TraceStruct1, TraceStruct2, binsper_x, ...
    binsper_y, LinLog)

    if nargin < 5
        LinLog = {'Lin', 'Log'};
    end
    if nargin < 4
        binsper_y = 30;
    end
    if nargin < 3
        binsper_x = 80;
    end

    TraceStruct1 = LoadTraceStruct(TraceStruct1);
    TraceStruct2 = LoadTraceStruct(TraceStruct2);
    
    %Get all data from structure 1, remove below noise floor
    DataArray1 = TraceStruct1.getAllData('b');
    DataArray1 = DataArray1(DataArray1(:,2) > log10(TraceStruct1.NoiseFloor),:);
    
    %Find # of bins for structure 1
    nbins_x = round(range(DataArray1(:,1))*binsper_x);
    nbins_y = round(range(DataArray1(:,2))*binsper_y);
    
    %Find counts and centers for structure 1
    [counts1, centers] = hist3(DataArray1, 'Nbins', [nbins_x, nbins_y]);

    %Get all data from structure 2, remove below noise floor
    DataArray2 = TraceStruct2.getAllData('b');
    DataArray2 = DataArray2(DataArray2(:,2) > log10(TraceStruct2.NoiseFloor),:);    
    
    %Find counts for structure 2 using the same centers
    [counts2, ~] = hist3(DataArray2, 'Ctrs', centers);
    
    %Normalize counts for each structure by # of traces
    counts1 = counts1./TraceStruct1.Ntraces;
    counts2 = counts2./TraceStruct2.Ntraces;
    
    %Find difference between two structures!
    CountDiff = counts1 - counts2;
    
    %Put data into format for scatter plotting:
    BigMatrix = zeros(nbins_x * nbins_y, 3);
    counter = 0;
    for i = 1:nbins_x
        for j = 1:nbins_y
            counter = counter + 1;
            BigMatrix(counter,1) = centers{1}(i);
            BigMatrix(counter,2) = centers{2}(j);
            BigMatrix(counter,3) = CountDiff(i,j);
        end
    end 
    
    %Remove zero counts to cut down on graphing overhead
    BigMatrix = BigMatrix(BigMatrix(:,3) ~= 0, :);
    
    %Put conductance data back into linear space for plotting
    BigMatrix(:,2) = 10.^BigMatrix(:,2);
    
    %Make plot
    figure();
    scatter(BigMatrix(:,1),BigMatrix(:,2),30,BigMatrix(:,3),'filled');
    colorbar();
    grid off;
    
    %Make color bar bounds symmetric
    maxDiff = max(max(CountDiff(:)),-min(CountDiff(:)));
    caxis([-maxDiff maxDiff]);

    if strcmp(LinLog{1},'Log')
        set(gca,'XScale','log');
    end    
    if strcmp(LinLog{2},'Log')
        set(gca,'YScale','log');
    end  
    
    %Put a title on the color bar!
    a = gca;
    h = a.Colorbar;
    set(get(h,'label'),'string','\Delta Counts per Trace','Rotation',-90,'VerticalAlignment',...
        'bottom','FontSize',14);
    cmap = importdata('hot_cold_cmap.mat');
    colormap(cmap);
    
    xlabel('Inter-Electrode Distance (nm)');
    ylabel('Log(Conductance/G_0)');

end