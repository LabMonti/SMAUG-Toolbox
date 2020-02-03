save_folder = 'C:\Users\LabMonti\Desktop\Nathan Temperory Outputs\TopChopTest';
base_name = '113-3 1uM OPV3-BT-NO2 Dep1T1_';

top_chops = [1.5; 1.75; 2.0; 2.25; 2.5; 2.75; 3.0; 3.25; 3.5];
N = length(top_chops);
Nrep = 12;

RefID = 6;
TopChop_RefID = 5;
cutoff_frac = 0.01;
soln_num = 4;
clust_num = 2;

%Read in all output structures
ClustOut = cell(N,1);
for i = 1:N
    disp([i N]);
    ClustOut{i} = importdata(fullfile(save_folder,strcat(base_name,...
        num2str(top_chops(i)),'_ClustOut.mat')));   
end

%Find a reference cluster for each different top chop
RefOutputs = cell(N,1);
for i = 1:N
    disp([i N]);
    RefOutputs{i} = ClustOut{i}.OO_List{RefID};
end

%Find the solution number and cluster number for the reference from each
%different top chop
[eps_peaks, soln_nums, clust_nums] = MatchSpecificClusterValley(RefOutputs,...
    TopChop_RefID,soln_num,clust_num,cutoff_frac);

%Now we can finally go through and match clusters for each different Top
%Chop's different minPts values
peaks = zeros(N,Nrep);
errors = zeros(N,Nrep);
halfwidths = zeros(N,Nrep);
for i = 1:N
    disp([i N]);
    [peaks(i,:),errors(i,:),halfwidths(i,:)] = Standard_ProcessSegClust_Peaks(...
        ClustOut{i}.OO_List,ClustOut{i}.TracesUsed,cutoff_frac,RefID,...
        soln_nums(i),clust_nums(i),1);
end