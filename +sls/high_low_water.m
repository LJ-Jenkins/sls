function varargout = high_low_water(times, var, nv)
% high_low_water - calculates the high and low waters from given water level or tide data.
%                  Two method options, 'region' (default) gets all groups above/below the mean and
%                  calculates the min or max of each group with options for ties (recommended).
%                  'peaks' uses the findpeaks() function and has an option for minimum peak
%                  separation distance but no option for ties.
%                  
% Inputs:
%   times - times of the data
%   var - water levels or tidal levels
% -name-value arguments-
%   'method' - (default) 'region' or 'peaks' for either method using regionprops() or findpeaks()
%   'ties' - 'first', (default) 'middle', or 'last' to select which max/min value in
%             the case of ties (only for 'region' method)
%   'minsep' - minimum number of intervals between peaks (only for 'peaks' method)
%   'crossingVal' - crossing value for the identification of high/low water peaks in the tide
%
% Outputs (in order):
%   1st - hw table of (:, 1) times of high waters and (:, 2) high water/tidal levels
%   2nd - lw table of (:, 1) times of low waters and (:, 2) low water/tidal levels

% Luke Jenkins May 2023 
% L.Jenkins@soton.ac.uk

arguments
    times (:, 1) datetime
    var (:, 1) double
    nv.method char {mustBeMember(nv.method, {'region', 'peaks'})} = 'region'
    nv.ties char {mustBeMember(nv.ties, {'first', 'middle', 'last'})} = 'middle'
    nv.minsep (1, 1) double {mustBePositive}
    nv.crossingVal (1, 1) double = mean(var, 'all', 'omitnan')
end

if strcmp(nv.method, 'region')
    % get max of high periods (aka high waters)
    hws = regionprops(var > nv.crossingVal, var, 'Area', 'PixelValues');
    hwts = times(var > nv.crossingVal);
    [hw, hwi] = arrayfun(@(x) grouplog(x.PixelValues, 'max', nv), hws, 'UniformOutput', false);
    hw = vertcat(hw{:});
    hwts = hwts(vertcat(hwi{:}));
    % get min of low periods (aka low waters)
    lws = regionprops(var <= nv.crossingVal, var, 'Area', 'PixelValues');
    lwts = times(var <= nv.crossingVal);
    [lw, lwi] = arrayfun(@(x) grouplog(x.PixelValues, 'min', nv), lws, 'UniformOutput', false);
    lw = vertcat(lw{:});
    lwts = lwts(vertcat(lwi{:}));
elseif strcmp(nv.method, 'peaks')
    [hw, pix] = findpeaks(wl, 'MinPeakDistance', nv.minsep);
    hwts = times(pix);
    [lw, pix] = findpeaks(-wl, 'MinPeakDistance', nv.minsep);
    lw = -lw;
    lwts = times(pix);
end
hw = table(hwts, hw, 'VariableNames', ["time", "high water"]);
lw = table(lwts, lw, 'VariableNames', ["time", "low water"]);
varargout = {hw, lw};
end

% fini

function [m, l] = grouplog(a, min_max, nv)
    if strcmp(min_max, 'max')
        m = max(a, [], 'omitnan');
    else
        m = min(a, [], 'omitnan');
    end
    li = a == m;
    if sum(li == 1) > 1
        if strcmp(nv.ties, 'middle')
            l = false(length(li), 1);
            f = find(li == 1);
            if rem(length(f), 2) == 1; q = .5; else q = 0; end
            l(f(length(f) / 2 + q)) = 1;
        else
            l = false(length(li), 1);
            l(find(li == 1, 1, nv.ties)) = 1;
        end
    else
        l = li;
    end
end

% fini fini