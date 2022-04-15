function [peaks_ON,peaks_OFF] = sumitcPeaks_exact(vitc_ON,vitc_OFF,freqWin_125,freqWin_250,freqs_ON_0,freqs_OFF_0,timesWin,times_ON_0,times_OFF_0,freqWin_alpha,timesWin_alpha,meanMax,meanMax_alpha)%(vitc_ON,efreqs_ON,vitc_OFF,efreqs_OFF)
% Return the itc peaks
%  The returned values are freqency of the peak and the itc value;
% 1-2, Peak frequency and itc around 12.5 Hz(On task)
% 3-4, Peak frequency and itc around 12.5 Hz(Off task)
% 5-6, Peak frequency and itc around 25 Hz(On task)
% 7-8, Peak frequency and itc around 25 Hz(Off task)

    [freqPeak1,itcPeak1] = itcPeaks2D_exact(vitc_ON,freqWin_125,freqs_ON_0,timesWin,times_ON_0,meanMax);%(12.5,vitc_ON,efreqs_ON);
    [freqPeak2,itcPeak2] = itcPeaks2D_exact(vitc_ON,freqWin_250,freqs_ON_0,timesWin,times_ON_0,meanMax);%(25,vitc_ON,efreqs_ON);
    [freqPeak3,itcPeak3] = itcPeaks2D_exact(vitc_OFF,freqWin_125,freqs_OFF_0,timesWin,times_OFF_0,meanMax);%(12.5,vitc_OFF,efreqs_OFF);
    [freqPeak4,itcPeak4] = itcPeaks2D_exact(vitc_OFF,freqWin_250,freqs_OFF_0,timesWin,times_OFF_0,meanMax);%(25,vitc_OFF,efreqs_OFF);
    
    
    [freqPeak5,itcPeak5] = itcPeaks2D_exact(vitc_ON,freqWin_alpha,freqs_ON_0,timesWin_alpha,times_ON_0,meanMax_alpha);%(alpha,vitc_ON,efreqs_ON);
    [freqPeak6,itcPeak6] = itcPeaks2D_exact(vitc_OFF,freqWin_alpha,freqs_OFF_0,timesWin_alpha,times_OFF_0,meanMax_alpha);%(12.5,vitc_OFF,efreqs_OFF);

peaks_ON = [freqPeak1;itcPeak1;freqPeak2;itcPeak2;freqPeak5;itcPeak5];
peaks_OFF = [freqPeak3;itcPeak3;freqPeak4;itcPeak4;freqPeak6;itcPeak6];
% peaks_
end

