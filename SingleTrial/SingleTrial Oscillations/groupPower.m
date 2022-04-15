function [group_Power_pre,group_Power_post] = groupPower(EEG,d2,lower_bound,upper_bound)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% d2 = squeeze(EEG.data(1,:,:));
nd2 = size(d2,2);
group_Power_pre = zeros(1,nd2);
group_Power_post = zeros(1,nd2);
for i = 1:nd2
    rawdata = squeeze(d2(:,i))';
    [group_Power_pre(i),group_Power_post(i)] = trialPower(EEG,rawdata,lower_bound,upper_bound);
%     fprintf(['Trial ' num2str(i) ' finished.\n'])
end