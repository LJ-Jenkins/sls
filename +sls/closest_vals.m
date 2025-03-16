function [cv] = closest_vals(a, b, nv)
% closest_vals - Find the closest values (or their indices) in b to those in a.
%
% Inputs:
%   a - data or times
%   b - data or times
%
% -name-value arguments-
%   'indices' - 'true' to return the indices of the closest values in b
%   'side' - (default) 'left' or 'right' to specify which side to return the index from
%
% Outputs (in order):
%   1st - closest values (or indices) in b to those in a

% Credit: Divakar 
% (https://stackoverflow.com/questions/45349561/find-nearest-indices-for-one-array-against-all-values-in-another-array-python/45350318#45350318)
% Amended by Luke Jenkins Apr 2024
% L.Jenkins@soton.ac.uk

arguments
    a
    b
    nv.indices = false
    nv.side char {mustBeMember(nv.side, {'left', 'right'})} = 'left'
end

L = numel(b);
[sorted_b, sidx_b] = sort(b);
sorted_idx = sls.searchsorted(sorted_b, a, 'side', nv.side);
sorted_idx(sorted_idx == L) = L - 1;
mask = (sorted_idx > 0) & ((abs(a - sorted_b(sorted_idx - 1)) < abs(a - sorted_b(sorted_idx))));
if nv.indices == true
    cv = sidx_b(sorted_idx - mask);
else
    cv = b(sidx_b(sorted_idx - mask));
end

% fini