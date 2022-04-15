function [electrode_Power_pre,electrode_Power_post] = electrodePower(EEG,data,lower_bound,upper_bound)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% lower_bound = 4;
% upper_bound = 8;
% j = 4;
% data = EEG.data(1:j,:,:);
nelectrode = size(data,1);
ngroup = size(data,3);
electrode_Power_pre = zeros(nelectrode,ngroup);
electrode_Power_post = electrode_Power_pre;
for i = 1:nelectrode
    d2data = squeeze(data(i,:,:));
    [electrode_Power_pre(i,:),electrode_Power_post(i,:)] = groupPower(EEG,d2data,lower_bound,upper_bound);
    fprintf(['Electrode ' num2str(i) ' converted.\n\n'])
end