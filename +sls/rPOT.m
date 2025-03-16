function varargout = rPOT(times, var, return_level, sw, thresh_cross_del)
% rPOT - gains peaks over threshold (POT) values, using 'R largest' method: 
%        sorting values largest to smallest and then using a 'storm window'
%        to delete surrounding values. option to delete values from large consecutive 
%        groups above the return level/threshold
%
% Inputs:
%   var - data for the calculation
%   times - times of the data
%   return_level - return level/s from which to calculate POT
%                  if more than one, data > than the smallest value is used
%   sw - number of hours to delete around the large value, e.g., sw = 32 
%        would be 16 hours either side deleted (storm window)
%   thresh_cross_del - 'y' or (default) 'n' on whether to apply the threshold crossing deletion 
%                       from thresh_cross_del.m, the same return level is used as above  
%
% Outputs:
%   Rover - table of times and values ('descending' by value size) that have exceeded the minimum return level and data that is 's' hours 
%           around that value has been deleted 
%   time_between - table of time between each rPOT event (in datenum) and the associated dates of the second event in each rolling pair
%                  of exceedances that are > than the minimum return level given
%   var_tcd - variable with threshold crossed group data deleted bar the max values, when thresh_cross_del is set to 'y'

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    times (:, 1) datetime
    var (:, 1) double {mustBeNumeric}
    return_level (:, 1) double {mustBeNumeric}
    sw (1, 1) double {mustBeNumeric, mustBeNonnegative}
    thresh_cross_del char {mustBeMember(thresh_cross_del, {'y', 'n'})} = 'n' 
end

if thresh_cross_del == 'y'
    var = sls.thresh_cross_del(var, min(return_level, [], 'all'));
end

i = find(var > min(return_level, [], 'all'));
if isempty(i)
    error("No values above minimum return level given.")
end
Rover = var(i); times = times(i); 
[Rover, i] = sortrows(Rover, 'descend');
times = times(i);
for i = 1:length(Rover) + 1
    j = times >= times(i) - hours(sw / 2) &  ...
            times <= times(i) + hours(sw / 2);
    j(i) = 0;
    Rover(j) = [];
    times(j) = [];
    if i == length(Rover)
        break
    end
end
Rover = table(times, Rover);
varargout{1} = Rover;
if nargout >= 2
    dates = sort(Rover{:, 1}, 'ascend');
    if length(dates) == 1
        warning('Only one exceedance - cannot do time between, output becomes nan')
        varargout{2} = nan;
    else
        time_between = table(dates(2:end), diff(sort(datenum(Rover{:, 1}), 'ascend')), ...
            'VariableNames', {'dates', 'time between'});
        varargout{2} = time_between;
    end
end

if thresh_cross_del ~= 'y' && nargout == 3
    error("'var_tcd' (third) output only returns when thresh_cross_del is set to 'y'")
else
    varargout{3} = var;
end

% fini