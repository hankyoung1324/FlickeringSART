close all;clear all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
exportfolder = 'Export\';
pwfolder = 'Pw\';
load([rootfolder procfolder 'all_total_RelatedStickiness.mat']);
v_setfiles = dir([rootfolder procfolder 'PreCleanICApostAve\*.mat']);
load([rootfolder procfolder 'PreCleanICApostAve\' v_setfiles(1).name]) %% An example for 
nameNaOrd = {v_setfiles.name}';
nameDeOrd = nameNaOrd;
chs = [11,20,13,31];% P7,P8,Pz,Fz
EEGs = who('-regexp', 'EEG_'); 
EEGs = EEGs(5:6);
for i = 1:length(EEGs)
    nonz = eval(['nnz(' strjoin([EEGs(i) 'data'], '.') ')']); % Number of non-zero elements
    if nonz~=0
        EEGdata(i) = eval(cell2sym(EEGs(i)));
    end
end    
%%
erp = 'n1';
subs = 1:length(v_setfiles);
plotOn = 0;
f_output = 'ST';
condset = [];
[measure,f_output,chan,sub] = computeSingleTrialERP_diy(erp, v_setfiles, plotOn,EEGs,f_output);
%%
erp = 'p1';
subs = 1:length(v_setfiles);
plotOn = 0;
f_output = 'ST';
condset = [];
[measure,f_output,chan,sub] = computeSingleTrialERP_diy(erp, v_setfiles, plotOn,EEGs,f_output);
%%
erp = 'p3';
subs = 1:length(v_setfiles);
plotOn = 0;
f_output = 'ST';
condset = [];
[measure,f_output,chan,sub] = computeSingleTrialERP_diy(erp, v_setfiles, plotOn,EEGs,f_output);

%%

