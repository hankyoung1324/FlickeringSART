function [ power_Spectrum ] = meanSpectrum( tmpdata, winlength,overlap,fftlength,srate,lower_bound_theta,upper_bound_theta )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% 
[tmpspec,freqs] = pwelch(tmpdata, winlength,overlap,fftlength,srate);
% logspec = 10*log10(tmpspec);
[ind_low_theta,] = find(freqs>= lower_bound_theta);
[ind_high_theta,] = find(freqs <= upper_bound_theta);
% power_Spectrum = mean(logspec(min(ind_low_theta):max(ind_high_theta)));
power_Spectrum = (abs(mean(tmpspec(min(ind_low_theta):max(ind_high_theta)))))^2;
end