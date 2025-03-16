function varargout = remove_msl(times, water_levels, nv)
% remove_msl - removes mean sea level trends from sea level data using method described in:
%              https://doi.org/10.1007/s11069-022-05617-z
%
% Inputs:
%   times - times of the sea level data
%   water_levels - sea level data
% -name-value arguments-
%   'linear' - (default) 1 for linear trend, 2 for quadratic trend
%
% Outputs (in order):
%   1st - water levels with mean sea level trends removed
%   2nd - (:,1) year and (:,2) the mean sea level trend for that year
%   3rd - the interpolated mean sea level trend

% Ivan Haigh
% I.D.Haigh@soton.ac.uk
% amended Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    times (:, 1) 
    water_levels (:, 1) double
    nv.linear = true
end

times = datenum(times);
yrs = year(times(1)):1:year(times(end));
i = year(times) == yrs;
a = [yrs' nan(length(yrs), 2)];
for j = 1:width(i)
    a(j, 2) = (sum(~isnan(water_levels(i(:, j)))) / length(i(i(:, j) == 1, j))) * 100; % perc cov of obs
    a(j, 3) = datenum(yrs(j), 7, 1, 0, 0, 0);
    a(j, 4) = mean(water_levels(i(:, j)), 'all', 'omitnan');
end
a(a(:, 2) < 75, 4) = nan;
j = ~isnan(a(:, 4));
if nv.linear == true
    nvl = 1;
else
    nvl = 2;
end
[~, yf] = msltrend(nvl, a(j, 3), a(j, 4), a(:, 3), 1);
b = yf - yf(end);
msl = interp1(a(:, 3), b, times);
wld = water_levels - msl;
out = {wld, [yrs' flipud(b)], -msl};
for i = 1:nargout
    varargout{i} = out{i}; 
end
end

% fini

function [T, yfit2] = msltrend(ty, x, y, x2, df)
    % Calculate trend and standard error
    switch ty
        %linear trend
        case 1
            X = [x ones(length(x), 1)];
            m = X \ y;
            %standard error without auto-correlation
            [n, ~] = size(X);
            nu = n - 2;                               % Residual degrees of freedom
            yfit = X * m;                             % Predicted responses at each data point.
            r = y - yfit;                             % Residuals.
            rmse = (sqrt(sum(r .^ 2))) / sqrt(nu);      % Root mean square error.
            Xi = inv(X' * X);
            se = [rmse * sqrt(Xi(1, 1)); rmse * sqrt(Xi(2, 2))];      
            %standard error with auto-correlation
            nu2 = ceil((n - 2) * df);                   % Residual degrees of freedom
            rmse2 = (sqrt(sum(r .^ 2))) / sqrt(nu2);    % Root mean square error.
            se2 = [rmse2 * sqrt(Xi(1, 1)); rmse2 * sqrt(Xi(2, 2))];                                  
            %export
            T = [m(1), se(1), se2(1)]; 
            X2 = [x2 ones(length(x2), 1)];
            yfit2 = X2 * m;                     
        %Quadractic trend
        case 2
            % trend - Quadtractic
            X = [x .^ 2 x ones(length(y), 1)];
            m = X \ y;
            %standard error without auto-correlation
            [n, ~] = size(X);
            nu = n - 3;                             % Residual degrees of freedom
            yfit2 =X * m;                           % Predicted responses at each data point.
            r = y - yfit2;                           % Residuals.
            rmse = (sqrt(sum(r .^ 2))) / sqrt(nu);    % Root mean square error.
            Xi = inv(X' * X);
            se = [rmse * sqrt(Xi(1, 1)); rmse * sqrt(Xi(2, 2)); rmse * sqrt(Xi(3, 3))];
            %standard error with auto-correlation
            nu2 = ceil((n - 3) * df);                    % Residual degrees of freedom
            rmse2 = (sqrt(sum(r .^ 2))) / sqrt(nu2);    % Root mean square error.
            se2 = [rmse2 * sqrt(Xi(1, 1)); rmse2 * sqrt(Xi(2, 2)); rmse2 * sqrt(Xi(3, 3))];
            %export
            T = [m(1) * 2, se(1) * 2, se2(1) * 2];
    end
end

% fini fini