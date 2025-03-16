function varargout = time_between_exceedance_groups(var, threshold, times)
% time_between_exceedance_groups - for every group of consecutive values over a threshold, get the time between each group
%
% Inputs:
%   var - data for the calculation
%   threshold - threshold to calculate groups from
%   times - times (datetime) of the data for calculation of time between
%
% Outputs (in order):
%   1st - calendarDuration array of times between exceedance groups
%   2nd - numeric double array of datenum of times between exceedance groups
%   3rd - right edge of every gap between exceedances

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    var (:, 1) double 
    threshold (:, 1) double
    times (:, 1) datetime
end

groups = regionprops(var > threshold,var, 'Area', 'PixelValues'); % get groups of above threshold
if height(groups) < 2
    error("Less than 2 groups of exceedances")
end
j = find(var > threshold); % indices
idx = 0;
time_between = calendarDuration.empty(height(groups) - 1, 0);
ntime_between = nan(height(groups) - 1, 1);
eg_times = datetime.empty(height(groups) - 1, 0);
for i = 2:height(groups)
    idx = idx + groups(i - 1).Area;
    time_between(i - 1, 1) = between(times(j(idx)), times(j(idx + 1)));
    ntime_between(i - 1, 1) = datenum(times(j(idx + 1)) - times(j(idx)));
    eg_times(i - 1, 1) = times(j(idx + 1));
end
varargout = {time_between, ntime_between, eg_times};

% fini