function [timeabv] = time_above_thresh(times, var, threshold, ignore_timestep, option, nv)
% time_above_thresh -  calculates time above threshold in hours with multiple options/methods.
%                      presumes changes in timestep occur only due to an updated
%                      temporal resolution and are in continuous blocks (will
%                      be erroneous if this is not the case)
%
% Inputs:
%   var - data for the calculation (should be surge)
%   times - times of the data
%   threshold - threshold for calculation of time above
%   ignore_timestep - 24 (default): timestep in hours for which to ignore 
%                     in calculation (e.g., for gappy data and missing data
%                     causing irregular timestep)
%   option - 'mean', 'max' ,'median', 'mode', 'gps' (default), 'total'
%             or the Xth percentile e.g., 95 for 95th percentile.
%             'gps': is group summary, aka mean, median, mode and max.
%             values are rounded to nearest whole integer
% -name-value arguments-
%   'round' - round values or not 'y' or (default) 'n'
%
% Outputs:
%   timeabv - time above thresh calculated from the aggregated consecutive time above a threshold
%             rounded to nearest whole hour (unless 'gps')

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    times (:, 1) datetime
    var (:, 1) double {mustBeNumeric}
    threshold (1, 1) double {mustBeNumeric}
    ignore_timestep (1, 1) double {mustBeNumeric} = 24
    option = 'gps'
    nv.round char {mustBeMember(nv.round, {'y', 'n'})} = 'n'
end

var(var <= threshold) = nan; 
if ~isrow(var), var = var'; end

if isregular(times)
    d = diff([false, ~isnan(var), false]); % get consecutive groups
    l = find(d < 0) - find(d > 0); % lengths of consecutive groups
    ts = hours(times(2) - times(1)); % get timestep
    l = l * ts; % convert to hours
else
    dt = hours(diff(times)); % create array of time interval in hours
    dt = [hours(times(2) - times(1)); dt]; % add back first
    dt(isnan(var)) = 0;
    dt(dt > ignore_timestep) = 0;
    groups = regionprops(dt ~= 0, dt, 'Area', 'PixelValues'); % get groups of non-0
    l = nan([1, height(groups)]);
    for i = 1:height(groups)
        l(i) = sum(groups(i).PixelValues); % sum each group
    end
end
%%
% options
if strcmpi(option, 'mean')
    timeabv = mean(l, 'all');
elseif strcmpi(option, 'median')
    timeabv = median(l, 'all');
elseif strcmpi(option, 'mode')
    timeabv = mode(l, 'all');
elseif strcmpi(option, 'max')
    timeabv = max(l, [], 'all');
elseif isnumeric(option)
    timeabv = prctile(l, option, 'all');
elseif strcmpi(option, 'total')
    timeabv = sum(l);
elseif strcmpi(option, 'gps')
    timeabv.mean = mean(l, 'all');
    timeabv.median = median(l, 'all');
    timeabv.mode = mode(l, 'all');
    timeabv.max = max(l, [], 'all');
end
if nv.round == 'y'
    if ~strcmpi(option, 'gps')
        timeabv = round(timeabv);
    else
        timeabv.mean = round(timeabv.mean);
        timeabv.median = round(timeabv.median);
        timeabv.mode = round(timeabv.mode);
        timeabv.max = round(timeabv.max);
    end
end

% fini

% Checking code for largest periods
%     x = dt';
%     zpos = find(~[0 x 0]);
%     [~, grpidx] = max(diff(zpos));
%     y0 = x(zpos(grpidx):zpos(grpidx+1)-2);
%     y1 = times(zpos(grpidx):zpos(grpidx+1)-2);
%     y2 = var(zpos(grpidx):zpos(grpidx+1)-2);
%     max(max(cellfun(@length,struct2cell(groups))))