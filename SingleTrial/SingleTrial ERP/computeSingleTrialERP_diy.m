function [measure,f_output,chan,sub] = computeSingleTrialERP_diy(erp, v_setfiles, plotOn, EEGs, f_output)
% Compute W matrix and do local peak search to find the single trial ERP of interest. 
% Outputs are based on invididuals x conditions x tasks. 
% Note: the W in output file is integrated in the unit of sampling points to save computing time; the real W should be adjusted by W * 1000/srate.

rootfolder = 'G:\RUG\Project_GMD\Labdata\';
procfolder = 'DataProcessing\EEGAnaz\';
exportfolder = 'Export\';

load([rootfolder 'Codes\pars_markers.mat']);
id = find(strcmp({erps.name}, erp));
measure = erps(id).name;
x2searchLower = erps(id).x2searchLower; 
x2searchUpper = erps(id).x2searchUpper; 
yRng2search   = erps(id).yRng2search;
sign  = erps(id).sign;
chans = erps(id).chans;
boundaryType  = erps(id).boundaryType; % 'float': [xLower RT]; 'fixed': [xLower xUpper]; 'adjusted': [xLower RT-->xUpper]
i = 0;

       
for sub = 3%:length(v_setfiles)
    strs = strsplit(v_setfiles(sub).name,'_');
    strs_sub = char(strs(1));
    load([rootfolder procfolder 'PreCleanICApostAve\' v_setfiles(sub).name])
    for n = 1:length(EEGs)
%         n = 1;
%         testEEG = EEGdata(n);
        testEEG = eval(cell2sym(EEGs(n)));
        data = testEEG.data;
        mat = zeros(size(data,3),3); % colnames: s1Idx, s2Idx, val, t, s
        times = testEEG.times;
        srate = testEEG.srate;
        for chan = chans
            for ni = 1:size(data,3) % loop over trial
                fprintf(['ST running for trial ' num2str(ni) ' EEGs ' char(EEGs(n)) ', channel ' num2str(chan) ' for subject ' strs_sub '\n'])
                trial = data(chan,:,ni);
                xRng2search = [x2searchLower, x2searchUpper];
                if ni == 1
                    [W, xRng, yRng] = compute_Wst(trial,times,srate,plotOn);
                else
                    W = compute_Wst(trial,times,srate,plotOn);
                end
                [mat(ni,1), mat(ni,2), mat(ni,3)] = local_peak(W, xRng, yRng, xRng2search, yRng2search, sign, plotOn);
                if plotOn == 1
                    figure
                    imagesc(xRng,yRng,W)
                    set(gca,'YDir','normal')
                    caxis([-50 50])
                    hold on 
                    x1 = xRng2search(1); y1 = yRng2search(1); x2 = xRng2search(end); y2 = yRng2search(end);
                    x = [x1, x2, x2, x1, x1];
                    y = [y1, y1, y2, y2, y1];
                    plot(x, y, 'k:', 'Color',[0.25 0.25 0.25], 'LineWidth', 2);
                    if isempty(mat(ni,1)) == 0
                        hold on
                        plot(mat(ni,2), mat(ni,3), '--ks','MarkerSize',5,'MarkerFaceColor','k');
                        hold on
                        text(mat(ni,2)+10, mat(ni,3), num2str(mat(ni,1)));
                    end
%                     title(['Session ', num2str(session), ', trial ', num2str(id)])
                end
            end  % ni
            
            %% output
%             varName = [measure '_' strs_sub '_' char(EEGs(n)) '_chan', num2str(chan)];
%             subfolder = [rootfolder procfolder f_output '\', measure, ' chan', num2str(chan)];
%             file = [subfolder '\' strs_sub '_' char(EEGs(n)) '.mat'];
%             eval([varName,'= mat;'])
%             if exist(subfolder) ~= 7
%                 mkdir(subfolder)
%             end
%             
%             if exist(file,'file') == 2
%                 save(file, varName, '-append')
%             else
%                 save(file, varName)
%             end
            file = char(join([strs_sub '_' measure '_chan', num2str(chan) '_' char(EEGs(n)) '.mat']));
            file= file(~isspace(file));
            save([rootfolder procfolder f_output '\' file],'mat')
        end % chan
    end % EEGs    
end  % sub
       

end
