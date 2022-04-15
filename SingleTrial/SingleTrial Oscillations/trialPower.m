function [power_pre,power_post] = trialPower(EEG,rawdata,lower_bound,upper_bound)
plotOn =0;
% lower_bound = 0.5;
% upper_bound = 30;
transition_width = 0.1;
filter_order = 100;%round(3*(EEG.srate/lower_bound));%
nyquist = EEG.srate/2;

times = EEG.times;
[,hilberted_data] = filHil(rawdata,lower_bound,upper_bound,transition_width,nyquist,filter_order,plotOn,times);
[preHil, postHil] = splTrial(hilberted_data,EEG);

winlength = 64;
overlap = 0;
fftlength = 64;
srate = EEG.srate;
power_pre = meanSpectrum( preHil, winlength,overlap,fftlength,srate,lower_bound,upper_bound );
power_post = meanSpectrum( postHil, winlength,overlap,fftlength,srate,lower_bound,upper_bound );
% power_evo = power_post-power_pre;
end