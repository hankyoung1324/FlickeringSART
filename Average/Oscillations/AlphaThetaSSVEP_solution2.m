%% Here's an alternative approach, which is consistent with the single trial
% result, This is used for the final computation of average power
close all;clear all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
exportfolder = 'Export\';
pwfolder = 'Pw900_whole\';
n = [11,20,13,31];% P7,P8,Pz,Fz
ON_file = dir([rootfolder procfolder pwfolder '\dataComp*EEG_ON*.mat']);
OFF_file = dir([rootfolder procfolder pwfolder '\dataComp*EEG_OFF*.mat']);
stickness_high_file = dir([rootfolder procfolder pwfolder '\dataComp*EEG_stickness_high*.mat']);
stickness_low_file = dir([rootfolder procfolder pwfolder '\dataComp*EEG_stickness_low*.mat']);

er_alpha_ON = zeros(length(ON_file),length(n));
er_theta_ON = er_alpha_ON;
er_alpha_OFF = er_alpha_ON;
er_theta_OFF = er_alpha_ON;
for i = 1:length(ON_file)
if erase(ON_file(i).name,'EEG_ON')== erase(OFF_file(i).name,'EEG_OFF')
    load([rootfolder procfolder pwfolder ON_file(i).name]);
    er_alpha_ON(i,:) = transpose(mean(Power_alpha,2));
    er_theta_ON(i,:) = transpose(mean(Power_theta,2));
    load([rootfolder procfolder pwfolder OFF_file(i).name]);
    er_alpha_OFF(i,:) = transpose(mean(Power_alpha,2));
    er_theta_OFF(i,:) = transpose(mean(Power_theta,2));
else
    error(['Not the same number for participant ' num2str(i)])
end
end
er_alpha_ONtemp = er_alpha_ON;
er_alpha_OFFtemp = er_alpha_OFF;
er_theta_ONtemp = er_theta_ON;
er_theta_OFFtemp = er_theta_OFF;

for i = 1:length(stickness_high_file)
if erase(stickness_low_file(i).name,'EEG_stickness_low')== erase(stickness_high_file(i).name,'EEG_stickness_high')
    load([rootfolder procfolder pwfolder stickness_low_file(i).name]);
    er_alpha_stickness_low(i,:) = transpose(mean(Power_alpha,2));
    er_theta_stickness_low(i,:) = transpose(mean(Power_theta,2));
    
    load([rootfolder procfolder pwfolder stickness_high_file(i).name]);
    er_alpha_stickness_high(i,:) = transpose(mean(Power_alpha,2));
    er_theta_stickness_high(i,:) = transpose(mean(Power_theta,2));
else
    error(['Not the same number for participant ' num2str(i)])
end
end

er_alpha_stickness_lowtemp = er_alpha_stickness_low;
er_alpha_stickness_hightemp = er_alpha_stickness_high;

er_theta_stickness_lowtemp = er_theta_stickness_low;
er_theta_stickness_hightemp = er_theta_stickness_high;


alpha_wide = [er_alpha_OFFtemp(:,[1,3,2,4]);er_alpha_ONtemp(:,[1,3,2,4])];
alpha_wide_stickiness = [er_alpha_stickness_hightemp(:,[1,3,2,4]);er_alpha_stickness_lowtemp(:,[1,3,2,4])];

theta_wide = [er_theta_OFFtemp(:,[1,3,2,4]);er_theta_ONtemp(:,[1,3,2,4])];
theta_wide_stickiness = [er_theta_stickness_hightemp(:,[1,3,2,4]);er_theta_stickness_lowtemp(:,[1,3,2,4])];

save([rootfolder procfolder '\bandExport_wide_er900_whole.mat'],'theta_wide','alpha_wide');
save([rootfolder procfolder '\bandExport_wide_stickiness_er900_whole.mat'],'theta_wide_stickiness','alpha_wide_stickiness');