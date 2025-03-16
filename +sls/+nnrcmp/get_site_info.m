function t = get_site_info(var)
% nnrcmp.get_site_info: Get information on the NNRCMP Coastal Monitoring Organisation realtime data sites from their website.
%
% Input:
%   var: string
%       'waves' - get information on wave sites
%       'tides' - get information on tide sites
%       'met' - get information on meteorological sites
%
% Output:
%   t: table (some variables won't be necessary for all sites, easily removed)
%       Site: string - site name
%       Location: 1x4 string - location of the site
%       WMO code: double - World Meteorological Organisation code
%       Water depth (m): double - approximate water depth in metres
%       Water depth datum: string - water depth datum (if given)
%       Spring tidal range (m): double - approximate spring tidal range in metres
%       Storm alert threshold (m): double - storm alert threshold in metres

% Luke Jenkins May 2024
% L.Jenkins@soton.ac.uk

arguments
    var char {mustBeMember(var, {'waves', 'tides', 'met'})}
end

% load data table
url='https://coastalmonitoring.org/realtimedata/';
options = weboptions('Timeout', 30);
data = webread(url, options);
if strcmpi(var, 'waves')
    i = strfind(data, '<div class="table-responsive" id="waves">');
    j = strfind(data, 'class="charts_header" ><th colspan="5">Tides</');
    locnames = {"Wave buoy location", "Step gauge location", "Wave radar location", ...
        "Pressure array location", "Step gauge and met station location",...
        "Rex location"};
elseif strcmpi(var, 'tides')
    i = strfind(data, 'class="charts_header" ><th colspan="5">Tides</');
    j = strfind(data, '<table class="table table-striped"><tr class="charts_header" ><th colspan="5">Met</');
    locnames = {"Tide gauge location", "Platform location", "Wave radar location",...
        "Step gauge location", "Pressure array location", "Rex location",...
        "Step gauge and met station location"};
elseif strcmpi(var, 'met')
    i = strfind(data, '<table class="table table-striped"><tr class="charts_header" ><th colspan="5">Met</');
    j = strfind(data, '</table><div class="table-responsive" id="GPS">');
    locnames = {"Met station location", "Meteorological station location",...
        "Platform location", "Step gauge and met station location", "M<strong>et station location"};
end
info = {"<title>National Coastal Monitoring", locnames, "WMO code",...
    "Approximate water depth", "Approximate spring tidal range",...
    {"Storm alert threshold", "Storm threshold"}};
d = data(i:j);
pattern = ['\?chart=\d+&tab=' var '"'];
matches = regexp(d, pattern, 'match');
matches = unique(matches);
scodes = regexp(matches, '\d+', 'match');
le = length(scodes);
ws = strings(le, 1);
loc = strings(le, 4);
wmo = nan(le, 1);
wd = nan(le, 1);
wd_cd = strings(le, 1);
tr = nan(le, 1);
sa = nan(le, 1);
funcs = {@(str) regexp(str, '- (.+?)</', 'tokens', 'once'),... 
    @(str) regexp(str, '(\d+(\.\d+)?)&#', 'tokens'),...
    @(str) regexp(str, '\d+', 'match', 'once'),...
    @(str) regexp(str, '(\d+.*?)<', 'tokens', 'once'),...
    @(str) regexp(str, '(\d+.*?)<', 'tokens', 'once'),...
    @(str) regexp(str, '(\d+.*?)<', 'tokens', 'once')};
get_n = @(str) double(string(regexp(str, '[-+]?\d*\.?\d+', 'match')));
for n = 1:length(scodes)
    scode = scodes{n}{1};
    % load information on one site
    sitedata = webread([url '?chart=' scode '&tab=info&disp_option=']);
    sinfo = cell(1, length(info));
    siteout = cell(1, length(info));
    for nn = 1:length(info) % get the information
        if length(info{nn}) == 1
            ii = strfind(sitedata, info{nn});
        else
            ii = []; index = 1;
            while isempty(ii) && index <= numel(info{nn})
                ii = strfind(sitedata, info{nn}{index});
                index = index + 1;
            end
        end
        if isempty(ii)
            siteout{nn} = {nan};
        else
            if nn == 1
                k = '</title>';
            else
                k = '</tr>';
            end
            nxtline = strfind(sitedata(ii:end), k);
            sinfo{nn} = sitedata(ii:ii + nxtline(1));
            siteout{nn} = funcs{nn}(sinfo{nn});
        end
    end
    % format the output
    ws(n) = siteout{1}{1};
    try
        loc(n, :) = string(siteout{2});
    catch
        tmp = regexp(sinfo{2}, '(?<=;)\s*([\d.]+)', 'tokens');
        loc(n, :) = string(tmp);
    end
    wmo(n) = str2double(siteout{3});
    if ~isnan(siteout{4}{1}); wd(n) = get_n(siteout{4}); end
    if all(~isnan(siteout{4}{1}))
        if contains(siteout{4}, 'CD')
            wd_cd(n) = "CD";
        elseif contains(siteout{4}, 'OD')
            wd_cd(n) = "OD";
        else 
            wd_cd(n) = "Not specified";
        end
    else
        wd_cd(n) = "NA";
    end
    if ~isnan(siteout{5}{1}); tr(n) = get_n(siteout{5}); end
    if ~isnan(siteout{6}{1}); sa(n) = get_n(siteout{6}); end
    if all(~isnan(siteout{4}{1})) && contains(siteout{4}, 'cm'); disp(wave_sites(n) + " has 'cm'"); wd = wd * 100; end
    if all(~isnan(siteout{5}{1})) && contains(siteout{5}, 'cm'); disp(wave_sites(n) + " has 'cm'"); tr = tr * 100; end
    if all(~isnan(siteout{6}{1})) && contains(siteout{6}, 'cm'); disp(wave_sites(n) + " has 'cm'"); sa = sa * 100; end
end
t = table(ws, loc, wmo, wd, wd_cd, tr, sa, 'VariableNames', ["Site", "Location", "WMO code", "Water depth (m)",...
    "Water depth datum", "Spring tidal range (m)", "Storm alert threshold (m)"]);
t = sortrows(t);
t.Site(contains(t.Site, 'Gwynt')) = "Gwynt Y Mor";

% fini