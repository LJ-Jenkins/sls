function sk = skew_surge(wl_times, wl, t_times, tide, s_tide, nv)
% skew_surge - calculates skew surge by using the high waters of a sinusoidal tidal curve and calculating the difference in tidal (predicted) high water and the actual high water around
%              each sinusoidal peak. Also attains other associated parameters (time to predicted high water from skew, time of predicted tidal high water, predicted tidal high water, time of actual
%              high water and actual high water), with nan 'flags' (percentage of nans in window, timestep of prior value -> actual high water, time to nearest non-nan before hw and time
%              to nearest non-nan after hw). Two method options 'split' and 'retime', with 'split' preferred (even for regular timeseries, see below), as well as options for the window size 
%              around high water, ties, the number of nan-flag columns, and to replace the times with shifted regular times. Regular times should be used if you want to use the faster 'split' 
%              method but have wl and tide times that are *very* irregular, for example with clock drift or sampling error. In these cases of 'regular irregularity', e.g. every n timesteps has :29 
%              minutes instead of :30, it is recommended to shift the times to a (more) regular interval and input as 'RegularTimes' ato prevent errors. The original timeseries will still be used 
%              for the skew surge timing etc. Note: if using a higher resolution tidal reconstruction dataset, do consider that parameters such as time to predicted high water will be have some 
%              level of bias from the resolution difference.
%
% Inputs:
%   wl_times - times of the water level data
%   wl - water levels
%   t_times - times of the predicted tide data
%   tide - predicted tide
%   s_tide - simple sinusodial tide (use sls.calc_tide with 'ncnstits' option)
% -name-value arguments-
%   'method' - (default) 'split' or 'retime' method. 'split' splits the water levels timeseries into ordered separate arrays containing groups of similar timesteps,
%              meaning in theory that this could cause the loss of *minimal* data where lots of jumps occur, whereas 'retime' places all water level data onto the tidal times -
%              which means no data loss occurs. However, it also means the water level times MUST be present in the tidal times. 'retime' is much slower to run and because the
%              data loss is so minimal, 'split' is default and preferred for virtually all timeseries. For example, Aberdeen tide gauge had >6 gaps/changing timesteps and a 
%              size of 1414176x1 and only lost a single data point.
%   'ties' - 'first', (default) 'middle', or 'last' to select which max value in the case of ties
%   'window' - number of hours (default: 6) around the sinusodial tidal high water from which to calculate tidal/water level high waters (e.e, 6 for 3 hours either side)
%   'nanflag' - 'perc' or (default) 'all' to select whether you want just the percentage nan flag column in output or the nearest non nans to high
%               water as well - nearest nan is most time consuming aspect of script (+~10 seconds when testing on a UK tide gauge) and less useful
%               than perc nan flag column but it's recommended to use both in conjunction (these columns are not actual flags but just the information
%               needed to make educated decisions on the removal of suspect data)
%   'RegularTimes' - datetime array of times that have been converted to (more) regular intervals in the case of clock drift, very irregular sampling
%                    or sampling timing error (for more info. see function description)
%   'crossingval' - crossing value (default does the mean) for the identification of high water peaks in the sine tide 
%
% Outputs:
%   sk - table of skew surge, time to predicted high water, time of predicted tidal high water,
%        predicted tidal high water, time of actual high water, actual high water, percentage of
%        nan values in window around sinusodial tide high water analysed, shortest amount of time
%        from actual (wl) high water to a non-nan water level data point prior to high water and after high water

% Luke Jenkins May 2023
% L.Jenkins@soton.ac.uk

arguments
    wl_times (:, 1) datetime
    wl (:, 1) double
    t_times (:, 1) datetime
    tide (:, 1) double
    s_tide (:, 1) double
    nv.method char {mustBeMember(nv.method, {'retime', 'split'})} = 'split'
    nv.ties char {mustBeMember(nv.ties, {'first', 'middle', 'last'})} = 'middle'
    nv.window (1, 1) double = 6
    nv.nanflag char {mustBeMember(nv.nanflag, {'perc', 'all'})} = 'all'
    nv.RegularTimes (:, 1) datetime
    nv.crossingval = nan
end

if length(tide) ~= length(s_tide)
    error("Tide and simple tide are different lengths - must have matching times")
end
if ~issorted(t_times)
    error("Tidal times are not sorted")
elseif ~issorted(wl_times)
    error("Water level times are not sorted")
end
if nv.window == 6
    fprintf(2, "Default 6 hour window is being used - may not be suitable for your site!" + newline)
end
if strcmp(nv.method, 'retime')
    wt = retime(timetable(wl, 'RowTimes', wl_times), t_times, 'fillwithmissing');
    wl = wt.wl;
    wl_times = wt.Time;
end
d = reshape({s_tide, tide, wl, t_times, t_times, wl_times}, 3, 2);
if isnan(nv.crossingval)
    ls = {s_tide > mean(s_tide, 'all', 'omitnan'), {}, {}};
else
    ls = {s_tide > nv.crossingval, {}, {}};
end
z = cell(3, 3);
for x = 1:3
    r = regionprops(ls{x}, d{x, 1}, 'Area', 'PixelValues');
    tm = d{x, 2}(ls{x});
    [a, b, np] = arrayfun(@(x) grouplogskew(x.PixelValues, nv), r, 'UniformOutput', false);
    vm = vertcat(a{:});
    z{x, 1} = vm(~isnan(vm));
    z{x, 2} = tm(vertcat(b{:}));
    np = vertcat(np{:});
    z{x, 3} = np(~isnan(vm));
    if x == 1
        for j = 2:3
            if j == 3 && strcmp(nv.method, 'split')
                if isfield(nv, 'RegularTimes')
                    [d{3, 1}, d{3, 2}, ls{j}] = split_timeseries(nv.RegularTimes, wl, z{1, 2},nv);
                else
                    [d{3, 1}, d{3, 2}, ls{j}] = split_timeseries(wl_times, wl, z{1, 2}, nv);
                end
            else
                timestep = hours(d{j, 2}(2) - d{j, 2}(1));
                ind = ceil((nv.window / 2) / timestep);
                ls{j} = nhourlog(d{j, 2}, z{1, 2}, ind, nv);
            end
        end
    end
end
if length(z{2, 2}) ~= length(z{3, 2})
    in = interp1(z{2, 2}, 1:length(z{2, 2}), z{3, 2}, 'nearest', 'extrap');
    if length(in) == length(z{3, 2})
        z{2, 1} = z{2, 1}(in);
        z{2, 2} = z{2, 2}(in);
    else
        [v, w] = unique(in, 'stable');
        di = setdiff(1:numel(in), w);
        fi = find(in == in(di));
        k = z{3, 2}(fi);
        u = interp1(z{2, 2}, 1:length(z{2, 2}), k, 'nearest', 'extrap');
        dd = NaT(length(u), 1) - NaT(1);
        for q = 1:length(u)
            dd(q) = k(q) - z{2, 2}(u(q));
        end
        for ui = unique(u)
            fi2 = find(u == ui);
            [~, mi] = min(abs(dd(fi2)));
            del_i = fi(fi2(mi));
            z{2, 1}(del_i) = [];
            z{2, 2}(del_i) = [];
        end
        in = interp1(z{2, 2}, 1:length(z{2, 2}), z{3, 2}, 'nearest', 'extrap');
        z{2, 1} = z{2, 1}(in);
        z{2, 2} = z{2, 2}(in);
    end
end
if isfield(nv, 'RegularTimes')
    timesteps = get_timesteps(z, nv.RegularTimes);
else
    timesteps = get_timesteps(z, wl_times);
end
out = {z{3, 1} - z{2, 1}, z{2, 2} - z{3, 2}, z{2, 2}, z{2, 1}, z{3, 2}, z{3, 1}, z{3, 3}, timesteps};
vnames = ["skew surge","time to tidal high water from actual high water", ...
    "time of tidal high water","tidal high water","time of actual high water", ...
    "actual high water","percentage of sea level nans in window","timestep of prior value -> actual high water (hours)"];
if strcmp(nv.nanflag, 'all')
    [nb, na] = nearest_nans(z, d);
    out = [out, nb, na];
    vnames = [vnames "time to nearest non-nan before hw (hours)","time to nearest non-nan after hw (hours)"];
end
sk = table(out{:}, 'VariableNames', vnames);
% remove those outside of window
sk(sk.(2) > hours(nv.window / 2) | sk.(2) < -hours(nv.window / 2), :) = [];
end

% fini

function [nwl, nts, i] = split_timeseries(wl_times, wl, shwts, nv)
    dt = hours(diff(wl_times)); % create array of time interval in hours
    dt = [hours(wl_times(2) - wl_times(1)); dt]; % add back first
    areas = @(x) [1; find(diff(x)) + 1; length(x)];
    ai = areas(dt); % get areas of consecutive timesteps
    cwl = cell(length(ai) - 1, 2);
    for z = 1:length(ai) - 1 % get separate arrays of consecutive timesteps
        cwl{z, 1} = wl(ai(z):ai(z + 1) - 1);
        cwl{z, 2} = wl_times(ai(z):ai(z + 1) - 1);
    end
    f = find(cellfun(@isscalar, cwl(:, 2)));
    for i = 1:length(f)
        if i < length(f) && f(i) < length(cwl) && f(i) + 1 == f(i + 1)
            cwl{f(i), 1} = []; cwl{f(i), 2} = [];
        elseif f(i) == length(cwl)
            cwl{f(i), 1} = []; cwl{f(i), 2} = [];
        else
            if cwl{f(i) + 1, 2}(1) - cwl{f(i), 2} == cwl{f(i) + 1, 2}(2) - cwl{f(i) + 1, 2}(1)
                cwl{f(i) + 1, 2} = [cwl{f(i), 2} ; cwl{f(i) + 1, 2}];
                cwl{f(i) + 1, 1} = [cwl{f(i), 1} ; cwl{f(i) + 1, 1}];
                cwl{f(i), 1} = []; cwl{f(i), 2} = [];
            end
        end
    end
    cwl(cellfun(@(x) isempty(x), cwl(:, 1)), :) = [];
    cwl(cellfun(@(x) length(x) == 1, cwl(:, 1)), :) = [];
    y = cell(height(cwl), 1);
    for z = 1:height(cwl)
        tps = hours(cwl{z, 2}(2) - cwl{z, 2}(1));
        inn = ceil((nv.window / 2) / tps);
        y{z} = nhourlog(cwl{z, 2}, shwts, inn, nv);
    end
    nwl = vertcat(cwl{:, 1});
    nts = vertcat(cwl{:, 2});
    i = vertcat(y{:});
end

function [m, l, nperc] = grouplogskew(a, nv)
    m = nan; l = false(length(a), 1); nperc = 100;
    if isempty(a)
        return
    elseif isnan(max(a, [], 'omitnan'))
        return
    else
        m = max(a, [], 'omitnan');
        li = a == m;
        if sum(li == 1) > 1
            if strcmp(nv.ties, 'middle')
                l = false(length(li), 1);
                fi = find(li == 1);
                if rem(length(fi), 2) == 1; q = .5; else; q = 0; end
                l(fi(length(fi) / 2 + q)) = 1;
            else
                l = false(length(li), 1);
                l(find(li == 1, 1, nv.ties)) = 1;
            end
        else
            l = li;
        end
        nperc = sum(isnan(a)) / length(a) * 100;
    end
end

function [ix] = nhourlog(times1, times2, ind, nv)
    if strcmp(nv.method, 'retime')
        ix = ismember(times1, times2);
    elseif strcmp(nv.method, 'split')
        iz = interp1(times1, 1:length(times1), times2, 'nearest', 'extrap');
        [~, u] = unique(iz);
        offset = table(iz(u), times1(iz(u)), times2(u));
        offset.(4) = hours(offset.(2) - offset.(3));
        offset(nv.window / 2 < abs(offset.(4)), :) = [];
        ix = false(length(times1), 1);
        ix(offset.(1)) = 1;
    end
    f = find(ix == 1);
    for j = 1:length(f)
        if strcmp(nv.method, 'retime')
            o = 0;
        else
            o = offset.(4)(j) / hours(times1(2) - times1(1));
        end
        fo = ceil(o);
        bo = floor(o);
        try
            ix(f(j) - ind + bo:f(j)) = 1;
        catch
            ix(1:f(j)) = 1;
        end
        if f(j) + ind - fo > length(ix)
            ix(f(j) + 1:end) = 1;
        else
            ix(f(j) + 1:f(j) + ind - fo) = 1;
        end
    end
end

function timesteps = get_timesteps(z, wl_times)
    jj = find(ismember(wl_times, z{3, 2}));
    if any(jj == 1)
        jj(jj == 1) = [];
        timesteps = hours(z{3, 2}(2:end) - wl_times(jj - 1));
        timesteps = [nan; timesteps];
    else
        timesteps = hours(z{3, 2} - wl_times(jj - 1));
    end
end

function [nb, na] = nearest_nans(z, d)
    % posixtime for speed
    i = find(ismember(d{3, 2}, z{3, 2}));
    if any(i == 1); S = 2; else; S = 1; end
    in = ~isnan(d{3, 1});
    nb = nan(length(z{3, 2}), 1); na = nan(length(z{3, 2}), 1);
    for j = S:length(i)
        ib = find(in(1:i(j) - 1), 1, 'last');
        if ~isempty(ib)
            nb(j) = (posixtime(d{3, 2}(ib)) - posixtime(d{2, 2}(i(j)))) / 3600;
        else
            nb(j) = nan;
        end
        ia = find(in(i(j) + 1:end), 1, 'first');
        if ~isempty(ia)
            ia = i(j) + ia;
            na(j) = (posixtime(d{3, 2}(ia)) - posixtime(d{2, 2}(i(j)))) / 3600;
        else
            na(j) = nan;
        end
    end
end

% fini fini