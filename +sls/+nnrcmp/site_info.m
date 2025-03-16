function info = site_info(site, var)
% nnrcmp.site_info: Get information on the NNRCMP Coastal Monitoring Organisation realtime data sites. Correct as of May 2024.
%
% Input:
%   var: string
%       'waves' - get information on wave sites
%       'tides' - get information on tide sites
%       'met' - get information on meteorological sites
%
% Output:
%   info: struct (some variables won't be necessary for all sites, easily removed)
%       Site: string - site name
%       Location: 1x4 string - location of the site
%       WMO: double - World Meteorological Organisation code
%       WaterDepth: double - approximate water depth in metres
%       WaterDepthDatum: string - water depth datum (if given)
%       SpringTidalRange: double - approximate spring tidal range in metres
%       StormThreshold: double - storm alert threshold in metres

% Luke Jenkins May 2024
% L.Jenkins@soton.ac.uk

arguments
    site
    var char {mustBeMember(var, {'waves', 'tides', 'met'})}
end

data = getdata(var);
% Create a table
t = cell2table(data, 'VariableNames', {'Site', 'L1', 'L2', 'L3', 'L4', 'WMO_Code', 'Water_Depth', 'Water_depth_datum',...
                                      'Spring_Tidal_Range', 'Storm_Alert_Threshold'});
i = find(contains(t.Site, site, 'IgnoreCase', true));
if length(i) ~= 1
    minl = editDistance(t.Site(i), site);
    [~, mini] = min(minl);
    i = i(mini);
end
info.Site = t.Site(i);
info.Location = [t.L1(i), t.L2(i), t.L3(i), t.L4(i)];
info.WMO = t.("WMO code")(i);
info.WaterDepth = t.("Water depth (m)")(i);
info.WaterDepthDatum = t.("Water depth datum")(i);
info.SpringTidalRange = t.("Spring tidal range (m)")(i);
info.StormThreshold = t.("Storm alert threshold (m)")(i);

function data = getdata(var)
if stcrmpi(var, 'waves')
% Define the data
data = {
    "Bideford Bay"	"51"	"03.48"	"004"	"16.62"	6201024	11	"CD"	8.4	5.04
    "Blakeney Overfalls"	"53"	"03"	"001"	"06"	62042	23	"Not specified"	NaN	3.31
    "Boscombe"	"50"	"42.69"	"001"	"50.39"	6201008	10.4	"CD"	1.5	2.61
    "Bracklesham Bay"	"50"	"43.43"	"000"	"50.30"	6201012	10.4	"CD"	4.6	3.19
    "Chapel Point"	"53"	"14"	"000"	"26"	6201050	13	"Not specified"	6	2.64
    "Chesil"	"50"	"36.13"	"002"	"31.37"	6201006	12	"CD"	3.1	4.18
    "Cleveleys"	"53"	"53.70"	"003"	"11.78"	6201028	10	"CD"	8.2	3.74
    "Dawlish"	"50"	"34.80"	"003"	"25.04"	6201027	11	"CD"	3.9	2.63
    "Deal Pier"	"51"	"13.428"	"001"	"24.556"	NaN	NaN	"NA"	NaN	1.47
    "Felixstowe"	"51"	"56"	"001"	"23"	6201052	8	"Not specified"	3.4	1.94
    "Folkestone"	"51"	"03.76"	"001"	"07.67"	6201017	12.7	"CD"	6.5	2.48
    "Goodwin Sands"	"51"	"14.99"	"001"	"29.00"	6201018	10	"CD"	1.5	2.49
    "Gwynt Y Mor"	"53"	"28.62"	"03"	"30.20"	NaN	10	"CD"	7.2	3.55
    "Happisburgh"	"52"	"49"	"001"	"32"	6201051	10	"Not specified"	2.6	2.66
    "Hastings Pier"	"50"	"51.053"	"000"	"34.372"	NaN	NaN	"NA"	NaN	2.16
    "Hayling Island"	"50"	"43.90"	"000"	"57.54"	6201011	10	"CD"	4.6	2.78
    "Herne Bay"	"51"	"22.919"	"001"	"06.934"	NaN	0.5	"CD"	NaN	0.71
    "Hornsea"	"53"	"55.02"	"000"	"03.95"	6201019	12	"CD"	5	3.04
    "Looe Bay"	"50"	"20.33"	"004"	"24.65"	6201025	10	"CD"	4.8	3.7
    "Lowestoft"	"52"	"28"	"001"	"49"	6201059	20	"Not specified"	1.9	3.06
    "Lymington"	"50"	"44.4198"	"001"	"30.4268"	NaN	2	"CD"	NaN	0.79
    "Milford"	"50"	"42.75"	"001"	"36.91"	6201009	10	"CD"	2	2.74
    "Minehead"	"51"	"13.68"	"003"	"28.15"	6201004	10	"CD"	9.6	2.2
    "Morecambe Bay"	"53"	"59.38"	"003"	"03.96"	6201029	10	"CD"	8.2	3.21
    "New Brighton"	"53"	"26.57"	"003"	"02.06"	NaN	5	"CD"	8.4	1.64
    "Newbiggin"	"55"	"11.11"	"001"	"28.69"	6201047	18	"CD"	4.2	3.42
    "North Well"	"53"	"03"	"000"	"28"	62041	31	"Not specified"	6.25	2.2
    "Penarth"	"51"	"26.080"	"003"	"09.887"	NaN	NaN	"NA"	NaN	NaN
    "Penzance"	"50"	"06.86"	"005"	"30.18"	6201000	10	"CD"	4.8	3.06
    "Perranporth"	"50"	"21.19"	"005"	"10.47"	6201001	14	"CD"	6.1	5.4
    "Pevensey Bay"	"50"	"46.91"	"000"	"25.10"	6201015	9.8	"CD"	6.1	3.2
    "Port Isaac"	"50"	"35.651"	"004"	"50.065"	NaN	NaN	"NA"	NaN	3
    "Porthleven"	"50"	"03.76"	"005"	"18.44"	6201044	15	"CD"	4.7	4.93
    "Rhyl Flats"	"53"	"22.92"	"003"	"36.21"	NaN	10	"CD"	7.2	2.89
    "Rustington"	"50"	"44.06"	"000"	"29.64"	6201013	9.9	"CD"	6.1	3.37
    "Rye Bay"	"50"	"51.083"	"000"	"47.433"	NaN	10	"CD"	6.1	3.52
    "Sandown Bay"	"50"	"39.03"	"001"	"07.68"	6201010	10.7	"CD"	3.3	2.48
    "Sandown Pier"	"50"	"39.067"	"001"	"09.189"	NaN	NaN	"NA"	NaN	1.41
    "Scarborough"	"54"	"17.60"	"000"	"19.06"	6201045	19	"CD"	4.8	4.22
    "Seaford"	"50"	"45.99"	"000"	"04.53"	6201014	11	"CD"	6.1	3.78
    "Second Severn Crossing"	"51"	"34.456"	"002"	"41.999"	NaN	NaN	"NA"	NaN	0.74
    "St Mary's Sound"	"49"	"53.53"	"06"	"18.76"	6201053	53	"CD"	5	4.43
    "Start Bay"	"50"	"17.53"	"003"	"36.99"	6201002	10	"CD"	4.4	2.98
    "Swanage Pier"	"50"	"36.562"	"001"	"56.954"	NaN	NaN	"NA"	NaN	1.14
    "Teignmouth Pier"	"50"	"32.632"	"003"	"29.529"	NaN	NaN	"NA"	NaN	1.75
    "Tor Bay"	"50"	"26.02"	"003"	"31.08"	6201003	11	"CD"	4	2.2
    "Wave Hub"	"50"	"20.84"	"005"	"36.84"	NaN	50	"CD"	6.1	6.81
    "West Anglesey (SEACAMS)"	"53"	"13.0017"	"004"	"43.4438"	NaN	45	"CD"	NaN	NaN
    "West Bay"	"50"	"41.63"	"002"	"45.06"	6201005	10	"CD"	3.5	4.08
    "Weston Bay"	"51"	"21.13"	"003"	"01.23"	6201026	13	"CD"	11.2	1.94
    "Weymouth"	"50"	"37.36"	"002"	"24.85"	6201007	NaN	"NA"	2	2.11
    "Whitby"	"54"	"30.27"	"000"	"36.41"	6201046	NaN	"NA"	4.6	4.16
};
elseif strcmpi(var, 'tides')
data = {
    "Arun Platform"	"50"	"46.200"	"000"	"29.500"	NaN	NaN	"NA"	NaN	NaN
    "Brighton"	"50"	"48.707"	"000"	"06.071"	NaN	NaN	"NA"	NaN	NaN
    "Deal Pier"	"51"	"13.428"	"001"	"24.556"	NaN	NaN	"NA"	NaN	1.47
    "Exmouth"	"50"	"37.043"	"03"	"25.415"	NaN	NaN	"NA"	NaN	NaN
    "Hastings Pier"	"50"	"51.053"	"000"	"34.372"	NaN	NaN	"NA"	NaN	2.16
    "Herne Bay"	"51"	"22.919"	"001"	"06.934"	NaN	0.5	"CD"	NaN	0.71
    "Lymington"	"50"	"44.4198"	"001"	"30.4268"	NaN	2	"CD"	NaN	0.79
    "Penarth"	"51"	"26.080"	"003"	"09.887"	NaN	NaN	"NA"	NaN	NaN
    "Port Isaac"	"50"	"35.651"	"004"	"50.065"	NaN	NaN	"NA"	NaN	3
    "Sandown Pier"	"50"	"39.067"	"001"	"09.189"	NaN	NaN	"NA"	NaN	1.41
    "Scarborough"	"54"	"16.948"	"00"	"23.408"	NaN	NaN	"NA"	NaN	NaN
    "Second Severn Crossing"	"51"	"34.456"	"002"	"41.999"	NaN	NaN	"NA"	NaN	0.74
    "Swanage Pier"	"50"	"36.562"	"001"	"56.954"	NaN	NaN	"NA"	NaN	1.14
    "Teignmouth Pier"	"50"	"32.632"	"003"	"29.529"	NaN	NaN	"NA"	NaN	1.75
    "West Bay Harbour"	"50"	"42.532"	"002"	"45.847"	NaN	NaN	"NA"	NaN	NaN
    "Whitby Harbour"	"54"	"29.318"	"00"	"36.878"	NaN	NaN	"NA"	NaN	NaN
};
elseif strcmpi(var, 'met')
data = {
    "Arun Platform"	"50"	"46.200"	"000"	"29.500"	NaN	NaN	"NA"	NaN	NaN
    "Brighton"	"50"	"48.844"	"000"	"06.046"	NaN	NaN	"NA"	NaN	NaN
    "Bude"	"50"	"49.847"	"004"	"33.003"	NaN	NaN	"NA"	NaN	NaN
    "Chapel Point"	"53"	"13"	"000"	"20"	6201050	13	"Not specified"	6	2.64
    "Deal Pier"	"51"	"13.435"	"001"	"24.540"	NaN	NaN	"NA"	NaN	1.47
    "Exmouth"	"50"	"36.657"	"03"	"23.945"	NaN	NaN	"NA"	NaN	NaN
    "Felixstowe"	"51"	"56"	"001"	"19"	6201052	8	"Not specified"	3.4	1.94
    "Folkestone"	"51"	"04.77"	"001"	"10.19"	6201017	12.7	"CD"	6.5	2.48
    "Happisburgh"	"52"	"48"	"001"	"33"	6201051	10	"Not specified"	2.6	2.66
    "Herne Bay"	"51"	"22.370"	"001"	"07.460"	NaN	0.5	"CD"	NaN	0.71
    "Looe Bay"	"50"	"20.70"	"004"	"27.17"	6201025	10	"CD"	4.8	3.7
    "Lymington"	"50"	"44.4198"	"001"	"30.4268"	NaN	2	"CD"	NaN	0.79
    "Minehead"	"51"	"12.427"	"003"	"27.734"	6201004	10	"CD"	9.6	2.2
    "Penarth"	"51"	"26.089"	"003"	"09.889"	NaN	NaN	"NA"	NaN	NaN
    "Penzance"	"50"	"07.04"	"005"	"31.79"	6201000	10	"CD"	4.8	3.06
    "Perranporth"	"50"	"20.77"	"005"	"09.71"	6201001	14	"CD"	6.1	5.4
    "Port Isaac"	"50"	"35.408"	"004"	"49.426"	NaN	NaN	"NA"	NaN	3
    "Sandown Pier"	"50"	"39.070"	"001"	"09.190"	NaN	NaN	"NA"	NaN	1.41
    "Southwold"	"52"	"18"	"001"	"40"	NaN	NaN	"NA"	NaN	NaN
    "Swanage Pier"	"50"	"36.562"	"001"	"56.954"	NaN	NaN	"NA"	NaN	1.14
    "Teignmouth Pier"	"50"	"32.633"	"003"	"29.527"	NaN	NaN	"NA"	NaN	1.75
    "West Bay Harbour"	"50"	"42.640"	"002"	"45.837"	NaN	NaN	"NA"	NaN	NaN
    "Weston Bay"	"51"	"20.65"	"002"	"58.90"	6201026	13	"CD"	11.2	1.94
    "Weymouth"	"50"	"34.21"	"002"	"27.31"	6201007	NaN	"NA"	2	2.11
    "Worthing Pier"	"50"	"48.422"	"000"	"22.128"	NaN	NaN	"NA"	NaN	NaN
};
end

% fini