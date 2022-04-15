function [Wst, tlag, scale] = compute_Wst(data,times,srate,plotOn)
% [Wst, tlag, scale] = compute_Wst(data, times, *srate = [autoCompute], *plotOn = 0)
% data/times: nPnt; same size
% times: ms

if ~isequal(size(data),size(times))
    error('Data and times must be the same size!')
end

% default
if nargin < 4 || isempty(plotOn)
    plotOn = 0;
end

if nargin < 3 || isempty(srate)
    srate = computeSrate(times);
end

% pars
tlag = 1:1000/srate:1000;
scale = 1:1000/srate:3500;

% intialize
Wst = zeros(length(scale),length(tlag));

% loop over t/s combo
for ti = 1:length(tlag)
    t = tlag(ti);
    for si = 1:length(scale)
        s = scale(si);
        wavelet = mexican_hat(times,t,s);
        %Wst(si, ti) = trapz(data.*wavelet).* (1000/srate) ./sqrt(s);
        Wst(si,ti) = sum(data .* wavelet)./sqrt(s);
    end
end

% plot
if plotOn == 1
    figure
    imagesc(tlag,scale,Wst)
    set(gca,'YDir','normal')
    %caxis([-50 50])
    ylabel('Scale (ms)')
    xlabel('Time lag (ms)')
    colorbar
end
        

end % func