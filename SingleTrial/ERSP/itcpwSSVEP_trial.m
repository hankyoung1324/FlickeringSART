%% This is the script to generate the single trial ITC and ERSP at 12.5 Hz, 25 Hz and the alpha frequencies

clear all;
close all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
avefolder = 'PreCleanICApostAve\';
statfolder = 'Stats\';
AmpPw.twind = [-200,1200];

load([rootfolder procfolder 'all_total_RelatedStickiness.mat']);
files = dir([rootfolder procfolder avefolder 'sub*.mat']);
matfiles = files;
nn = 1:length(matfiles);
remPartNo = setdiff(1:length(matfiles),nn);
% remPartName = matfiles(remPartNo).name;
peaks = zeros(length(nn),8);
peaks_stickness = peaks;

% aveitc_ON = zeros(22,55,length(matfiles));
% aveitc_OFF = aveitc_ON;
sumitc_ON = complex(zeros(25,1));
sumitc_OFF = complex(zeros(25,1));

sumpower_ON = complex(zeros(1,384));
sumpower_OFF = sumpower_ON;

sumitc_stickness_low = complex(zeros(25,1));
sumitc_stickness_high = complex(zeros(25,1));

sumpower_stickness_low = complex(zeros(1,384));
sumpower_stickness_high = sumpower_stickness_low;


% for n = 1:length(nameDeOrd)
for n = 1:length(matfiles)
    load([rootfolder procfolder avefolder matfiles(n).name]);
    fName = titleName(matfiles(n).name,'sub');
    ch = 16;
    % Segment the data    
    [,indWin] = find(EEG_ON.times >= AmpPw.twind(1) & EEG_ON.times <= AmpPw.twind(2));
    indPost_min = min(indWin);
    indPost_max = max(indWin);
    
    data_on = EEG_ON.data(ch,indPost_min:indPost_max,:);
    data_off = EEG_OFF.data(ch,indPost_min:indPost_max,:);
    data_stickness_low = EEG_stickness_low.data(ch,indPost_min:indPost_max,:);
    data_stickness_high = EEG_stickness_high.data(ch,indPost_min:indPost_max,:);
    
    itc_ON = zeros(25,200,size(data_on,3));
    ersp_ON = itc_ON;
    freqs_ON = zeros(25,size(data_on,3));
%     freqs_ON = zeros(25,1);
    powbase_ON = zeros(25,size(data_on,3));
    times_ON = zeros(200,size(data_on,3));
    for t = 1:size(data_on,3)
        [ersp_ON_0,itc_ON_0,powbase_ON_0,times_ON_0,freqs_ON_0] = newtimef(squeeze(data_on(:,:,t)), size(data_on,2), round([EEG_ON.times(indPost_min),EEG_ON.times(indPost_max)]) ...
            , EEG_ON.srate, [5 0.5],'baseline',[NaN],'freqs', [8 30],'nfreqs',25, 'freqscale', 'linear', ...
            'padratio', 2,'plotersp', 'off','plotitc','off');   
        ersp_ON(:,:,t) = ersp_ON_0;
        itc_ON(:,:,t) = itc_ON_0;
        powbase_ON(:,t) = powbase_ON_0;
        times_ON(:,t) = times_ON_0;
        freqs_ON(:,t) = freqs_ON_0;
    end

    itc_OFF = zeros(25,200,size(data_off,3));
    ersp_OFF = itc_OFF;
    freqs_OFF = zeros(25,size(data_off,3));
    powbase_OFF = freqs_OFF;
    times_OFF = zeros(200,size(data_off,3));
    for t = 1:size(data_off,3)
        [ersp_OFF_0,itc_OFF_0,powbase_OFF_0,times_OFF_0,freqs_OFF_0] = newtimef(squeeze(data_off(:,:,t)), size(data_off,2), round([EEG_OFF.times(indPost_min),EEG_OFF.times(indPost_max)]) ...
            , EEG_OFF.srate, [5 0.5],'baseline',[NaN],'freqs', [8 30],'nfreqs',25, 'freqscale', 'linear', ...
            'padratio', 2,'plotersp', 'off','plotitc','off');   
        ersp_OFF(:,:,t) = ersp_OFF_0;
        itc_OFF(:,:,t) = itc_OFF_0;
        powbase_OFF(:,t) = powbase_OFF_0;
        times_OFF(:,t) = times_OFF_0;
        freqs_OFF(:,t) = freqs_OFF_0;
    end
    
    itc_stickness_low = zeros(25,200,size(data_stickness_low,3));
    ersp_stickness_low = itc_stickness_low;
    freqs_stickness_low = zeros(25,size(data_stickness_low,3));
    powbase_stickness_low = freqs_stickness_low;
    times_stickness_low = zeros(200,size(data_stickness_low,3));
    for t = 1:size(data_stickness_low,3)
        [ersp_stickness_low_0,itc_stickness_low_0,powbase_stickness_low_0,times_stickness_low_0,freqs_stickness_low_0] = newtimef(squeeze(data_stickness_low(:,:,t)), size(data_stickness_low,2), round([EEG_stickness_low.times(indPost_min),EEG_stickness_low.times(indPost_max)]) ...
            , EEG_stickness_low.srate, [5 0.5],'baseline',[NaN],'freqs', [8 30],'nfreqs',25, 'freqscale', 'linear', ...
            'padratio', 2,'plotersp', 'off','plotitc','off');   
        ersp_stickness_low(:,:,t) = ersp_stickness_low_0;
        itc_stickness_low(:,:,t) = itc_stickness_low_0;
        powbase_stickness_low(:,t) = powbase_stickness_low_0;
        times_stickness_low(:,t) = times_stickness_low_0;
        freqs_stickness_low(:,t) = freqs_stickness_low_0;
    end

    itc_stickness_high = zeros(25,200,size(data_stickness_high,3));
    ersp_stickness_high = itc_stickness_high;
    freqs_stickness_high = zeros(25,size(data_stickness_high,3));
    powbase_stickness_high = freqs_stickness_high;
    times_stickness_high = zeros(200,size(data_stickness_high,3));
    for t = 1:size(data_stickness_high,3)
        [ersp_stickness_high_0,itc_stickness_high_0,powbase_stickness_high_0,times_stickness_high_0,freqs_stickness_high_0] = newtimef(squeeze(data_stickness_high(:,:,t)), size(data_stickness_high,2), round([EEG_stickness_high.times(indPost_min),EEG_stickness_high.times(indPost_max)]) ...
            , EEG_stickness_high.srate, [5 0.5],'baseline',[NaN],'freqs', [8 30],'nfreqs',25, 'freqscale', 'linear', ...
            'padratio', 2,'plotersp', 'off','plotitc','off');   
        ersp_stickness_high(:,:,t) = ersp_stickness_high_0;
        itc_stickness_high(:,:,t) = itc_stickness_high_0;
        powbase_stickness_high(:,t) = powbase_stickness_high_0;
        times_stickness_high(:,t) = times_stickness_high_0;
        freqs_stickness_high(:,t) = freqs_stickness_high_0;
    end
    vitc_ON = abs(itc_ON);
    vitc_OFF = abs(itc_OFF);
    vitc_stickness_low = abs(itc_stickness_low);
    vitc_stickness_high = abs(itc_stickness_high);
    
    versp_ON = ersp_ON;
    versp_OFF = ersp_OFF;
    versp_stickness_low = ersp_stickness_low;
    versp_stickness_high = ersp_stickness_high;
      %  Frequency window
    freqWin_125 = [12 13];
    freqWin_250 = [24.5 25.5];
    freqWin_alpha = [8 12];
    timesWin = [500 900];
    timesWin_alpha = [times_ON_0(1) times_ON_0(end)]; 
%%  
  [itc_peaks_ON,itc_peaks_OFF] = sumitcPeaks_exact(vitc_ON,vitc_OFF,freqWin_125,freqWin_250,freqs_ON_0,freqs_OFF_0,timesWin,times_ON_0,times_OFF_0,freqWin_alpha,timesWin_alpha,'max','ave');%(vitc_ON,freqs_ON_0,vitc_OFF,freqs_OFF_0);
  [itc_peaks_stickness_low,itc_peaks_stickness_high] = sumitcPeaks_exact(vitc_stickness_low,vitc_stickness_high,freqWin_125,freqWin_250,freqs_stickness_low_0,freqs_stickness_high_0,timesWin,times_stickness_low_0,times_stickness_high_0,freqWin_alpha,timesWin_alpha,'max','ave');%(vitc_stickness_low,freqs_stickness_low_0,vitc_stickness_high,freqs_stickness_high_0);
  [ersp_peaks_ON,ersp_peaks_OFF] = sumitcPeaks_exact(versp_ON,versp_OFF,freqWin_125,freqWin_250,freqs_ON_0,freqs_OFF_0,timesWin,times_ON_0,times_OFF_0,freqWin_alpha,timesWin_alpha,'ave','ave');%(vitc_ON,freqs_ON_0,vitc_OFF,freqs_OFF_0);
  [ersp_peaks_stickness_low,ersp_peaks_stickness_high] = sumitcPeaks_exact(versp_stickness_low,versp_stickness_high,freqWin_125,freqWin_250,freqs_stickness_low_0,freqs_stickness_high_0,timesWin,times_stickness_low_0,times_stickness_high_0,freqWin_alpha,timesWin_alpha,'ave','ave');%(vitc_stickness_low,freqs_stickness_low_0,vitc_stickness_high,freqs_stickness_high_0);

  save([rootfolder procfolder 'ITC_ST_exact\peaks_ST' char(fName) '.mat'],'itc_peaks_ON','itc_peaks_OFF','itc_peaks_stickness_low','itc_peaks_stickness_high','ersp_peaks_ON','ersp_peaks_OFF','ersp_peaks_stickness_low','ersp_peaks_stickness_high','freqs_OFF_0', 'freqs_ON_0', 'freqs_stickness_high_0', 'freqs_stickness_low_0');
    

end
% suptitle('ITC across frequencies using the newtimef function');
% set(gcf, 'Position', [0 0 1200 800]);
% saveas(gcf,[rootfolder 'Export\SART_itc_parts_stickiness.jpg'],'jpeg')
% NN = find(nums_off==0|nums_on == 0);
% aveitc_ON = sumitc_ON /(length(matfiles)-length(NN));
% aveitc_OFF = sumitc_OFF /(length(matfiles)-length(NN));
% 
% avepower_ON = sumpower_ON/(length(matfiles)-length(NN));
% avepower_OFF = sumpower_OFF/(length(matfiles)-length(NN));

% aveitc_stickness_low = sumitc_stickness_low /(length(matfiles)-length(NN));
% aveitc_stickness_high = sumitc_stickness_high /(length(matfiles)-length(NN));

% avepower_stickness_low = sumpower_stickness_low/(length(matfiles)-length(NN));
% avepower_stickness_high = sumpower_stickness_high/(length(matfiles)-length(NN));

% save([rootfolder statfolder 'freqs_ST.mat'],'fre_OFF', 'fre_ON', 'fre_stickness_high', 'fre_stickness_low', 'freqs_OFF', 'freqs_ON', 'freqs_stickness_high', 'freqs_stickness_low')
% save([rootfolder statfolder 'plotITC_ST.mat'],'vitc_ON','vitc_OFF','vitc_stickness_low','vitc_stickness_high')
% save([rootfolder statfolder 'peaks_ST.mat'],'peaks','peaks_stickness','remPartNo','remPartNo');
%%
load([rootfolder statfolder 'freqs.mat']);
load([rootfolder statfolder 'plotITC.mat']);
load([rootfolder statfolder 'peaks.mat']);


figure;
p1 = plot(freqs_stickness_low,aveitc_stickness_low,'LineWidth',1,'LineStyle','-','Color',hex2color('#cc0001'));
hold on;
p2 = plot(freqs_stickness_high,aveitc_stickness_high,'LineWidth',1,'LineStyle','-','Color',hex2color('#627ea3'));
xlabel('Frequency(Hz)')
label_h = ylabel('Inter-trial Coherence(ITC)');
label_h.Position = [1.93676971336411,0.0400000372529021,-0.999999999999986];
line([12.5 12.5],[0,.08],'LineStyle','--');
text(13,0.1,'f = 12.5 Hz')
% set(gca,'ylim',[0,1])
legend([p1 p2],{['Less sticky trials'], ['More sticky trials']},'Location','northeast');
title('Inter-trial coherence across frequencies');
set(gcf, 'Position', [0 0 400 300]);
saveas(gcf,[rootfolder 'Export\SART_itc_ave_stickiness.jpg'],'jpeg')

%%
figure;
p1 = plot(freqs_ON,aveitc_ON,'LineWidth',1,'LineStyle','-','Color',hex2color('#cc0001'));
hold on;
p2 = plot(freqs_OFF,aveitc_OFF,'LineWidth',1,'LineStyle','-','Color',hex2color('#627ea3'));
xlabel('Frequency(Hz)')
label_h = ylabel('Inter-trial Coherence(ITC)');
label_h.Position = [1.93676971336411,0.0400000372529021,-0.999999999999986];
line([12.5 12.5],[0,.08],'LineStyle','--');
text(13,0.1,'f = 12.5 Hz')
% set(gca,'ylim',[0,1])
legend([p1 p2],{['On-task trials'], ['Off-task trials']},'Location','northeast');
title('Inter-trial coherence across frequencies');
set(gcf, 'Position', [0 0 400 300]);
saveas(gcf,[rootfolder 'Export\SART_itc_ave.jpg'],'jpeg')

%%
figure;
p1 = plot(fre_ON,avepower_ON,'LineWidth',1.5,'LineStyle','-');
hold on;
p2 = plot(fre_OFF,avepower_OFF,'LineWidth',1.5,'LineStyle','--');
xlabel('Frequency(Hz)')
ylabel('Power')
line([12.5 12.5],[0,6],'LineStyle','--');
text(13,3,'f = 12.5 Hz')
% set(gca,'ylim',[0,0.5])
legend([p1 p2],{['On-task trials'], ['Off-task trials']},'Location','northeast');
title('Power spectrum across frequencies');
set(gcf, 'Position', [0 0 400 300]);
set(gca,'xlim',[0,40]);
saveas(gcf,[rootfolder 'Export\SART_pw_ave.jpg'],'jpeg')