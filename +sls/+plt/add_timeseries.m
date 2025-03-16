function [varargout] = add_timeseries(times, var, labels, lineopts, init)
% plt.add_timeseries - plots variables and their associated times on a new plot or to a open plot on the next tile
%
% Inputs:
%   var - variable of type double
%   times - times of type datetime
%   labels - string array of ylabel and title (default is blank)
% -name-value arguments-
%   - any public property name and value for the line() base function, e.g., 'Color','r'
%   'initialise' - initialise plot (default) 'n' or 'y' if not plotting to an open plot, aka create figure and tiledlayout
%
% Outputs (in order):
%   1st - axes object
%   2nd - line object

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    times (:, 1) datetime
    var (:, 1) double
    labels (1, 2) string = ["",""]
    lineopts.?matlab.graphics.chart.primitive.Line
    init.initialise char {mustBeMember(init.initialise, {'y', 'n'})} = 'n'
end

if init.initialise == 'y'
    f = figure('units', 'normalized');
    tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');
    set(f, 'outerposition', [.075 .125 .85 .80])
end

lo = namedargs2cell(lineopts);
tile = nexttile;
%grid on
box on
line = plot(times, var, lo{:});
ylabel(labels(1))
title(labels(2))
set(findobj(gcf, 'type', 'axes'), 'fontweight', 'bold')

if nargout >= 1
    out = {tile, line};
    varargout = cell(nargout, 1);
    for k = 1:nargout
        varargout{k} = out{k};
    end
end

% fini