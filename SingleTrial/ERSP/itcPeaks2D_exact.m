function [freqPeak,itcPeak] = itcPeaks2D_exact(vitc_ON,freqWin,freqs_ON_0,timesWin,times_ON_0,meanMax)
% Detect the peak ITC value
%  The returned values are freqency of the peak and the itc value;
%     freqWin = [10,15];

    indFreqWin = intersect(find(freqs_ON_0 >= freqWin(1)),find(freqs_ON_0 <= freqWin(2)));
    
    [,indWin] = find(times_ON_0 >= timesWin(1) & times_ON_0 <= timesWin(2));
    indPost_min = min(indWin);
    indPost_max = max(indWin);
    
    itcWin= mean(vitc_ON(indFreqWin,indPost_min:indPost_max,:),2);
    itcWin = reshape(itcWin,[size(itcWin,1) size(itcWin,3)]);
    if meanMax == 'max'
        [itcVal,indRel] = max(itcWin,[],1);
        freqPeak = freqs_ON_0(indFreqWin(indRel));
        itcPeak = itcWin(indRel);
    elseif meanMax =='ave'
        itcPeak = mean(itcWin,1);
        freqPeak = repmat(median(freqs_ON_0(indFreqWin)),1,size(itcWin,2));
%         freqPeak = freqPeak';
    end
end

