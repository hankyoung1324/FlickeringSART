function [ampPeak,latPeak] = erpPeaki(EEG_ON,erps,i)
% Detect the erps peak given the parameters for erps detection
chan = erps.chans(i,:);
twind = erps.wind(i,:);
nonz = nnz(EEG_ON.data);%eval(['nnz(' strjoin([EEGs(i) 'data'], '.') ')']); % Number of non-zero elements
    if nonz ~= 0
        [,indWin] = find(EEG_ON.times>=twind(1) & EEG_ON.times<=twind(2));
        ave_ON = mean(EEG_ON.data,3);
        win_ON = ave_ON(chan,indWin);
        polarity = erps.polar{i};
        if polarity =='positive'
            [ampPeak,b] = max(win_ON,[],2);
        elseif polarity == 'negative'
            [ampPeak,b] = min(win_ON,[],2);
        end
        indPeak = b + min(indWin)-1;
        latPeak = EEG_ON.times(indPeak);
    elseif nonz == 0
        ampPeak = [];
        latPeak = [];
    end
end