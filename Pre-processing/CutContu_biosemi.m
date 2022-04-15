function [EEG] = CutContu_biosemi( EEG,StartMarker,EndMarker )
%Cut continuous eeg data using given start marker and end marker
%   Please make sure the marker is unique in the whole dataset
% StartMarker = 90;
% EndMarker = 99;
% AllEvents={};
% AllEvents=cell(length(EEG.event),1);
AllEvents=[];
AllEvents=zeros(length(EEG.event),1);
for i=1:length(EEG.event)
    AllEvents(i,1)=EEG.event(i).type;
end
% Start=strcmp(StartMarker,AllEvents);
% [a,b]=find(Start==1);
[aa,b] = find(AllEvents == StartMarker);
if isempty(aa)
    StartTime = EEG.times(EEG.event(1).latency)/1000;
elseif ~isempty(aa)
    StartTime=EEG.times(EEG.event(aa(1)).latency)/1000; % The first startMarker 
end
% End=strcmp(EndMarker,AllEvents);
% [c,d]=find(End==1);
[cc,d] = find(AllEvents == EndMarker);
if isempty(cc)
    EndTime = EEG.times(EEG.event(end).latency)/1000;
elseif ~isempty(cc)
    EndTime=EEG.times(EEG.event(cc(end)).latency)/1000;    % convert milisecond to second % The last end Marker
timerange=linspace(StartTime,EndTime,2);
EEG = pop_select( EEG,'time',timerange ); % in second

end

