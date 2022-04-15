function [electrode_Power] = electrodePower_whole(EEG,data,lower_bound,upper_bound)
%
% lower_bound = 4;
% upper_bound = 8;
% j = 4;
% data = EEG.data(1:j,:,:);
nelectrode = size(data,1);
ngroup = size(data,3);
electrode_Power = zeros(nelectrode,ngroup);
% electrode_Power_post = electrode_Power_pre;
for i = 1:nelectrode
    d2data = squeeze(data(i,:,:));
    [electrode_Power(i,:)] = groupPower_whole(EEG,d2data,lower_bound,upper_bound);
    fprintf(['Electrode ' num2str(i) ' converted.\n\n'])
end