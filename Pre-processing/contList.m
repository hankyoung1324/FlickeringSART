function typeContent = contList(EEG,list, eventcontent)
% Extract event in the epoch
%     list = 'epoch';
%     eventcontent = 'eventcontent';
    typeContent = [];
    eval(['typeContent = zeros(length(EEG.' list '),1);']);
    for t = 1:length(eval(['EEG.' list]))
        eval(['contents = EEG.' list '(t).' eventcontent ';']);
        if length(contents)>=2
%             temp = cell2mat(contents(cell2mat(contents)>0));
            temp = contents(contents>0);
        else
%             temp = cell2mat(contents);
            temp = contents;
        end
        if isempty(temp)
            typeContent(t) = 0;
        elseif ~isempty(temp)
            typeContent(t) = unique(temp);
        end
    end
end

