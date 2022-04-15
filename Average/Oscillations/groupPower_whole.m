function [group_Power] = groupPower_whole(EEG,d2,lower_bound,upper_bound)
%
nd2 = size(d2,2);
group_Power = zeros(1,nd2);
% group_Power_post = zeros(1,nd2);
for i = 1:nd2
    rawdata = squeeze(d2(:,i))';
    [group_Power(i)] = trialPower_whole(EEG,rawdata,lower_bound,upper_bound);
end