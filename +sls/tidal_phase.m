function phases = tidal_phase(tide_time, hwlw_time, nv)
% tidal_phase -  calculates tidal phase, aka time to either nearest high or low water for every timestep
%
% Inputs:
%   tide_time - times of the tide data
%   hwlw_time - times of the high/low waters
% -name-value arguments-
%   'unit' -  for the output unit, default 'hours'
%
% Outputs (in order):
%   1st - the tidal phase corresponding to the tidal timeseries

% Luke Jenkins May 2023
% L.Jenkins@soton.ac.uk

arguments
    tide_time (:, 1) datetime
    hwlw_time (:, 1) datetime
    nv.unit char {mustBeMember(nv.unit, {'years', 'days', 'hours', 'minutes', 'seconds'})} = 'hours'
end

i = interp1(hwlw_time, 1:numel(hwlw_time), tide_time, 'nearest', 'extrap');
phases = tide_time - hwlw_time(i);
convert_unit = @(x, u) feval(u, x);
phases = convert_unit(phases, lower(nv.unit));

% fini 