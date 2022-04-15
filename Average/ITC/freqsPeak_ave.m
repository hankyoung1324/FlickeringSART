function [frePeak,pwPeak] = freqsPeak_ave(fre_ON,freqWin_125,freqWin_250,freqWin_alpha,pw_ON)
% 
%         [c1,d1] = min(abs(fre_ON - freq(1)),[],2);
%         [c2,d2] = min(abs(fre_ON - freq(2)),[],2);
%         frePeak = [fre_ON(:,unique(d1)) fre_ON(:,unique(d2))];
%         pwPeak = [pw_ON(:,unique(d1)) pw_ON(:,unique(d2))];
        
        indFreqWin_125 = intersect(find(fre_ON >= freqWin_125(1)),find(fre_ON <= freqWin_125(2)));
        indFreqWin_250 = intersect(find(fre_ON >= freqWin_250(1)),find(fre_ON <= freqWin_250(2)));
        indFreqWin_alpha = intersect(find(fre_ON >= freqWin_alpha(1)),find(fre_ON <= freqWin_alpha(2)));
        frePeak = [mean(fre_ON(:,indFreqWin_125)),mean(fre_ON(:,indFreqWin_250)),mean(fre_ON(:,indFreqWin_alpha))];
        pwPeak = [mean(pw_ON(:,indFreqWin_125)),mean(pw_ON(:,indFreqWin_250)),mean(pw_ON(:,indFreqWin_alpha))];
end

