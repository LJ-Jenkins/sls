function [varargout] = time_between_exceedances(timebetween, xax, yax_log, r)
% plt.time_between_exceedances - plots the time between each group of consecutive values over a threshold, with options to highlight the magnitude of each exceedance 
%
% Inputs:
%   timebetween - (1x2) table from sls.rPOT: (:,1) dates, (:,2) time between
%   xax - the full datetime array of the timeseries or just the start and end dates (for xlim)
%   yax_log - values for the log y axis
% -name-value arguments- ('Rover', 'thresholds' and 'together' *ONLY* to be used in conjunction, the other name value args do not require them)
%   'Rover' - Rover table from sls.rPOT for magnitude of exceedances, only for use when 'thresholds' is also selected (Rover table should be 1 row longer than the timebetween table)
%   'thresholds' - give thresholds (double) if wish to show differences in magnitude of the data, requires 'Rover'
%   'together' - 'y': if specifying 'thresholds' and 'Rover' then plot on one tile with colours to show differences rather than a separate tile for each threshold
%   'colors' - colors of each set of scatters representing each threshold band, can be char, string array, or double of values but MUST be row-orientated e.g., ['a';'b'], ["a";"b"] or [1 2 3;4 5 6]
%   'addtofig' - 'y' to add to open figure on the next tile, aka do not initialise/create figure and tiledlayout - this will potentially exclude ylabels etc
%   'linky' - 'y' to link the y axes together, if issues with the y axes are seen, use 'fullaxis' if no axes are correct 
%   'fullaxis' - 'y' to apply setting. Sometimes when plotting (particularly if little data) the y axis changes limits/ticks/labels and are unable to be manually specified - to get round this, 
%                dummy data is plotted in white (as it is presumed a white background is preferred) to maintain y axis limits and ticks
%                if length(xax) == 2 then 100 points plotted, else if length(xax) > 2 then a point is plotted at every value of xax
%                as axes are/should be linked, this is only an issue is plotting a small number of locations or if all locations have very little data!
%                alternative solutions or get arounds to this problem, please email!
%
% Outputs (in order):
%   1st - cell array of tile handles
%
% Notes: if plotting different data in a loop using 'addtofig', for best results use the 'linky' code after
%        to standardise the y axis across plots, e.g. : linkaxes(findobj('type','axes'),'y'); set(gca,'YLimMode','auto','YLimitMethod','tight')

% Luke Jenkins Apr 2023
% L.Jenkins@soton.ac.uk

arguments
    timebetween (:, 2) table
    xax (:, 1) datetime
    yax_log (1, :) double
    r.Rover (:, 2) table
    r.thresholds (1, :) double
    r.colors = lines(20)
    r.together char {mustBeMember(r.together, {'y'})}
    r.lglabels string
    r.addtofig char {mustBeMember(r.addtofig, {'y'})}
    r.linky char {mustBeMember(r.linky, {'y'})}
    r.fullaxis char {mustBeMember(r.fullaxis, {'y'})}
end

if ~issortedrows(timebetween)
    timebetween = sortrows(timebetween);
end
if ~isfield(r, "addtofig")
    f = figure('units', 'normalized', 'outerposition', [.075 .125 .85 .80]);
    tld = tiledlayout('flow', 'TileSpacing', 'compact', 'padding', 'compact');
end
if ~isfield(r, "Rover")
    tiles = {nexttile};
    if isfield(r, "fullaxis")
        if length(xax) > 2
            scatter(xax(2:end - 1), linspace(yax_log(1), yax_log(end - 1), length(xax) - 2) + .5, .1, 'w')
        else
            scatter(repmat(timebetween.(1), 1, 100), linspace(yax_log(1), yax_log(end - 1), 100) + .5, .1, 'w')
        end
        set(gca, 'Layer', 'top')
        hold on
    end
    scatter(timebetween.(1), timebetween.(2), 30, 'filled', 'MarkerFaceColor', r.colors(1, :))
    ylabel('Time between exceedances')
else
    if ~isfield(r, "thresholds")
        error("'Rover' input also requires 'thresholds' input")
    end
    if isfield(r, "lglabels")
        lg_labels = r.lglabels;
    else
        lg_labels = sls.plt.binlabels(r.thresholds, 'right_edge', string(char(8805)) + string(r.thresholds(end)));
    end
    if ~issortedrows(r.Rover)
        r.Rover = sortrows(r.Rover);
    end
    r.Rover = r.Rover(2:end, :);
    if length(r.thresholds) > 1
        pd = cell(1, length(r.thresholds));
        for i = 1:length(r.thresholds)
            if i ~= length(r.thresholds)
                pd{i} = timebetween(r.Rover.(2) >= r.thresholds(i) & ...
                    r.Rover.(2) < r.thresholds(i + 1), :);
            else
                pd{i} = timebetween(r.Rover.(2) >= r.thresholds(i), :);
            end
        end
    end
    if isfield(r, "together")
        tiles = {nexttile};
        hold on
        if isfield(r, "fullaxis")
            if length(xax) > 2
                scatter(xax(2:end - 1), linspace(yax_log(1), yax_log(end - 1), length(xax) - 2) +.5 , .1, 'w')
            else
                scatter(repmat(timebetween.(1), 1, 100), linspace(yax_log(1), yax_log(end - 1), 100) + .5, .1, 'w')
            end
            set(gca, 'Layer', 'top')
        end
        for i = 1:length(r.thresholds)
            scatter(pd{1, i}.(1), pd{1, i}.(2), 30, 'filled', 'MarkerFaceColor', r.colors(i, :))
        end
        ylabel('Time between exceedances')
        legend(lg_labels, 'Location', 'northoutside', 'Orientation', 'horizontal')
    else
        if ~isfield(r, "addtofig")
            set(f, 'position', [0.3010 0.1370 0.4062 0.7139])
            tld.GridSize = [length(r.thresholds), 1];
        end
        tiles = cell(1, length(r.thresholds));
        for i = 1:length(r.thresholds)
            tiles{i} = nexttile;
            if isfield(r, "fullaxis")
                if length(xax) > 2
                    scatter(xax(2:end - 1), linspace(yax_log(1), yax_log(end - 1), length(xax) - 2) + .5, .1, 'w')
                else
                    scatter(repmat(timebetween.(1), 1, 100), linspace(yax_log(1), yax_log(end - 1), 100) + .5, .1, 'w')
                end
                set(gca, 'Layer', 'top')
                hold on
            end
            s(:, i) = scatter(pd{1, i}.(1), pd{1, i}.(2), 30, 'filled', 'MarkerFaceColor', r.colors(i, :));
        end
        lg = legend(s, lg_labels, 'Orientation', 'horizontal');
        if ~isfield(r, "addtofig")
            ylabel(tld, 'Time between exceedances')
            lg.Layout.Tile = 'north';
        end
    end
end
set(horzcat(tiles{:}), 'yscale', 'log', 'yticklabelmode', 'manual', 'ytick', yax_log, 'yticklabels', yax_log, ...
    'ylim', [0 yax_log(end)], 'xlim', [xax(1) xax(end)], 'XGrid', 'on', 'Ygrid', 'on', ...
    'XMinorGrid', 'on', 'YMinorGrid', 'on', 'Box', 'on')
if isfield(r, "linky")
    linkaxes(horzcat(tiles{:}), 'y')
    set(gca, 'YLimMode', 'auto', 'YLimitMethod', 'tight')
end

if nargout == 1
    varargout{1} = tiles;
end

% fini