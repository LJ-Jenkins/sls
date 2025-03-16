function varargout = calc_tide(times, water_levels, latitude, Usettings, nv)
% calc_tide - year by year or whole timeseries tidal harmonic analysis and tidal reconstruction from inputted 
%             sea level data onto your times or onto a 15 minute temporal timeseries from times(1) to 
%             times(end). If year by year, where years have less than the inputted data coverage, the nearest 
%             year that meets the inputted data coverage will be used. Mean sea level trends are removed prior 
%             to the analysis using sls.remove_msl, method described in:
%             https://doi.org/10.1007/s11069-022-05617-z
%
%             Requires UTide: Daniel Codiga (2023). UTide Unified Tidal Analysis and Prediction Functions 
%             (https://www.mathworks.com/matlabcentral/fileexchange/46523-utide-unified-tidal-analysis-and-prediction-functions), 
%             MATLAB Central File Exchange.
%
% Inputs:
%   times - times of the sea level data
%   water_levels - sea level data from which to calculate tide
%   latitude - latitude of data source
%   Usettings - cell array of accepted inputs to the UTide constituents call 'ut_solv' after the variables and latitude inputs, see UTide manual
%               (default) {'auto','NoTrend','LinCI','White','RunTimeDisp','nyn'}
% -name-value arguments- 
%   'period' - (default) 'yearly' or 'whole' for either a year by year tidal analysis or whole period analysis
%   'newtimes' - (default) 'y' or 'n' for whether to calculate tide for a new 15 minute temporal resolution or on the input's temporal resolution
%   'coverage' - 2x1 double of minimum number of observations and minimum percentage of data coverage to choose a year for harmonic analysis
%                Only for use in conjunction with 'period','yearly'
%                (default) 7000 observations and 50% data coverage
%   'ncnstits' - number of main constituents to use, see Utide's 'Cnstit' input (default is to ignore call) 
%   'dispU' - 'n' if you wish to keep the above UTide defaults but change the display setting to minimum
%   'removeMSL' - (default) 'y' or 'n' to remove mean sea level rise from the data before analysis
%   'timestep' - (default is 15) number of minutes for the timestep when 'newtimes' is 'y'
%
% Outputs (in order):
%   1st - tidal values
%   2nd - tidal times (15 minute temporal resolution)
%   3rd - results from the harmonic analysis (if year by year, a new harmonic analysis over the whole period will be undertaken)

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    times (:, 1) datetime
    water_levels (:, 1) double
    latitude (1, 1) double {mustBeNumeric}
    Usettings cell = {'auto', 'NoTrend', 'LinCI', 'White', 'RunTimeDisp', 'nnn'}
    nv.period char {mustBeMember(nv.period, {'yearly', 'whole'})} = 'yearly'
    nv.newtimes (1, 1) char {mustBeMember(nv.newtimes, {'y', 'n'})} = 'n'
    nv.coverage (1, 2) double {mustBeNumeric, mustBeNonnegative} = [7000 50]
    nv.ncnstits (1, 1) double
    nv.dispU (1, 1) char {mustBeMember(nv.dispU, {'y', 'n'})} = 'n'
    nv.removeMSL (1, 1) char {mustBeMember(nv.removeMSL, {'y', 'n'})} = 'y'
    nv.timestep (1, 1) double = 15
end

% first remove MSL rise
if strcmp(nv.removeMSL, 'y')
    water_levels = sls.remove_msl(times, water_levels);
end
if nv.newtimes == 'y'
    % New tidal timeseries
    yrs = year(times(1)):1:year(times(end));
    % t_times = (datetime(yrs(1), 1, 1, 0, 0, 0):minutes(15):datetime(yrs(end), 12, 31, 23, 45, 0))';
    t_times = (times(1):minutes(nv.timestep):times(end))';
else
    yrs = unique(year(times))';
    t_times = times;
end
if strcmp(nv.period, 'yearly')
    fprintf("Tidal analysis year by year:")
    i = year(times) == yrs;
    cov = [yrs' nan(length(yrs), 2)];
    for j = 1:width(i)
        cov(j, 2) = sum(~isnan(water_levels(i(:, j)))); % number of obs
        cov(j, 3) = (sum(~isnan(water_levels(i(:, j)))) / length(i(i(:, j) == 1, j))) * 100; % perc cov of obs
    end
    cov(:, 4) = cov(:, 2) >= nv.coverage(1) & cov(:, 3) >= nv.coverage(2);
    ry = find(cov(:, 4) == 1);
    tide = nan(length(t_times), 1);
    for j = 1:height(cov)
        fprintf(" %d" , yrs(j))
        if cov(j, 4) == 1
            % if both data coverage checks are met
            [~, TA_COEF] = evalc("ut_solv(datenum(times(i(:, j))), water_levels(i(:, j)), [], latitude, Usettings{:})");
            if isnan(TA_COEF.mean)
                cov(j, 4) = 0;
                ry(ry == j) = [];
                ut_warn
            end
        end
        if cov(j, 4) == 0
            % if one isn't met or if first attempt failed
            [nyi, TA_COEF] = nearest_solv(j, ry, times, i, water_levels, latitude, Usettings);
            if isnan(TA_COEF.mean)
                cov(nyi, 4) = 0;
                ry(ry == nyi) = [];
                ut_warn
                [~, TA_COEF] = nearest_solv(j, ry, times, i, water_levels, latitude, Usettings);
            end
        end
        if isfield(nv, 'ncnstits')
            [~, ti] = evalc("ut_reconstr(datenum(t_times(year(t_times) == cov(j, 1))), TA_COEF, 'Cnstit', TA_COEF.name(1:nv.ncnstits))");
        else
            [~, ti] = evalc("ut_reconstr(datenum(t_times(year(t_times) == cov(j, 1))), TA_COEF)");
        end
        tide(year(t_times) == cov(j,1)) = ti;
    end
elseif strcmp(nv.period, 'whole')
    fprintf("Tidal analysis for whole period %d-%d", yrs(1), yrs(end))
    [~, TA_COEF] = evalc("ut_solv(datenum(times), water_levels, [], latitude, Usettings{:})");
    [~, tide] = evalc("ut_reconstr(datenum(t_times), TA_COEF)");
end
if strcmpi(nv.period, 'yearly') && nargout == 3
    [~, TA_COEF] = evalc("ut_solv(datenum(times), water_levels, [], latitude, Usettings{:})");
end
varargout = {tide, t_times, TA_COEF};

% fini

function varargout = suppressed_call(suppressed, string)
    if suppressed
        varargout{:} = evalc(string);
    else
        varargout{:} = eval(string);
    end
end

function [nyi, TA_COEF] = nearest_solv(j, ry, times, i, water_levels, latitude, Usettings)
    nyi = ry(interp1(ry, 1:length(ry), j, 'nearest', 'extrap'));
    [~, TA_COEF] = evalc("ut_solv(datenum(times(i(:, nyi))), water_levels(i(:, nyi)), [], latitude, Usettings{:})");
end

function ut_warn
    warning("ut_solv FAILED: Attempting nearest year with coverages met." + newline + ...
        "Consider amending 'coverage' input if you see this message")
end

end

% fini fini