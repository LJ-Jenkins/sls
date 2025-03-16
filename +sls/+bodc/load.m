function [t, varargout] = load(sitecode, directory, datum, nv)
% bodc.load - loads all BODC tide gauge files in a directory
%
% Inputs:
%   sitecode - BODC three letter sitecode, does not use files without this 
%              code in the filename (case sensitive)
%   directory - where the BODC text files are stored (must have original names
%               and therefore be in date order)
%   datum - 'cd' or (default) 'od': chart or ordnance datum
% -name-value arguments-
%   'dispfile' - (default) 'n' or 'y' to show file currently being loaded
%
% Outputs:
%   t - table of all variables and times
% Optional (in order):
%   1st - times (datetime)
%   2nd - water levels (m)
%   3rd - flags from water levels
%   4th - residuals (m)
%   5th - flags from residuals

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    sitecode string {mustBeTextScalar}
    directory string {mustBeTextScalar}
    datum string {mustBeMember(datum, {'od', 'cd'})} = "od"
    nv.dispfile char {mustBeMember(nv.dispfile, {'y', 'n'})} = 'n'
end

if ~endsWith(directory, ["\", "/"]) && contains(directory, "\")
    directory = directory + "\";
elseif ~endsWith(directory, ["\", "/"]) && contains(directory, "/")
    directory = directory + "/";
end

%% File arrangement
files = string(extractfield(dir(fullfile(directory, '*.txt')), 'name'));
files = files(contains(files, sitecode));

%% Preallocate
t = table('Size', [0, 5], 'VariableTypes', ["datetime", repmat(["double", "string"], 1, 2)], ...
        'VariableNames', ["time", "water level (cd) (m)", "wl flags", "residual (m)", "rs flags"]);

%% Loop
for i = 1:length(files)
    if nv.dispfile == 'y'
        disp(files(i))
    end
    filein = fullfile(directory, files(i));
    % read in variable names line and get variable widths
    f = fopen(filein);
    widths = textscan(f, '%s', 1, 'delimiter', '\n', 'headerlines', 10);
    fclose(f);
    widths = [' ' char(widths{:})];
    [si, ei] = regexp(widths, ["Number", "ss", "\sf"], 'start', 'end');
    vwidths = [ei{1} ei{2} - ei{1} si{3}(1) - ei{2} ei{3}(1) - si{3}(1) si{3}(2) - ei{3}(1) ei{3}(2) - si{3}(2)];
    opts = fixedWidthImportOptions('NumVariables', 6, 'DataLines', 12, 'VariableNames', ...
        ["n", "time", "water level (cd) (m)", "wl flags", "residual (m)", "rs flags"], 'VariableWidths', vwidths, ...
        'VariableTypes', ["char", "datetime", "double", "string", "double", "string"], ...
        'VariableNamingRule', 'preserve');
    opts = setvaropts(opts, "time", 'InputFormat', 'yyyy/MM/dd HH:mm:ss');
    opts.SelectedVariableNames = 2:6;
    % load, extract and append
    T = readtable(filein, opts);
    if width(T) > 5 % code adds extra column if change in position break within the data
        T.(6) = [];
    end
    t = [t; T];
end
t(isnat(t{:, 1}), :) = [];
if ~issorted(t.time) %-- if times are not sorted
    t = sortrows(t);
end
if length(t.time) ~= length(unique(t.time)) %-- if times are not unique
    tt = table2timetable(t);
    tt.("water level (cd) (m)")(isnan(tt.("water level (cd) (m)"))) = inf;
    tt.("wl flags")(ismissing(tt.("wl flags"))) = inf;
    tt.("residual (m)")(isnan(tt.("residual (m)"))) = inf;
    tt.("rs flags")(ismissing(tt.("rs flags"))) = inf;
    [utt] = unique(tt);
    utt.("water level (cd) (m)")(isinf(utt.("water level (cd) (m)"))) = nan;
    utt.("wl flags")(strcmpi(utt.("wl flags"), 'inf')) = nan;
    utt.("residual (m)")(isinf(utt.("residual (m)"))) = nan;
    utt.("rs flags")(strcmpi(utt.("rs flags"), 'inf')) = nan;
    if length(utt.time) ~= length(unique(utt.time)) %-- if times are still not unique (duplicate times with non-duplicate values)
        dt = unique(utt.time((diff(sort(utt.time)) == 0))); %-- get dup times
        nt = timetable('Size', [length(dt), length(utt.Properties.VariableNames)], ...
            'VariableTypes', repmat(["double", "string"], 1, 2), 'rowTimes', dt, ...
            'VariableNames', utt.Properties.VariableNames); %-- preallocate using original timetable
        for i = 1:length(dt)
            tmp = utt(utt.time == dt(i), :); %-- data at dup time
            utt(utt.time == dt(i), :) = []; %-- delete that data
            [~, j] = min(sum(ismissing(tmp{:, :}), 2)); %-- get time with most non missing data
            nt(i, :) = tmp(j(1), :); %-- add back in, (1) for either the single row output, or if multiple, just pick first
        end
        utt = sortrows([utt; nt]);
    end
    t = timetable2table(utt);
end
if strcmpi(datum, 'od') 
    [~, ~, ~, od] = sls.bodc.tide_gauge_info(sitecode);
    t.(2)(t.(2) ~= -99) = t.(2)(t.(2) ~= -99) + od;
    t.Properties.VariableNames(2) = "water level (od) (m)";
end

if nargout > 1
    varargout = cell(nargout - 1, 1);
    for k = 2:nargout
        varargout{k - 1} = t.(k - 1);
    end
end

% fini