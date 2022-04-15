function [filtered_data,hilberted_data] = filHil(rawdata,lower_bound,upper_bound,transition_width,nyquist,filter_order,plotOn,times)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% rawdata = squeeze(filtered_data(1,:));
% plotOn =1;
% lower_bound = 0.5;
% upper_bound = 30;
% transition_width = 0.1;
% filter_order = 200;%round(3*(EEG.srate/lower_bound));%
% nyquist = EEG.srate/2;
% rawdata = squeeze(EEG.data(10,:,1));

rawdata = double(rawdata);
ffrequencies   = [ 0 (1-transition_width)*lower_bound lower_bound upper_bound (1+transition_width)*upper_bound nyquist ]/nyquist;
idealresponse  = [ 0 0 1 1 0 0 ];
filterweights = firls(filter_order,ffrequencies,idealresponse);
filtered_data = filtfilt(filterweights,1,rawdata);
% fft_filtkern  = abs(fft(filterweights));
%% Evaluate the filtering
hilberted_data = hilbert(filtered_data); 
% (hilberted_data)
% pwelch([filtered_data;hilberted_data].',256,0,[],EEG.srate,'centered')
% legend('Original','hilbert')
%%
if plotOn == 1
    hz_filtkern   = linspace(0,nyquist,ceil(length(filterweights)/2));

    figure
    plot(ffrequencies*nyquist,idealresponse,'r')
    hold on

    fft_filtkern  = abs(fft(zscore(filterweights)));
    fft_filtkern  = fft_filtkern./max(fft_filtkern); % normalized to 1.0 for visual comparison ease
    plot(hz_filtkern,fft_filtkern(1:ceil(length(fft_filtkern)/2)),'b')

    set(gca,'ylim',[-.1 1.1],'xlim',[0 nyquist])
    legend({'ideal';'best fit'})

    freqsidx = dsearchn(hz_filtkern',ffrequencies'*nyquist);
    title([ 'SSE: ' num2str(sum( (idealresponse-fft_filtkern(freqsidx)).^2 )) ])
    
%     angleData = ;
    figure;
    plot(times,filtered_data,'b');
    hold on;
    plot(times,real(hilberted_data),'ro');    
    hold on;
    plot(times,angle(hilberted_data),'y')
    legend({'Original','Real hilbert','Phase'});
end
end

