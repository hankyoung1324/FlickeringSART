function [freqPeak,itcPeak] = itcPeaks2D(vitc_ON,freqWin,freqs_ON,timesWin,times_ON,meanMax)
% Detect the peak ITC value
%  The returned values are freqency of the peak and the itc value;
%     freqWin = [10,15];

% itc_ON,freqWin_125,freqs_ON,timesWin,times_ON
%         freqWin = freqWin_125;
%         times_ON = times_ON_0;
%        freqs_ON = freqs_ON_0;
%     
    indFreqWin = intersect(find(freqs_ON >= freqWin(1)),find(freqs_ON <= freqWin(2)));
    
    [,indWin] = find(times_ON >= timesWin(1) & times_ON <= timesWin(2));
    indPost_min = min(indWin);
    indPost_max = max(indWin);
%     data_on = EEG_ON.data(ch,indPost_min:indPost_max,:);
%     data_off = EEG_OFF.data(ch,indPost_min:indPost_max,:);
    
    itcWin= mean(vitc_ON(indFreqWin,indPost_min:indPost_max),2);%abs(mean(itc_ON(indFreqWin,:),2));
%     Detecting the frequency which showed the highest ITC
    if meanMax == 'max'
        [itcVal,indRel] = max(itcWin,[],1);
        freqPeak = freqs_ON(indFreqWin(indRel));
        itcPeak = itcWin(indRel);
    elseif meanMax == 'ave'
%     % Detecting the mean ITC in the frequencies
        itcPeak = mean(itcWin,1);
        freqPeak = median(freqs_ON(indFreqWin));
    elseif meanMax == 'sum'
        itcPeak = sum(itcWin,1);
        freqPeak = median(freqs_ON(indFreqWin));      
    end
end

