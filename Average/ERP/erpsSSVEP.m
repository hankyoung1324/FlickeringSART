% Detecting peak values for ERP components
close all;clear all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
exportfolder = 'Export\';

v_setfiles = dir([rootfolder procfolder 'PreCleanICApostAve\*.mat']);
load([rootfolder procfolder 'PreCleanICApostAve\' v_setfiles(1).name]) %% An example for 
% nameNaOrd = {v_setfiles.name}';
% nameDeOrd = nameNaOrd;
nn = [];
ICs = [];
trs = [];
% trs = zeros(length(v_setfiles),2);
for n  = 1:length(v_setfiles)
    load([rootfolder procfolder 'PreCleanICApostAve\' v_setfiles(n).name]);
    filename = v_setfiles(n).name;
    if isfield(EEG_ON,'trials') && isfield(EEG_OFF,'trials') 
        ns = EEG_ON.trials+EEG_OFF.trials;
        IC = size(EEG_ON.icaweights,1);
        tr = [EEG_ON.trials,EEG_OFF.trials];
    else
        ns = 0;
        IC =0;
        tr = [0,0];
    end
    nn = [nn;ns];
    ICs = [ICs;IC];
    trs = [trs;tr];
end
nn(nn==0)=[];
aveTrials = mean(nn)/234;
ICs(ICs==0) = [];
rmICs = 38-ICs;
% Removed participants
rm_part = char({v_setfiles(sum(trs<30,2)~=0).name}');
%% Parameters for the detection of ERPs components
erps.comps = {'p1';'n1';'p3'};
erps.chans = [1:32;1:32;1:32];
erps.wind = [50,200;100,250;250,600];
erps.polar = {'positive';'negative';'positive'};
% EEGdata = zeros(1,length(EEGs))
for n = 1:length(v_setfiles)
    load([rootfolder procfolder 'PreCleanICApostAve\' v_setfiles(n).name]);
    filename = v_setfiles(n).name;
    [filepath,shortName,ext] = fileparts(filename);
    subj = strsplit(shortName,'_');
    EEGs = who('-regexp', 'EEG_'); 
    EEGs = EEGs(5:10);
    for i = 1:length(EEGs)
        nonz = eval(['nnz(' strjoin([EEGs(i) 'data'], '.') ')']); % Number of non-zero elements
        if nonz~=0
            EEGdata(i) = eval(cell2sym(EEGs(i)));
        elseif nonz==0
            fields = fieldnames(EEG_ON)';
            c = cell(length(fields),1);
            s = cell2struct(c,fields);
%             EEG_empty = emptyEEG(eval(cell2sym(EEGs(i))),1);
            EEGdata(i) = s;
        end
    end 

    for p = 1:length(erps.comps)
        [peaks(p,:) lats(p,:)]= arrayfun(@(x) erpPeaki(x,erps,p), EEGdata, 'UniformOutput', false);
    end
    clear EEGdata;
    %% Aggegreate the data and export
    comps = repmat({'p1';'n1';'p3'},length(EEGs),1);
    rpeaks = reshape(peaks,length(EEGs)*length(erps.comps),1);
    rlats = reshape(lats,length(EEGs)*length(erps.comps),1);
    rrpeaks = zeros(length(EEGs)*length(erps.comps),length(erps.chans));
    rrlats = rrpeaks;
    pchan = rrpeaks;
    pchanlabels = {};
    pchanlabels = cell(length(EEGs)*length(erps.comps),length(erps.chans));
    for r = 1:length(rpeaks)
        if nnz(rpeaks{r,1})~= 0
            rrpeaks(r,:) = transpose(rpeaks{r,1});
            rrlats(r,:) = transpose(rlats{r,1});
            pp = find(strcmp(comps{r,1},erps.comps) == 1); % find the channels for given peak
            pchan(r,:) = erps.chans(pp,:);
            for rr= 1:size(erps.chans,2)
                pchanlabels{r,rr} = EEG_ON.chanlocs(pchan(r,rr)).labels;
            end
        end
    end   
    datasets = arrayfun(@(x) repmat(x,length(erps.comps),1),EEGs,'UniformOutput', false);
    datasets = vertcat(datasets{:});
    ERPsPeaks.rrpeaks = reshape(rrpeaks,length(EEGs)*length(erps.comps)*size(erps.chans,2),1);
    ERPsPeaks.rrlats = reshape(rrlats,length(EEGs)*length(erps.comps)*size(erps.chans,2),1);
    ERPsPeaks.pchanlabels = reshape(pchanlabels,length(EEGs)*length(erps.comps)*size(erps.chans,2),1);
    ERPsPeaks.datasets = repmat(datasets,size(erps.chans,2),1);
    ERPsPeaks.comps = repmat(comps,size(erps.chans,2),1);
    ERPsPeaks.subject = repmat(subj{1},length(EEGs)*length(erps.comps)*size(erps.chans,2),1);
    save([rootfolder procfolder 'ERPsPeaks\' shortName '.mat'],'ERPsPeaks')
end
%% ERPs across individuals
%% Let's detect the peaks of average ERPs (which might be different from the ST peaks) with another solution.
% This solution turns out to be the same as the first solution.
close all;clear all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
load([rootfolder procfolder 'all_total_RelatedStickiness.mat']);
setfiles = dir([rootfolder procfolder 'PreCleanICApost\*.mat']);
load([rootfolder procfolder 'PreCleanICApostAve\' setfiles(1).name]); %% An example for 
rm_part_State = find(nums_on==0|nums_off==0);
rm_part_Stick = find(nums_stickness_high==0|nums_stickness_low==0);
rm_name_state=string({setfiles(rm_part_State).name}');
rm_name_stick=string({setfiles(rm_part_Stick).name}');
 % check with the rm_partState_No.csv and rm_partStick_No.csv
%%
erps.comps = {'p1';'n1';'p3'};
erps.chans = [11,20;11,20;13,31];
erps.wind = [50,200;100,250;250,600];
erps.polar = {'positive';'negative';'positive'};

    for p = 1:length(erps.comps)
% p = 1;
%         [peaks(:,:,p) lats(:,:,p)]= arrayfun(@(x) erpPeaki_individual(x,EEG,rm_part_State,erps,i), {'all_ON';'all_OFF'}, 'UniformOutput', false);
            % Detect the erps peak given the parameters for erps detection
%             [ampPeak,latPeak] = erpPeaki_individual(all_ON,EEG,rm_part_State,erps,i);
      [peaks_P1_ON lats_P1_ON] = erpPeaki_individual(all_ON,EEG_ON,rm_part_State,erps,p);
      [peaks_P1_OFF lats_P1_OFF] = erpPeaki_individual(all_OFF,EEG_ON,rm_part_State,erps,p);
      P1_State = [peaks_P1_ON,peaks_P1_OFF,lats_P1_ON,lats_P1_OFF];
%       lats_P1_State = [lats_P1_ON,lats_P1_OFF];
      [peaks_P1_stickness_high lats_P1_stickness_high] = erpPeaki_individual(all_stickness_high,EEG_ON,rm_part_Stick,erps,p);
      [peaks_P1_stickness_low lats_P1_stickness_low] = erpPeaki_individual(all_stickness_low,EEG_ON,rm_part_Stick,erps,p);
      P1_Stick = [peaks_P1_stickness_high,peaks_P1_stickness_low,lats_P1_stickness_high,lats_P1_stickness_low];
      headers_State = [strcat('amp_',erps.comps(p),'_',{EEG_ON.chanlocs(erps.chans(p,1)).labels}), ...
          strcat('amp_',erps.comps(p),'_',{EEG_ON.chanlocs(erps.chans(p,2)).labels}),...
          strcat('amp_',erps.comps(p),'_',{EEG_ON.chanlocs(erps.chans(p,1)).labels}), ...
          strcat('amp_',erps.comps(p),'_',{EEG_ON.chanlocs(erps.chans(p,2)).labels}),...
          strcat('lat_',erps.comps(p),'_',{EEG_ON.chanlocs(erps.chans(p,1)).labels}), ...
          strcat('lat_',erps.comps(p),'_',{EEG_ON.chanlocs(erps.chans(p,2)).labels}),...
          strcat('lat_',erps.comps(p),'_',{EEG_ON.chanlocs(erps.chans(p,1)).labels}), ...
          strcat('lat_',erps.comps(p),'_',{EEG_ON.chanlocs(erps.chans(p,2)).labels})...
          ];

        state_name = char(strcat('G:\RUG\Project_GMD\Labdata\Codes\Ave_State_', erps.comps(p), '.csv'));
        csvwrite_with_headers(state_name,P1_State,[headers_State]);
        csvwrite_with_headers([char(strcat('G:\RUG\Project_GMD\Labdata\Codes\Ave_Stick_', erps.comps(p), '.csv'))],P1_Stick,[headers_State]);

    end