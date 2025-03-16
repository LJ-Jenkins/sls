function [varargout] = add_line(x, y, line_clr)
% plt.add_line - plots line variable to a open plot
%
% Inputs:
%   x - x axis variable
%   y - y axis variable
% -name-value arguments-
%   - any public property name and value for the line() base function, e.g., 'Color','r'
%
% Outputs (in order):
%   1st - line object

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments (Repeating)
    x 
    y
    %opts.?matlab.graphics.chart.primitive.Line
    line_clr
end

% line_opts = namedargs2cell(opts);
% hold on
% line = plot(x,y,line_opts{:});

hold on
line = cell(1, width(x));
for i = 1:width(x)
    line{i} = plot(x{1, i}, y{1, i}, 'Color', line_clr{1, i});
end

if nargout == 1
    varargout{1} = line;
end

% fini