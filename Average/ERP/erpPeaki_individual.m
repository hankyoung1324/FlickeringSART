function [ampPeak,latPeak] = erpPeaki_individual(all_ON,EEG,rm_part_State,erps,i)
            chan = erps.chans(i,:);
            twind = erps.wind(i,:);
%             all_ON = eval(cell2sym(str_all_ON));
            all_ON_select = all_ON(setdiff(1:40,rm_part_State),chan,:);

            [,indWin] = find(EEG.times>=twind(1) & EEG.times<=twind(2));
%             ave_ON = squeeze(all_ON_select,1);
            win_ON = all_ON_select(:,:,indWin);
            polarity = erps.polar{i};
            if polarity =='positive'
                [ampPeak,b] = max(win_ON,[],3);
            elseif polarity == 'negative'
                [ampPeak,b] = min(win_ON,[],3);
            end
            indPeak = b + min(indWin)-1;
            latPeak = EEG.times(indPeak);
end

