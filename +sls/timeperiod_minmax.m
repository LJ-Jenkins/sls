function t = timeperiod_minmax(minormax, timeperiod, times, var)
% timeperiod_minmax - table of minimum and/or maximum values and their associated times 
%                     in relation to a specified grouping time period. Can
%                     accept numerous datetime arrays and their variables
%                     and will aggregate all onto one table
%
% Inputs:
%   minormax - 'min', 'max' or 'both'
%   timeperiod - 'monthly', 'yearly' or 'seasonally' (DJF, MAM, JJA, SON)
% -repeating arguments-
%   times - times in datetime of the variable
%   var - variable data of type double
%
% Outputs (in order):
%   t - table of minimums and/or maximums, their times, and the corresponding time period

% Luke Jenkins May 2023
% L.Jenkins@soton.ac.uk

arguments
    minormax char {mustBeMember(minormax, {'min', 'max', 'both'})}
    timeperiod char {mustBeMember(timeperiod, {'monthly', 'yearly', 'seasonally'})}
end

arguments (Repeating)
    times (:, 1) datetime
    var (:, 1) double
end

all_t = sortrows(vertcat(times{:}));
group = year(all_t(1)):1:year(all_t(end));
switch timeperiod
    case 'yearly'
        group = group';
        f = @(x) year(x);
    case 'monthly'
        mnths = repmat((1:12)', 1, length(group));
        group = reshape(string(group) + mnths, [numel(mnths), 1]);
        f = @(x) string(year(x)) + month(x);
    case 'seasonally'
        mnths = mnth2season(repmat((1:12)', 1, length(group)));
        group = reshape(group + mnths, [numel(mnths), 1]);
        f = @(x) year(x) + mnth2season(month(x));
end
t = table(group, 'VariableNames', "Time Period");
for i = 1:width(times)
    a = table(times{1, i});
    a.Var2 = var{1, i};
    a.("Time Period") = f(a.Var1);
    if strcmpi(minormax, 'both')
        minormax = ["min", "max"];
    end
    for mm = string(minormax)
        if strcmpi(mm, 'max')
            out = groupfilter(a, "Time Period", @(x) x == max(x), 'Var2');
        elseif strcmpi(mm, 'min')
            out = groupfilter(a, "Time Period", @(x) x == min(x), 'Var2');
        end
        out.Properties.VariableNames(1:2) = ["Time of " + mm + " " + i, mm + " " + i];
        t = outerjoin(t, out, 'Keys', "Time Period", 'MergeKeys', true);
    end
end
if strcmpi(timeperiod, 'monthly')
    t.("Time Period") = str2double(t.("Time Period"));
    t = sortrows(t, "Time Period");
end
end

% fini

function c = mnth2season(month_array)
    c = string(month_array);
    c(ismember(c, ["12", "1", "2"])) = "DJF";
    c(ismember(c, ["3", "4", "5"])) = "MAM";
    c(ismember(c, ["6", "7", "8"])) = "JJA";
    c(ismember(c, ["9", "10", "11"])) = "SON";
end

% fini fini