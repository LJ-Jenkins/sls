function [npt] = POT_counts(input, return_level, timeperiod, out_format)
% POT_counts - counts peaks over threshold (POT) values, per specified time period,
%              highly recommended to apply declustering beforehand (e.g., sls.rPOT)
%
% Inputs:
%   input - either a:
%                   {1,2} cell array containing a POT table of data for the calculation {1} (:,1) times (datetime), (:,2) variable (double)
%                    and a datetime array {2} of all the times of the timeseries;
%                    or a table of the full timeseries (recommended to decluster prior), (:,1) times (datetime), (:,2) variable (double)
%   return_level - return level/s from which to calculate POT
%   timeperiod - time period to be used, 'NA storm season' for the North Atlantic winter storm
%                season annual period: 1st July - 31st June, 'seasonally' for DJF-MAM-JJA-SON,
%                or retime()'s newTimeStep inputs: 'yearly','quarterly','monthly','weekly','daily', or 'hourly'
%   out_format - 'totals' for total above each threshold, or 'relative' (default) for relative totals (totals in each 'band' of
%                 return level: e.g., for 4 return levels, between rl1 and rl2, rl2 and rl3, > rl4 etc.)
%
% Outputs:
%   npt - timetable of time period and counts above each return level/s, either total above each threshold or the 
%         relative amount in each band

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    input
    return_level (:, 1) double {mustBeNumeric}
    timeperiod char {mustBeMember(timeperiod, {'NA storm season', 'seasonally', ...
        'yearly', 'quarterly', 'monthly', 'weekly', 'daily', 'hourly'})} = 'NA storm season'
    out_format char {mustBeMember(out_format, {'totals', 'relative'})} = 'relative'
end

return_level = sort(return_level, 'ascend');
npt = cell(1, length(return_level));
sedate = datetime.empty(0, 2);
if iscell(input)
    td = [input{1, 2}(1) input{1, 2}(end)];
    input{1, 1} = table2timetable(input{1, 1});
elseif istable(input)
    td = [input{1, 1} input{end, 1}];
    input = {table2timetable(input)};
end
switch timeperiod
case 'NA storm season'
    for i = 1:2
        pdates = [datetime(year(td(i)) - 1, 7, 1) datetime(year(td(i)), 7, 1) datetime(year(td(i)) + 1, 7, 1)]; % possible start/end dates
        [~, mi] = min(abs(pdates - td(i))); % find nearest
        sedate(i) = pdates(mi);
    end
    timeperiod = sedate(1):calyears(1):sedate(2);
case 'seasonally'
    for i = 1:2
        pdates = [datetime(year(td(i)) - 1, 12, 1) datetime(year(td(i)), 3, 1) datetime(year(td(i)), 6, 1) ...
            datetime(year(td(i)), 9, 1) datetime(year(td(i)), 12, 1) datetime(year(td(i)) + 1, 3, 1)]; % possible start/end dates
        [~, mi] = min(abs(pdates - td(i))); % find nearest
        sedate(i) = pdates(mi);
    end
    timeperiod = sedate(1):calmonths(3):sedate(2);
otherwise
    if length(input) ~= 1
        input{1, 1} = retime(input{1, 1}, input{1, 2});
    end
end
for i = 1:length(return_level)
    input{1, 1}{input{1, 1}{:, 1} <= return_level(i), 1} = nan;
    if length(return_level) ~= 1 && i ~= length(return_level) && strcmpi(out_format, 'relative')
        tmp(1) = input(1, 1);
        tmp{1, 1}{tmp{1, 1}{:, 1} > return_level(i + 1), 1} = nan;
        npt{1, i} = retime(tmp{1, 1}, timeperiod, 'count');
    else
        npt{1, i} = retime(input{1, 1}, timeperiod, 'count');
    end
    npt{1, i}.Properties.VariableNames = "RL " + string(i) + ": " + string(return_level(i)) + " count";
end
npt = horzcat(npt{:});
if length(string(return_level)) ~= length(unique(string(return_level)))
    warning("Some return levels in column names will appear the same due to string() rounding.")
end

% fini