function varargout = return_levels(distfit, data, return_period, nv)
% return_levels - calculates return levels for specified return periods by fitting a gev, gumbel (for block maxima), or gp (for peaks over threshold) distribution to given data
%
% Inputs:
%   distfit - distribution to be fitted, 'gev' for generalized extreme value distribution, 'gum' for Gumbel distribution, 
%             or 'gp' for generalized pareto distribution
%   data - data from which to calculate the return levels: should be either peaks over threshold or block maxima values (e.g., annual detrended water level maxima)
%   return_period - return period/s from which to calculate return levels, (default) [1 2 5 10 25 50 100 250 1000]
% -name-value arguments-
%   'threshold' - the threshold used for peaks over threshold data with 'gp' distribution input
%   'avgpy' - the average number of exceedances per year (or timeperiod) for peaks over threshold data with 'gp' distribution input
%   'plot' - (default) 'n' or 'y' to plot a 4 tile plot of a) Probability, b) Quantiles, c) Return periods, and d) Density
%
% Outputs (in order):
%   1st - double of (:,1) return periods, (:,3) return levels, and (:,[2 4]) lower and upper return level confidence intervals
%   2nd - struct containing: 

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    distfit char {mustBeMember(distfit, {'gev', 'gum', 'gp'})}
    data (:, 1) double
    return_period (1, :) double = [1 2 5 10 25 50 100 250 1000]
    nv.threshold (1, 1) double
    nv.avgpy (1, 1) double
    nv.plot char {mustBeMember(nv.plot, {'n', 'y'})} = 'n'
end

if strcmp(distfit, 'gp') && ~isfield(nv, 'threshold') || strcmp(distfit, 'gp') && ~isfield(nv, 'avgpy')
    error("If fitting a gp distribution, 'threshold' and 'avgpy' inputs must be given.")
elseif any(strcmp(distfit, {'gev', 'gum'})) && isfield(nv, 'threshold') || any(strcmp(distfit, {'gev', 'gum'})) && isfield(nv, 'avgpy')
    warning("'threshold' and 'avgpy' inputs only used in conjunction with 'gp': ignoring these given inputs.")
end

% Fit distribution
if strcmp(distfit, 'gev')
    [paramEsts, paramCIs] = gevfit(data); % GEV fit
    kMLE = paramEsts(1);        % Shape parameter
    sigmaMLE = paramEsts(2);    % Scale parameter
    muMLE = paramEsts(3);       % Location parameter
    [mm, vr] = gevstat(kMLE, sigmaMLE, muMLE); % Mean and variance
    % Negative log likelihood and variance-covariance matrix
    [nll, acov] = gevlike(paramEsts, data);
elseif strcmp(distfit, 'gum')
    [paramEsts, paramCIs] = evfit(-data); % EV fit
    [mm, vr] = evstat(paramEsts(1), paramEsts(2)); % Mean and variance
    % Negative log likelihood and variance-covariance matrix
    [nll, acov] = evlike(paramEsts, data);
elseif strcmp(distfit, 'gp')
    [paramEsts, paramCIs] = gpfit(data - nv.threshold); % gp fit
    [mm, vr] = gpstat(paramEsts(1), paramEsts(2)); % Mean and variance
    % Negative log likelihood and variance-covariance matrix
    [nll, acov] = gplike(paramEsts, data - nv.threshold);
end
paramSEs = sqrt(diag(acov)); % Parameter standard errors

% Return levels
if strcmp(distfit, 'gp')
    f = 1 - (1 ./ (return_period .* nv.avgpy));
else
    f = exp(-1 ./ return_period);
    p = 1 - f;
end
return_levels(:, 1) = return_period;
if strcmp(distfit, 'gev')
    return_levels(:, 3) = gevinv(f, kMLE, sigmaMLE, muMLE);
elseif strcmp(distfit, 'gum')
    return_levels(:, 3) = evinv(p, paramEsts(1), paramEsts(2)) .* -1;
elseif strcmp(distfit,'gp')
    return_levels(:, 3) = gpinv(f, paramEsts(1), paramEsts(2), nv.threshold);
end

% Confidence intervals
if strcmp(distfit, 'gev')
    % from Coles (2001) page 56: the Delta method
    j = [(sigmaMLE .* kMLE .^ -2) .* (1 - (-log(1 - p)) .^ -kMLE) - ...
        (sigmaMLE .* kMLE .^ -1) .* ((-log(1 - p)) .^ -kMLE) .* (log((-log(1 - p)))); ...
        (-kMLE .^ - 1) .* (1 - (-log(1 - p)) .^ -kMLE);
        ones(1, length(p))];
    v = diag(j' * acov * j);
    return_levels(:, 2) = return_levels(:, 3) - 1.96 .* sqrt(v); % Confidence limits
    return_levels(:, 4) = return_levels(:, 3) + 1.96 .* sqrt(v);
elseif strcmp(distfit, 'gum')
    pd = fitdist(-data, 'ExtremeValue');
    [X] = -evinv(p, pd.mu, pd.sigma, pd.ParameterCovariance, 0.05);
    [X1, XLO, XUP] = evinv(p, pd.mu, pd.sigma, pd.ParameterCovariance, 0.05);
    return_levels(:, 2) = XLO - (X1 - X);
    return_levels(:, 4) = XUP - (X1 - X);
elseif strcmp(distfit,'gp')
    return_levels(:, 2) = gpinv(f, paramCIs(1, 1), paramCIs(1, 2), nv.threshold);
    return_levels(:, 4) = gpinv(f, paramCIs(2, 1), paramCIs(2, 2), nv.threshold);
end

% Empirical model
P_em = (1:length(data)) / (length(data) + 1);
if strcmp(distfit, 'gev')
    % Weibull plotting position, Coles (2001) page 43
    % Calculate inverse GEV for empirical model
    zp_em = gevinv(P_em, kMLE, sigmaMLE, muMLE);
    P_data = gevcdf(sort(data, 'ascend'), kMLE, sigmaMLE, muMLE);
elseif strcmp(distfit, 'gum')
    % Calculate inverse EV
    zp_em = evinv(P_em, paramEsts(1), paramEsts(2)) .* -1;
    P_data = evcdf(sort(data, 'ascend'), paramEsts(1), paramEsts(2));
elseif strcmp(distfit, 'gp')
    % Calculate inverse cdf for a gp
    zp_em = gpinv(P_em, paramEsts(1), paramEsts(2), nv.threshold);
    P_data = gpcdf(sort(data, 'ascend'), paramEsts(1), paramEsts(2), nv.threshold);
end
% Store plotting positions
if strcmp(distfit, 'gp')
    PP(:, 1) = 1 ./ ((1 - P_em) * nv.avgpy);
else
    PP(:, 1)  = -1 ./ log(P_em);
end
PP(:, 2)  = sort(data, 'ascend');

varargout = {return_levels, struct('paramEsts', paramEsts, 'paramCIs', paramCIs, 'paramSEs', paramSEs, ...
    'mean', mm, 'variance', vr, 'nloglik', nll, 'acov', acov)};

if nv.plot == 'y'
    xlabels = [repmat("Model", 1, 2), "Return period (years)", "Empirical"];
    ylabels = [repmat("Empirical", 1, 2), "Return level", "Density"];
    titles = ["(a) Probability", "(b) Quantile", "(c) Return levels", "(d) Density"];
    mkrstyle = {'ok', 'markersize', 3, 'markerfacecolor', 'k'};
    logsets = {'xscale', 'log', 'xlim', [0.1 1000], 'xticklabel', {'0.1', '1', '10', '100', '1000'}};

    figure('units', 'normalized', 'position', [.25 .25 .4 .5])
    tld = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    for i = 1:4
        nexttile
        hold on
        grid on
        box on
        if i == 1
            qp_plot(P_em, P_data, 0, 1)
        elseif i == 2
            qp_plot(zp_em, sort(data, 'ascend'), 1, 1e15)
            qlim = [min(data) - 0.02 max(data) + 0.02];
            axis([qlim qlim])
        elseif i == 3
            for j = 2:4
                if j == 3; s = '-r'; else; s = '-.r'; end
                plot(return_period, return_levels(:, j), s)
            end
            plot(PP(:, 1), PP(:, 2), mkrstyle{:})
            % xlim([return_period(1) return_period(end)])
            set(gca, logsets{:})
        elseif i == 4
            d_plot(distfit)
        end
        xlabel(xlabels(i))
        ylabel(ylabels(i))
        title(titles(i))
    end
    title(tld, upper(distfit) + " Distribution", 'fontweight', 'bold')
end

function qp_plot(x, y, li1, li2)
    plot(x, y, mkrstyle{:})
    plot(linspace(li1, li2), linspace(li1, li2), '--r'); %diagonal
end

function d_plot(distfit)
    [F, X] = ecdf(data, 'Function', 'cdf');  % compute empirical cdf
    ecdfhist(F, X, min(X):.1:max(X)) % empirical pdf from cdf
    h = findobj(gca, 'Type', 'patch');
    h.FaceColor = [.9 .9 .9];
    xlim = get(gca, 'XLim');
    X = linspace(xlim(1), xlim(2), 100);
    if strcmp(distfit, 'gev')
        Y = gevpdf(X, kMLE, sigmaMLE, muMLE);
    elseif strcmp(distfit, 'gum')
        Y = evpdf(-X, paramEsts(1), paramEsts(2));
    elseif strcmp(distfit,'gp')
        Y = gppdf(X, paramEsts(1), paramEsts(2), nv.threshold);
    end
    plot(X, Y, 'r')
    plot(data, 0, mkrstyle{:})
end

end

% fini