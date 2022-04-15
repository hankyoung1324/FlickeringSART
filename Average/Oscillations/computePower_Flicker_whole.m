% Compute alpha and theta oscillation for post-stimulus interval, this is for
% the average oscillations
close all;clear all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
exportfolder = 'Export\';
pwfolder = 'Pw900_whole\';
load([rootfolder procfolder 'all_total_RelatedStickiness.mat']);
v_setfiles = dir([rootfolder procfolder 'PreCleanICApostAve\*.mat']);
load([rootfolder procfolder 'PreCleanICApostAve\' v_setfiles(1).name]) %% An example for 
nameNaOrd = {v_setfiles.name}';
nameDeOrd = nameNaOrd;
n = [11,20,13,31];% P7,P8,Pz,Fz
EEGs = who('-regexp', 'EEG_'); 
EEGs = EEGs([5:6 9:10]);
for i = 1:length(EEGs)
    nonz = eval(['nnz(' strjoin([EEGs(i) 'data'], '.') ')']); % Number of non-zero elements
    if nonz~=0
        EEGdata(i) = eval(cell2sym(EEGs(i)));
    end
end    

for sub = 1:length(v_setfiles)
     strs = strsplit(v_setfiles(sub).name,'_');
     strs_sub = char(strs(1));
     fprintf(['Subject ' num2str(sub) ' .\n'])
     load([rootfolder procfolder 'PreCleanICApostAve\' v_setfiles(sub).name])
    for j = 1:length(EEGs)
        nonz = eval(['nnz(' strjoin([EEGs(j) 'data'], '.') ')']); % Number of non-zero elements
        testEEG = eval(cell2sym(EEGs(j)));

        twind = [0,900]; % Post-stimulus interval
        [,indWin] = find(EEG_ON.times >= twind(1) & EEG_ON.times <= twind(2));
        indPost_min = min(indWin);
        indPost_max = max(indWin);
        data = testEEG.data(n,indPost_min:indPost_max,:);

        Power_theta_pre = [];
        Power_theta_pre = zeros(length(n),size(data,3));
        Power_theta_post = Power_theta_pre;
        Power_alpha_pre = Power_theta_pre;
        Power_alpha_post =  Power_theta_pre;
        if nonz~=0
            [Power_theta] = electrodePower_whole(testEEG,data,4,8); %theta power of the electrodes
            [Power_alpha] = electrodePower_whole(testEEG,data,8,12); %alpha power of the electrodes
        end


        save([rootfolder procfolder pwfolder '\dataComp' strs_sub '_' char(EEGs(j)) '.mat'],'Power_alpha','Power_theta')
%                 end
    end
end