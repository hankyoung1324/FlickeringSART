% This script is to calculate the ITC across frequencies, the files inside the
% folder "SSVEPPeaks_Oz..." will be further put into the statistics in R.
%% Plot average
close all;clear all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
exportfolder = 'Export\';
load([rootfolder procfolder 'all_total_RelatedStickiness.mat']);
v_setfiles = dir([rootfolder procfolder 'PreCleanICApostAve\*.mat']);
load([rootfolder procfolder 'PreCleanICApostAve\' v_setfiles(1).name]) %% An example for 
nameNaOrd = {v_setfiles.name}';
nameDeOrd = nameNaOrd;
%% Plot the ON-vs-OFF task
chs = [11,20,13,31,16];% P7,P8,Pz,Fz,Oz
ave_ON = squeeze(mean(all_ON,1));
ave_OFF = squeeze(mean(all_OFF,1));
for ch = chs
subplot(3,2,find(ch == chs))
p1 = plot(EEG_ON.times,ave_ON(ch,:),'LineWidth',1.5,'Color',[0.8500, 0.3250, 0.0980]);
hold on;
p2 = plot(EEG_OFF.times,ave_OFF(ch,:),'LineWidth',1.5,'Color',[0.3010, 0.7450, 0.9330]);
title(['Electrode ' EEG_ON.chanlocs(ch).labels]);
xlabel('Time(ms)')
ylabel('Amplitude(\muV)')
legend([p1,p2],{'On-task trials','Off-task trials'});
set(gca,'ylim',[-5.5,7],'xlim',[-200,1200],'FontSize',12);
hold off;
% waitforbuttonpress
% saveas(gcf,[rootfolder exportfolder  ['SART_ONOFF_ave_' EEG_ON.chanlocs(ch).labels '.tiff']],'tiff')
end
% 
ch = 16;
ave_ONOFF = ave_ON(ch,:) - ave_OFF(ch,:);
subplot(3,2,6)
plot(EEG_OFF.times,ave_ONOFF,'k--','LineWidth',1.5);
xlabel('Time(ms)')
ylabel('Amplitude(\muV)')
title('Difference plot of Electrode Oz')


set(gcf, 'Position', [0 0 1800 1200]);
suptitle('Average ERP waveform between mind wandering and on-task')
saveas(gcf,[rootfolder exportfolder  'SART_ERPs_subplot_ONOFF.tiff'],'tiff')
%% Plot stickiness
chs = [11,20,13,31,16];% P7,P8,Pz,Fz,Oz
ave_stickness_low = squeeze(mean(all_stickness_low,1));
ave_stickness_high = squeeze(mean(all_stickness_high,1));
for ch = chs
subplot(3,2,find(ch == chs))
p1 = plot(EEG_stickness_low.times,ave_stickness_low(ch,:),'LineWidth',1.5,'Color',[0.8500, 0.3250, 0.0980]);
hold on;
p2 = plot(EEG_stickness_high.times,ave_stickness_high(ch,:),'LineWidth',1.5,'Color',[0.3010, 0.7450, 0.9330]);
title(['Electrode ' EEG_stickness_low.chanlocs(ch).labels]);
xlabel('Time(ms)')
ylabel('Amplitude(\muV)')
legend([p1,p2],{'Less sticky trials','More sticky trials'});
set(gca,'ylim',[-5.5,7],'xlim',[-200,1200],'FontSize',12);
hold off;
% waitforbuttonpress
% saveas(gcf,[rootfolder exportfolder  ['SART_ONOFF_ave_' EEG_ON.chanlocs(ch).labels '.tiff']],'tiff')
end

ch = 16
ave_stickinessDiff = ave_stickness_low(ch,:) - ave_stickness_high(ch,:);
subplot(3,2,6)
plot(EEG_OFF.times,ave_stickinessDiff,'k--','LineWidth',1.5);
xlabel('Time(ms)')
ylabel('Amplitude(\muV)')
title('Difference plot of Electrode Oz')

set(gcf, 'Position', [0 0 1800 1200]);
suptitle('Average ERP waveform between less sticky and more sticky trials')
saveas(gcf,[rootfolder exportfolder  'SART_ERPs_subplot_stickiness.tiff'],'tiff')
%% The period of -200ms-1200ms is selected for further analysis of the SSVEP

% Part 1: amplitude of SSVEP
% AmpPw.twind = [0,1200];
% ITC calculation with a bigger window
AmpPw.chan = [16];
AmpPw.twind = [-200,1200];
AmpPw.freq = [12.5;25];

% ITC window
statfolder = 'Stats\';
load([rootfolder statfolder 'times.mat']);
freqWin_125 = [12 13];
freqWin_250 = [24.5 25.5];
freqWin_alpha = [8 12];
if exist('freqWin_alpha')
    isalpha = 1;
else
    isalpha = 0;
end
timesWin_alpha = [times_ON(1) times_ON(end)]; 
% timesWin = [times_ON(1) times_ON(end)];
timesWin = [500 900];
EEGs = who('-regexp', 'EEG_'); 
EEGs = EEGs(5:10);
for n = 1:length(v_setfiles)
% n = 1;
    load([rootfolder procfolder 'PreCleanICApostAve\' v_setfiles(n).name]);
    filename = v_setfiles(n).name;
    [filepath,shortName,ext] = fileparts(filename);
    for i = 1:length(EEGs)
        nonz = eval(['nnz(' strjoin([EEGs(i) 'data'], '.') ')']); % Number of non-zero elements
        if nonz~=0
            EEGdata(i) = eval(cell2sym(EEGs(i)));
        end
    end
    %% Peak power and ITC
%     for t = 1:size(all_ON,1)
%         fprintf(2,['\n Subject ' num2str(t) '\n']);

        [meanamp,peakamp,latPeak,frePeak,pwPeak,freqs,frePeak_itc,itcPeak,frePeak_ersp,erspPeak] = arrayfun(@(x) ssvepPeak(x,AmpPw,freqWin_125,freqWin_250,timesWin,freqWin_alpha,timesWin_alpha), EEGdata, 'UniformOutput', false);
%     end

    ssvep.meanamp = transpose(meanamp);
    ssvep.peakamp = transpose(peakamp);
    ssvep.latPeak = transpose(latPeak);
    ssvep.frePeak = transpose(frePeak);
    ssvep.pwPeak = transpose(pwPeak);
    ssvep.freqs = transpose(freqs);
    ssvep.frePeak_itc = transpose(frePeak_itc);
    ssvep.itcPeak = transpose(itcPeak);
    ssvep.frePeak_ersp = transpose(frePeak_ersp);
    ssvep.erspPeak = transpose(erspPeak);


    pchanlabels = {};
    pchanlabels = cell(length(EEGs),length(AmpPw.chan));
    for r = 1:length(EEGdata)
            if nnz(ssvep.meanamp{r,1})~= 0
                s.meanamp(r,:) = transpose(ssvep.meanamp{r,1});
                s.peakamp(r,:) = transpose(ssvep.peakamp{r,1});
                s.latPeak(r,:) = transpose(ssvep.latPeak{r,1});
                s.pwPeak(r,:) = reshape(transpose(ssvep.pwPeak{r,:}),1,length(AmpPw.chan)*(length(AmpPw.freq)+isalpha));
                s.frePeak(r,:) = reshape(transpose(ssvep.frePeak{r,:}),1,length(AmpPw.chan)*(length(AmpPw.freq)+isalpha));

                s.frePeak_itc(r,:) = reshape(transpose(ssvep.frePeak_itc{r,:}),1,length(AmpPw.chan)*(length(AmpPw.freq)+isalpha));
                s.itcPeak(r,:) = reshape(transpose(ssvep.itcPeak{r,:}),1,length(AmpPw.chan)*(length(AmpPw.freq)+isalpha));
                
                s.frePeak_ersp(r,:) = reshape(transpose(ssvep.frePeak_ersp{r,:}),1,length(AmpPw.chan)*(length(AmpPw.freq)+isalpha));
                s.erspPeak(r,:) = reshape(transpose(ssvep.erspPeak{r,:}),1,length(AmpPw.chan)*(length(AmpPw.freq)+isalpha));
                for rr= 1:size(AmpPw.chan,2)
                    pchanlabels{r,rr} = EEG_ON.chanlocs(AmpPw.chan(rr)).labels;
                end
            end
    end
    clear EEGdata;
%     save([rootfolder procfolder 'SSVEPPeaks\' shortName '.mat'],'s','pchanlabels')
    chans = [EEG_ON.chanlocs(AmpPw.chan).labels];
    folderName = ['SSVEPPeaks_' chans '_' num2str(AmpPw.twind(1)),num2str(AmpPw.twind(2)) '_wind' num2str(timesWin(1)) num2str(timesWin(2)) '_freqwind' num2str(freqWin_125(1)) num2str(freqWin_125(2)) 'alpha'];
    savefolder = [rootfolder procfolder folderName];
    if ~exist(savefolder, 'dir')
       mkdir(savefolder)
    end
    save([savefolder '\' shortName '.mat'],'s','pchanlabels')
end

% save([rootfolder procfolder 'EEGs.mat'],'EEGs')
%% calculate number of participants
save_part(40,nums_on,nums_off,'onoff',rootfolder, procfolder,v_setfiles)
save_part(40,nums_stickness_high,nums_stickness_low,'stickiness',rootfolder, procfolder,v_setfiles)
save_part(40,nums_stickness_high,nums_stickness_low,'stickiness',rootfolder, procfolder,v_setfiles)
%% Separate participants
figure;
for n =1:length(v_setfiles)
for ch = chs(3) % Channel number
    Di = nameDeOrd(n); 
    fName= titleName(Di,'_');
    subplot(5,8,find(ismember(nameDeOrd,Di)))
    p3 = plot(EEG_ON.times,squeeze(all_ON(n,ch,:)),'LineWidth',1,'Color',[0.8500, 0.3250, 0.0980]);
    hold on;
    p4 = plot(EEG_OFF.times,squeeze(all_OFF(n,ch,:)),'LineWidth',1,'Color',[0.3010, 0.7450, 0.9330]);
    xlabel('Time(ms)')
    ylabel('Amplitude')
    title([fName])
%     legend([p3,p4],{['On-task trials(' num2str(nums_on(n)) ' trials)'], ['Off-task trials(' num2str(nums_off(n)) ' trials)']},'Location','northeast');
    set(gca,'xlim',[min(EEG_ON.times),max(EEG_ON.times)],'ylim',[-20 20]);
    % sgtitle(['Participant' num2str(n)]);
%     waitforbuttonpress
end
end
set(gcf, 'Position', [0 0 1800 3600]);
suptitle('Average ERP waveform during SART task for ON- /OFF- conditions(Oz)')
saveas(gcf,[rootfolder exportfolder  'SART_ONOFF_parts.tiff'],'tiff')
%% Plot stickiness 
figure;
for n =1:length(v_setfiles)
    for ch = chs(3) % Channel number
        Di = nameDeOrd(n); 
        fName= titleName(Di,'sub');
        subplot(5,8,find(ismember(nameDeOrd,Di)))
        p3 = plot(EEG_stickness_low.times,squeeze(all_stickness_low(n,ch,:)),'LineWidth',1,'Color',[0.8500, 0.3250, 0.0980]);
        hold on;
        p4 = plot(EEG_stickness_high.times,squeeze(all_stickness_high(n,ch,:)),'LineWidth',1,'Color',[0.3010, 0.7450, 0.9330]);
        % hold on;

        xlabel('Time(ms)')
        ylabel('Amplitude')
        title([fName])
        legend([p3,p4],{['Less sticky trials(' num2str(nums_stickness_low(n)) ' trials)'], ['More sticky trials(' num2str(nums_stickness_high(n)) ' trials)']},'Location','northeast');
        set(gca,'xlim',[min(EEG_stickness_low.times),max(EEG_stickness_high.times)],'ylim',[-20 20]);
        % sgtitle(['Participant' num2str(n)]);
    end
end
set(gcf, 'Position', [0 0 1800 1800]);
suptitle('Average ERP waveform during SART task for less/more sticky trials(Oz)')
saveas(gcf,[rootfolder exportfolder  'SART_Stickiness_parts.tiff'],'tiff')

%% Plot Go/Nogo response
figure;
for n = 1:length(v_setfiles)
    for ch = chs(3) % Channel number
    Di = nameDeOrd(n);
%     n = find(ismember(nameNaOrd,Di));
    fName = titleName(Di);
    subplot(5,8,find(ismember(nameDeOrd,Di)))
%     subplot(2,2,find(ismember(nameDeOrd,Di)))
    p5 = plot(EEG_Go_corr.times,all_Go_corr(n,:),'LineWidth',1.5,'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-');
    hold on;
    p6 = plot(EEG_Go_corr.times,all_Go_incorr(n,:),'LineWidth',1.5,'Color',	[0.9290, 0.6940, 0.1250],'LineStyle','--');
    hold on;
    p7 =  plot(EEG_Go_corr.times,all_Nogo_corr(n,:),'LineWidth',1.5,'Color',[0.4660, 0.6740, 0.1880],'LineStyle','-');
    hold on;
    p8 = plot(EEG_Go_corr.times,all_Nogo_incorr(n,:),'LineWidth',1.5,'Color',[0.3010, 0.7450, 0.9330],'LineStyle','--');
    xlabel('Time(ms)')
    ylabel('Amplitude')
    title([fName]);
    legend([p5,p6,p7,p8],{['Go-Correct(' num2str(nums_Go_corr(n)) ' trials)'], ['Go-Incorrect(' num2str(nums_Go_incorr(n)) ' trials)'],['Nogo-Correct(' num2str(nums_Nogo_corr(n)) ' trials)'] ['Nogo-Incorrect(' num2str(nums_Nogo_incorr(n)) ' trials)']},'Location','northeast');
    set(gca,'xlim',[min(EEG_Go_corr.times)-2,max(EEG_Go_corr.times)+2],'ylim',[-20 20]);
    end
end
set(gcf, 'Position', [0 0 1200 1200]);
suptitle('Average ERP waveform during SART task for Go/Nogo conditions(Oz)')
saveas(gcf,[rootfolder exportfolder 'SART_GoNogo_parts.tiff'],'tiff')
%% Plot Frequency
figure;
for n = 1:length(v_setfiles)
    Di = nameDeOrd(n);
%     n = find(ismember(nameNaOrd,Di));
    fName = titleName(Di);
    ch = 16;
    N_ON = size(all_ON,2);
    % figure;
    [fre_ON,pw_ON] = freqSSVEP(EEG_ON.srate,all_ON(n,:),N_ON);

    N_OFF = size(all_OFF,2);
    % figure;
    [fre_OFF,pw_OFF] = freqSSVEP(EEG_OFF.srate,all_OFF(n,:),N_OFF);

    % N_ONOFF = size(aveEEG_ONOFF,2);
    % figure;
    % [fre_ONOFF,pw_ONOFF] = freqSSVEP(EEG_ONOFF.srate,all_ONOFF(n,:),N_ONOFF);

    subplot(4,5,find(ismember(nameDeOrd,Di)))
%     subplot(2,2,find(ismember(nameDeOrd,Di)))
    p9 = plot(fre_ON,[pw_ON],'LineWidth',1.5,'Color',[0.8500, 0.3250, 0.0980]);
    hold on;
    p10 = plot(fre_ON,[pw_OFF],'LineWidth',1.5,'Color',[0.3010, 0.7450, 0.9330]);
    xline(12.5,'LineStyle','--');
    text(13,-3.5,'f = 12.5 Hz')
    xlabel('Frequency(Hz)')
    ylabel('Power(log10 transformed)')
%     legend([p9,p10],{['On-task trials(' num2str(nums_on(n)) ' trials)'], ['Off-task trials(' num2str(nums_off(n)) ' trials)']},'Location','northeast');
    title([fName]);
    set(gca,'xlim',[0,40]);
end
set(gcf, 'Position', [0 0 1800 1800]);
suptitle('Power spectrum of On-/off- task condition(Oz)')
saveas(gcf,[rootfolder exportfolder 'SART_freq_parts.tiff'],'tiff')