function [varargout] = rPOT(times, var, rPOT, time_window, threshold, fig)
% plt.rPOT - plots all exceedance events from rPOT
%
% Inputs:
%   times - times, datetime
%   var - variable, double
%   rPOT - largest events and their associated times (times column 1, events column 2)
%   time_window - number of hours to show around the target exceedance events
%   threshold - threshold for an event, to be plotted as horizontal line
% -name-value arguments-
%   'plot' - (default) 'y' or 'n' to plot as new figure
%   'labels' - string array of ylabel and title (default is ["Variable level","Exceedance events"])
%   'sw' - 'y' or (default) 'n' to estimate a storm window in hours,
%          only works if input has had thresh_cross_del.m applied
%   'addtofig' - 'y' to add to open figure as the next tile (overrides 'plot' whether 'y' or 'n')
%
% Outputs (in order):
%   1st - storm window estimation range (if 'sw' is 'n', then this is skipped)
%   2nd - axes object
%   3rd - cell array of line objects (tile by tile)

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    times (:, 1) datetime
    var (:, 1) double
    rPOT (:, 2) table
    time_window (1, 1) double
    threshold (1, 1) double
    fig.plot (1, 1) char {mustBeMember(fig.plot, {'y', 'n'})} = 'y'
    fig.labels (1, 2) string = ["Variable level", "Exceedances"]
    fig.sw (1, 1) char {mustBeMember(fig.sw, {'y', 'n'})} = 'n'
    fig.addtofig (1, 1) char {mustBeMember(fig.addtofig, {'y'})}
end

if fig.plot == 'y' && ~isfield(fig, 'addtofig')
    figure('units', 'normalized', 'outerposition', [.225 .2 .55 .70])
    tiledlayout(1, 1, 'TileSpacing', 'compact', 'Padding', 'compact')
elseif fig.plot == 'n' && ~isfield(fig, 'addtofig')
    f = figure('visible', 'off');
end
lines = cell(1, width(var));
ax = nexttile;
hold on
grid on
box on
ylabel(fig.labels(1))
xlabel('Hours')
title(fig.labels(2))
x = (0:1:(time_window * 60 / 5)) * 5 / 60 - time_window / 2; % get a 5 min resolution for the time window
for i = 1:height(rPOT)
    j = times >= rPOT{i, 1} - hours(time_window / 2) & times <= rPOT{i, 1} + hours(time_window / 2); % find values
    if time(between(rPOT{i, 1} - hours(time_window / 2), times(find(j == 1, 1, 'first')))) == minutes(0)
        tt = retime(timetable(times(j), var(j)), times(find(j == 1, 1, 'first')):minutes(5):times(find(j == 1, 1, 'last'))); % interpolate onto 5 min timeseries (fill with nan)
    else
        n_times = rPOT{i, 1} - hours(time_window / 2):minutes(5):rPOT{i, 1} + hours(time_window / 2);
        tt = retime(timetable(times(j), var(j)), n_times);
    end
    lines{1, i} = plot(x(~isnan(tt.(1))), tt.(1)(~isnan(tt.(1))));
end
yline(threshold, '--k', "Threshold", 'LabelVerticalAlignment', 'middle', 'Fontweight', 'bold', 'LineWidth', 2)
yd = findobj(gca, '-property', 'YData');
xd = findobj(gca, '-property', 'XData');
xy_all = cell(1, length(yd));
for i = 1:length(yd)
    xy_all{1, i} = yd(i).YData;
    xy_all{2, i} = xd(i).XData;
end
ylim([min(cell2mat(xy_all(1, :))) - .1, max(cell2mat(xy_all(1, :))) + .1])
xlim([min(x(mod(x, 1) == 0)) max(x(mod(x, 1) == 0))])
if length(x) < 400
    xticks(x(mod(x, 1) == 0))
elseif length(x) > 400 && length(x) < 800
    xticks(x(mod(x, 2) == 0))
else
    xticks(x(mod(x, 3) == 0))
end
text(.02, .97, "n = " + string(length(yd)), 'units', 'normalized', 'fontweight', 'bold')
set(findobj(gcf, 'type', 'axes'), 'fontweight', 'bold')
% Storm window line calculation
if fig.sw == 'y'
    window_lines = cell(1, width(xy_all));
    for i = 1:width(xy_all)
         window_lines{1, i} = xy_all{2, i}(xy_all{1, i} > threshold);
    end
    mwl = cell2mat(window_lines);
    left_window_edge = max(mwl(mwl < 0)); % largest negative number
    right_window_edge = min(mwl(mwl > 0)); % smallest positive number
    ltxt = "exceedance"; rtxt = "exceedance";
    if isempty(left_window_edge) && isempty(right_window_edge)
        left_window_edge = min(x(mod(x, 1) == 0));
        right_window_edge = max(x(mod(x, 1) == 0));
        ltxt = "value (no exceedances in time window)";
        rtxt = "value (no exceedances in time window)";
    elseif isempty(left_window_edge)
        left_window_edge = min(x(mod(x, 1) == 0));
        ltxt = "value (no exceedances in time window)";
    elseif isempty(right_window_edge)
        right_window_edge = max(x(mod(x, 1) == 0));
        rtxt = "value (no exceedances in time window)";
    end
    sgstd_sw = right_window_edge - left_window_edge;
    xline(left_window_edge, '--r', "Closest prior " + ltxt, ...
        'LabelVerticalAlignment', 'middle', 'LabelOrientation', 'horizontal', 'Fontweight', 'bold', 'LineWidth', 1)
    xline(right_window_edge, '--r', "Closest subsequent " + rtxt, ...
        'LabelVerticalAlignment', 'middle', 'LabelOrientation', 'horizontal', 'Fontweight', 'bold', 'LineWidth', 1)
    if abs(left_window_edge) < right_window_edge
        xline(left_window_edge, '--k', "Suggested storm window: " + string(abs(left_window_edge) * 2) + "-" + ...
            string(sgstd_sw) + " hours", 'LabelVerticalAlignment', 'top', 'LabelOrientation', 'horizontal', ...
            'Fontweight', 'bold', 'LineWidth',2)
        xline(0 + abs(left_window_edge), '--k', 'LineWidth', 2)
        sw_est = [abs(left_window_edge) * 2 sgstd_sw];
    elseif abs(left_window_edge) > right_window_edge
        xline(0 - right_window_edge, '--k', "Suggested storm window: " + string(right_window_edge * 2) + "-" + ...
            string(sgstd_sw) + " hours", 'LabelVerticalAlignment', 'top', 'LabelOrientation', 'horizontal', ...
            'Fontweight', 'bold', 'LineWidth', 2)
        xline(right_window_edge, '--k', 'LineWidth', 2)
        sw_est = [right_window_edge * 2 sgstd_sw];
    elseif abs(left_window_edge) == right_window_edge
        xline(left_window_edge, '--k', "Suggested storm window: " + string(sgstd_sw) + " hours", ...
            'LabelVerticalAlignment', 'top', 'LabelOrientation', 'horizontal', 'Fontweight', 'bold', 'LineWidth', 2)
        xline(right_window_edge, '--k', 'LineWidth', 2)
        sw_est = sgstd_sw;
    end
end
if fig.plot == 'n'
    close(f)
end

if nargout >= 1
    if fig.sw == 'y'
        out = {sw_est, ax, lines};
    else
        out = {ax, lines};
    end
    varargout = cell(nargout,1);
    for k = 1:nargout
        varargout{k} = out{k};
    end
end

% fini