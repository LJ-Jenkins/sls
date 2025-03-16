function [varargout] = perc_thresh_n_py(time, var, npy, sw, nv)
% perc_thresh_n_py: Get percentile threshold that gives closest to ~npy exceedances per year
%
% Inputs:
%   time - datetime array of time points
%   var - variable to calculate
%   npy - number of exceedances per year to get closest to
%   sw - storm window size (hours) for POT calculation
% -name-value arguments-
%   'startPerc' - starting percentile to search from (default 95)
%   'endPerc' - ending percentile to search to (default 99.9)
%   'percStep' - step size for searching percentiles (default 0.01)
%   'timeperiod' - time period to calculate return levels over (default 'yearly')
%
% Outputs (in order):
%   1st - threshold value
%   2nd - the percentile level of the threshold, e.g., 97 for 97th percentile used for threshold
%   3rd - the npy value of the chosen threshold that was the closest to the desired npy

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    time (:, 1) datetime
    var (:, 1) double
    npy (1, 1) double {mustBePositive}
    sw (1, 1) double {mustBePositive}
    nv.startPerc (1, 1) double {mustBePositive} = 95
    nv.endPerc (1, 1) double {mustBePositive} = 99.9
    nv.percStep (1, 1) double {mustBePositive} = 0.01
    nv.timeperiod char {mustBeMember(nv.timeperiod, {'NA storm season', 'seasonally', 'yearly', 'quarterly', 'monthly', 'weekly', 'daily', 'hourly'})} = 'yearly'
end

% Get percentile threshold that gives closest to ~npy exceedances per year
pot = sls.rPOT(time, var, prctile(var, nv.startPerc), sw);
percs = nv.startPerc:nv.percStep:nv.endPerc;
prctiles = prctile(var, percs);
bm = sls.POT_counts({pot, time}, prctiles, nv.timeperiod, 'totals');
avgpy = table2array(mean(bm, 1));
[~, j] = min(abs(avgpy - npy));
out = {prctiles(j), percs(j), avgpy(j)};

varargout = cell(1, nargout);
for n = 1:nargout
    varargout{n} = out{n};
end

% fini