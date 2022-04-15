%% SSVEP With SART 
clear all;
close all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
datafolder = 'Formal\';
procfolder = 'DataProcessing\EEGAnaz\';
avefolder = 'PreCleanICApostAve\';
codefolder = 'Codes\';
files = dir([rootfolder datafolder '*.bdf']);

% Select files according to the file sizes: The larger ones are the SART
% task
fileSize = [files.bytes]';
largeFiles = fileSize > median(fileSize);
v_files = files(largeFiles); %[5,7,8,11,12,13,14,16,17]

for v = length(v_files)
    [a,shortName,c] = fileparts(v_files(v).name);
    EEG = pop_biosig([rootfolder datafolder v_files(v).name],'channels',[1:38]);
    EEG = CutContu_biosemi(EEG,91,99);
    EEG=pop_chanedit(EEG, 'lookup','F:\\EEG_studying\\eeglab14_1_2b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp','load',{'G:\\RUG\\Project_GMD\\Labdata\\Codes\\BioSemi32+6chans.loc' 'filetype' 'autodetect'});
    EEG = pop_eegfiltnew(EEG, 0.5,30,3380,0,[],1);
    EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'ExportEL', [rootfolder codefolder 'eventlistGMD.txt'], 'List', [rootfolder codefolder 'equationGMD.txt'], 'SendEL2', 'All', 'Warning', 'on' ); % GUI: 25-Nov-2019 13:35:13

    EEG  = pop_binlister( EEG , 'BDF', [rootfolder codefolder 'binlisterGMD.txt'], 'ExportEL', [rootfolder codefolder 'eventlist_binedGMD.txt'], 'IndexEL',  1, 'SendEL2', 'All', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
    if v == 31 
        EEG2 = pop_select( EEG,'nopoint',[1847966 1945075] );
    
    end

    for t = 1:length(EEG.event)
        EEG.event(t).gonogo = sum(ismember([1,2,3,4],EEG.event(t).bini))>=1;
        EEG.event(t).marker = sum(ismember([1,2,3,4,5,6,7,8],EEG.event(t).bini))>=1;
    end
    
    % Creat variable for event types in EEG.event structure
    events = [EEG.event(:).type]';
    trials = 5; % Number of trials 
    EEG = eventCoding(EEG,trials,5,'content');
    if sum(ismember([51:59,71:79,81:89],events))~=0
        EEG = eventCoding(EEG,trials,6,'self');
        EEG = eventCoding(EEG,trials,7,'posNag');
        EEG = eventCoding(EEG,trials,8,'stickness');
    end
    for t = 1:length(EEG.event)
        EEG.event(t).binary = ~isempty(EEG.event(t).content);
    end
    oriEEG_event = EEG.event;

    EEG = pop_epoch( EEG, {  '11'  '12'  '13'  '14'  }, [-0.5 4.3], 'newname', 'BDF file epochs', 'epochinfo', 'yes');
    EEG = pop_rmbase( EEG, [-500 0]);
    TT = [];
    for t = 1:length(EEG.epoch)
        if sum(double(cell2mat(EEG.epoch(t).eventbinary)))~=0
            TT = [TT,t];
        end
    end
    EEG_t = pop_select(EEG,'trial',TT);
    EEG_ISI = pop_select(EEG_t,'time',[1.2 4.2]);
    EEG = pop_select( EEG_t,'time',[-0.5 1.3] );
    save([rootfolder procfolder 'Pre\' shortName '.mat'],'EEG','oriEEG_event','TT');
    save([rootfolder procfolder 'ISI\' shortName '.mat'],'EEG_ISI','oriEEG_event','TT');
end
%% Remove trials
clear all;
close all;
eeglab
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
prefolder = 'Pre\';
trialsfolder = 'Trial_rejM1\';
matfiles = dir([rootfolder procfolder prefolder '*.mat']);

    
sub = 6; % Please input index of the participant
v_setfile = matfiles(sub).name; % fill in the file numbers
[a,shortName,c] = fileparts(v_setfile);
load([rootfolder procfolder prefolder v_setfile])
% Manual marking trials
pop_eegplot(EEG,1,1,0);

rejIdx_input = []; % Please input the trial numbers that are considered containing artifacts
save([rootfolder procfolder trialsfolder shortName '.mat'],'rejIdx_input');

%     Automatic rejection
EEG = pop_selectevent( EEG, 'omitepoch',rejIdx_input ,'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG = pop_rmbase( EEG, [-499 0]);
save([rootfolder procfolder 'PreClean_auto\' shortName '.mat'],'EEG','oriEEG_event','TT','rejIdx_input');
  %% Calculate how many of the trials have been deleted
    clear all;
    close all;
    eeglab
    rootfolder = 'G:\RUG\Project_GMD\Labdata\';
    procfolder = 'DataProcessing\EEGAnaz\';
    prefolder = 'Pre\';
    trialsfolder = 'Trial_rejM1\';
    matfiles = dir([rootfolder procfolder prefolder '*.mat']);
    matfiles_rejM1 = dir([rootfolder procfolder trialsfolder '*.mat']);
    pct = zeros(length(matfiles),1);
    total = pct;
    part = pct;
    for sub = 1:length(matfiles);
    v_setfile = matfiles(sub).name; 
    load([rootfolder procfolder prefolder v_setfile])
    total(sub,1) = EEG.trials;
  
    v_setfile_rejM1 = matfiles_rejM1(sub).name; 
    load([rootfolder procfolder trialsfolder v_setfile_rejM1])
    part(sub,1) = size(rejIdx_input,2);
    pct(sub,1) = round(part(sub)/total(sub)*100,2);
    end
%% Run ICA
clear all;
close all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
matfiles = dir([rootfolder procfolder 'PreClean_auto\*.mat']);
files = matfiles;
% sub = 1
for sub = 40%6:length(files)
    v_matfile = files(sub).name; % fill in the file numbers
    [a,shortName,c] = fileparts(v_matfile);
    load([rootfolder procfolder '\PreClean_auto\' v_matfile])
    EEG = pop_reref( EEG, [],'exclude',[33:38] );
    EEG = pop_runica(EEG,'runica');
    save([rootfolder procfolder 'PreCleanICA\' shortName '.mat'],'EEG','oriEEG_event','TT','rejIdx_input');
end
%% Remove some of the components
clear all;close all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
matfiles = dir([rootfolder procfolder  '\PreCleanICA\*.mat']);

% close all;
sub = 1 %4 9 5 % Please input the index of participant
v_matfile = matfiles(sub).name; % fill in the file numbers
[a,shortName,c] = fileparts(v_matfile);
load([rootfolder procfolder 'PreCleanICA\' v_matfile])
eeglab('redraw') 
pop_eegplot( EEG, 1, 1, 0);
pop_eegplot( EEG, 0, 1, 0);
pop_selectcomps(EEG, [1:38] );

%%
nchans = []%[1 2 3]; % Please input the components to be removed
EEG = pop_subcomp( EEG, nchans, 0);
save([rootfolder procfolder 'PreCleanICApost\' shortName '.mat'],'EEG','oriEEG_event','TT','rejIdx_input');%,
% end

%% Trial rejection based on component
clear all;close all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
trialsfolder = 'Trial_rejM2';
matfiles = dir([rootfolder procfolder  '\PreCleanICApost\*.mat']);
sub = 35 %4 9 5
v_matfile = matfiles(sub).name; % fill in the file numbers
[a,shortName,c] = fileparts(v_matfile);
load([rootfolder procfolder 'PreCleanICApost\' v_matfile])
eeglab('redraw')
pop_eegplot( EEG, 0, 1, 0);

rejIdx_input = []; % Please input the trial numbers with are artifact
save([rootfolder procfolder trialsfolder shortName '.mat'],'rejIdx_input');

%     Automatic rejection
%     load([rootfolder procfolder trialsfolder v_setfile ], 'rejIdx_input');
%     EEG = pop_selectevent( EEG, 'omitepoch',rejIdx_input ,'deleteevents','off','deleteepochs','on','invertepochs','off');
% save([rootfolder procfolder 'PreCleanICApost\' shortName '.mat'],'EEG','oriEEG_event','TT','rejIdx_input');%,
%% Revisit the ICA components
clear all;close all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
matfiles = dir([rootfolder procfolder  '\PreCleanICA\*.mat']);
sub = 39; %4 9 5
v_matfile = matfiles(sub).name; % fill in the file numbers
[a,shortName,c] = fileparts(v_matfile);

matfiles_post = dir([rootfolder procfolder  '\PreCleanICApost\*.mat']);
% sub_post = 1 %4 9 5
v_matfile_post = matfiles_post(sub).name; % fill in the file numbers

if strcmp(v_matfile,v_matfile_post)
    ICA = load([rootfolder procfolder 'PreCleanICA\' v_matfile]);
    ICA_post = load([rootfolder procfolder 'PreCleanICApost\' v_matfile_post]);
    winv = round(mean(ICA.EEG.icawinv,1),4);
    postwinv = round(mean(ICA_post.EEG.icawinv,1),4);
    [a,rejComp] = setdiff(winv,postwinv,'stable');
    
    EEG = ICA.EEG;
    eeglab('redraw')
    pop_selectcomps(EEG, [1:max(rejComp)] );
    rejComp
end
% pop_eegplot( EEG, 0, 1, 0);

%% Conditions and trials
clear all;
close all;
rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
setfiles = dir([rootfolder procfolder 'PreCleanICApost\*.mat']);
v_setfiles = setfiles; % fill in the file numbers

% Initialize the waveform of ON/OFF trials
all_ON = zeros(length(v_setfiles),38,767);
all_OFF = all_ON;
all_Go_corr = all_ON;
all_Nogo_corr = all_ON;
all_Go_incorr = all_ON;
all_Nogo_incorr = all_ON;
all_stickness_low = all_ON;
all_stickness_high = all_ON;
all_Relatedstickness_low = all_ON;
all_Relatedstickness_high = all_ON;

nums_on = zeros(length(v_setfiles),1);
nums_off = nums_on;
nums_Go_corr = nums_on;
nums_Nogo_corr = nums_on;
nums_Go_incorr = nums_on;
nums_Nogo_incorr = nums_on;
nums_stickness_low = nums_on;
nums_stickness_high = nums_on;
nums_Relatedstickness_low = nums_on;
nums_Relatedstickness_high = nums_on;

for v = 1:length(v_setfiles)
%     EEG = pop_loadset('filename',v_setfiles(v).name,'filepath',[filefolder 'EEGAnaz\Pre\']);
    [a,shortName,c] = fileparts(v_setfiles(v).name);
    load([rootfolder procfolder 'PreCleanICApost\' v_setfiles(v).name])
    EEG = pop_select( EEG,'time',[-0.2 1.3] );
    EEG = pop_rmbase( EEG, [-199 0]);
%     ch = 16;
    ch = 1:38;
    %% Extract Go/Nogo correct/incorrect condition
%     typeBini = [EEG.epoch(:).eventbini]';
    typeBini = contList(EEG,'epoch','eventbini');

    et_Gocorr = find(typeBini==1);
    et_Goincorr = find(typeBini==2);
    et_Nogocorr = find(typeBini==3);
    et_Nogoincorr = find(typeBini==4);
    
    nums_Go_corr(v) = length(et_Gocorr);
    nums_Go_incorr(v) = length(et_Goincorr);
    nums_Nogo_corr(v) = length(et_Nogocorr);
    nums_Nogo_incorr(v) = length(et_Nogoincorr);
        
    EEG_Go_corr = emptyEEG(EEG,et_Gocorr);
    EEG_Go_incorr = emptyEEG(EEG,et_Goincorr);
    EEG_Nogo_corr = emptyEEG(EEG,et_Nogocorr);
    EEG_Nogo_incorr = emptyEEG(EEG,et_Nogoincorr);

    aveEEG_Go_corr = mean(EEG_Go_corr.data(ch,:,:),3);
    aveEEG_Nogo_corr = mean(EEG_Nogo_corr.data(ch,:,:),3);
    aveEEG_Go_incorr = mean(EEG_Go_incorr.data(ch,:,:),3);
    aveEEG_Nogo_incorr = mean(EEG_Nogo_incorr.data(ch,:,:),3);
    
    all_Go_corr(v,:,:) = aveEEG_Go_corr;
    all_Nogo_corr(v,:,:) = aveEEG_Nogo_corr;
    all_Go_incorr(v,:,:) = aveEEG_Go_incorr;
    all_Nogo_incorr(v,:,:) = aveEEG_Nogo_incorr;
    %% Extract the more and less stickness trials
    typeStickness = contList(EEG,'epoch','eventstickness');
    % 
    et_stickness_low = find(ismember(typeStickness,[81,82,83,84])==1);
    et_stickness_high = find(ismember(typeStickness,[86,87,88,89])==1);
    nums_stickness_low(v) = length(et_stickness_low);
    nums_stickness_high(v) = length(et_stickness_high);
    EEG_stickness_low = emptyEEG(EEG,et_stickness_low);
    EEG_stickness_high = emptyEEG(EEG,et_stickness_high);
    
    % Average ON/OFF trials
    aveEEG_stickness_low = mean(EEG_stickness_low.data(ch,:,:),3);
    aveEEG_stickness_high = mean(EEG_stickness_high.data(ch,:,:),3);
%     aveEEG_ONOFF = mean(EEG_ONOFF.data(ch,:,:),3);
    
    all_stickness_low(v,:,:) = aveEEG_stickness_low;
    all_stickness_high(v,:,:) = aveEEG_stickness_high;
%     all_ONOFF(v,:,:) = aveEEG_ONOFF;
    %% Extract related stickiness 
    % Add the average stickiness for each participant
    ave_Relatedstickness = mean(typeStickness);
    et_Relatedstickness_low = find(typeStickness<ave_Relatedstickness);
    et_Relatedstickness_high = find(typeStickness>ave_Relatedstickness);
    
    nums_Relatedstickness_low(v) = length(et_Relatedstickness_low);
    nums_Relatedstickness_high(v) = length(et_Relatedstickness_high);
    EEG_Relatedstickness_low = emptyEEG(EEG,et_Relatedstickness_low);
    EEG_Relatedstickness_high = emptyEEG(EEG,et_Relatedstickness_high);
    
    % Average ON/OFF trials
    aveEEG_Relatedstickness_low = mean(EEG_Relatedstickness_low.data(ch,:,:),3);
    aveEEG_Relatedstickness_high = mean(EEG_Relatedstickness_high.data(ch,:,:),3);
%     aveEEG_ONOFF = mean(EEG_ONOFF.data(ch,:,:),3);
    
    all_Relatedstickness_low(v,:,:) = aveEEG_Relatedstickness_low;
    all_Relatedstickness_high(v,:,:) = aveEEG_Relatedstickness_high;
    %% Extract On Task and Mind Wandering trials  
    typeContent = contList(EEG,'epoch','eventcontent');
    
    et_on = find(ismember(typeContent,[31,32])==1);
    et_off = find(ismember(typeContent,[33,35])==1);
    nums_on(v) = length(et_on);
    nums_off(v) = length(et_off);
    EEG_ON = emptyEEG(EEG,et_on);
    EEG_OFF = emptyEEG(EEG,et_off);

    EEG_ONOFF = emptyEEG(EEG,[et_on; et_off]);
    
    % Average ON/OFF trials
    aveEEG_ON = mean(EEG_ON.data(ch,:,:),3);
    aveEEG_OFF = mean(EEG_OFF.data(ch,:,:),3);
    aveEEG_ONOFF = mean(EEG_ONOFF.data(ch,:,:),3);
    
    all_ON(v,:,:) = aveEEG_ON;
    all_OFF(v,:,:) = aveEEG_OFF;
    all_ONOFF(v,:,:) = aveEEG_ONOFF;
    save([rootfolder procfolder 'PreCleanICApostAve\' shortName '.mat'],'EEG_ON','EEG_OFF','EEG_Go_corr','EEG_Go_incorr','EEG_Nogo_corr','EEG_Nogo_incorr','EEG_stickness_low','EEG_stickness_high','EEG_Relatedstickness_low','EEG_Relatedstickness_high');
%     if exist('EEG2')
%         save([filefolder 'EEGAnaz_eventOpt\PreCleanICApostISI\' shortName '.mat'],'EEG2','et_on','et_off','et_Gocorr','et_Goincorr','et_Nogocorr','et_Nogoincorr');
%     end
end 
save([rootfolder procfolder 'all_total_RelatedStickiness.mat'],'all_ON','all_OFF','all_ONOFF','all_Go_corr','all_Nogo_corr','all_Go_incorr','all_Nogo_incorr','all_stickness_low','all_stickness_high','all_Relatedstickness_low','all_Relatedstickness_high' ...
   , 'nums_on','nums_off','nums_Go_corr','nums_Go_incorr','nums_Nogo_corr','nums_Nogo_incorr','all_Go_incorr','all_Nogo_incorr','nums_stickness_low','nums_stickness_high','nums_Relatedstickness_low','nums_Relatedstickness_high');
