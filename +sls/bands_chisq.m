function varargout = bands_chisq(pop, sample, nbands, expected_amounts, nv)
% bands_chisq - chi squared goodness of fit test for data and a sample partitioned into n-bands
%
% Inputs:
%   pop - all data (population)
%   sample - sample of data
%   nbands - number of bands to use
%   expected_amounts - (default) 'proportion' or 'equiprobable', to either create equiprobable expected amounts (pop is ignored and sample 
%                      is presumed that it should have equal amounts in each band), or to use the proportions of each band seen in the 
%                      population as the proportions that should be seen in the sample
% -name value arguments-
%   'dcplaces' - (default: 3) number of decimal places to floor/ceil data when creating the bands
%
% Outputs (in order):
%   1st - chi squared x2 statistic
%   2nd - table summarising the chi squared test 

% Luke Jenkins May 2023
% L.Jenkins@soton.ac.uk

arguments
    pop (:, 1) double
    sample (:, 1) double
    nbands (1, 1) double
    expected_amounts char {mustBeMember(expected_amounts, {'proportion', 'equiprobable'})} = 'proportion'
    nv.dcplaces (1, 1) double = 3
end

b = floorS(min(pop), nv.dcplaces):(ceilS(max(pop), nv.dcplaces) - floorS(min(pop), nv.dcplaces)) ...
    / nbands:ceilS(max(pop), nv.dcplaces); % get n-bands
c = nan([length(b) - 1, 2]);
if strcmpi(expected_amounts, 'proportion')
    for i = 1:length(b) - 1 
        c(i, 1) = length(find(sample(~isnan(sample)) >= b(i) & sample(~isnan(sample)) < b(i + 1))); % find no. obs. in sample
        p = (length(find(pop(~isnan(pop)) >= b(i) & pop(~isnan(pop)) < b(i + 1))) ...
            / length(pop(~isnan(pop)))) * 100; % find pop proportion in band
        c(i, 2) = round((length(sample(~isnan(sample))) / 100) * p); % calculate what the expected amount would be
    end
elseif strcmpi(expected_amounts, 'equiprobable')
    for i = 1:length(b) - 1 
        c(i, 1) = length(find(sample(~isnan(sample)) >= b(i) & sample(~isnan(sample)) < b(i + 1))); % find no. obs. in sample
    end
    c(:, 2) = length(sample(~isnan(sample))) / nbands; % expected
end
c(:, 3) = ((c(:, 1) - c(:, 2)) .^ 2) ./ c(:, 2);
bs = sls.plt.binlabels(b, 'rightedge', 'delete');
[h, p, stats] = chi2gof(1:nbands, 'freq', c(:, 1), 'expected', c(:,2), 'ctrs', 1:nbands);
chi = stats.chi2stat;
df = stats.df;
c = array2table(c, 'VariableNames', ["Observed", "Expected", "((O - E) ^ 2) / E"]);
c = addvars(c, bs, 'NewVariableNames', 'Bands', 'Before', 1); 
q = ["x2 = " + string(sprintf('%.2f', chi)); "h = " + string(h); ...
    "p = " + string(sprintf('%.2f', p)); "df = " + string(df)];
q(end + 1:height(c)) = "";
c.Notes = q;
varargout = {chi, c};

end

% fini

function flooredVal = floorS(val, nS)
    pw = ceil(log10(val)); % Find order of magnitude of val.
    res = 10 ^ (pw - nS); % Resolution to round to.
    flooredVal = floor(val / res) * res;
end

function ceiledVal = ceilS(val, nS)
    pw = ceil(log10(val)); % Find order of magnitude of val.
    res = 10 ^ (pw - nS); % Resolution to round to.
    ceiledVal = ceil(val / res) * res; 
end

% fini fini