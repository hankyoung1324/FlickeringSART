function [preTrial,postTrial] = splTrial(trialData,EEG)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% trialData = squeeze(EEG.data(10,:,1));
ind_zero = find(EEG.times==0);
preTrial = trialData(:,1:ind_zero);
postTrial = trialData(:,ind_zero+1:end);
end

