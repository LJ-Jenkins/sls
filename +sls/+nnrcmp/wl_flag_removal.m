function [var_fr] = wl_flag_removal(var, nv)
% nnrcmp.wl_flag_removal - removes flagged NNRCMP qc water level data (replaces with nan)
%
% Inputs:
%   var - variable/s associated with flags, either nx1 double or nx5 table in the format from nnrcmp.load_wl output
%   flags_to_del - array of numbers corresponding to the flags below which specify datapoints to be removed  
%   flags - NNRCMP flags for the data (double) (to be used only with single variable inputs)
%
% Outputs:
%   var_fr - variable/s with flags removed (either nx1 double or nx5 table)

% NNRCMP Water Level QC Data Quality Control Flags (as of January 2022)
% 
% Flag	Description
% 2	    Interpolated value
% 3	    Doubtful value, typically not used
% 4	    Isolated spike or wrong value
% 5	    Correct but extreme value
% 6	    Reference change detected, typically not used
% 7	    Constant values, i.e. flat-lining
% 8	    Out of range
% 9	    Missing data	

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    var
    nv.flags_to_del (1, :) double = [3, 4, 7, 8, 9]
    nv.flags (:, 1) double = []
end

if isnumeric(var)
    if ~iscolumn(var) && ~isrow(var) || ~iscolumn(nv.flags) && ~isrow(nv.flags)
       error("Single variable inputs and flags must be nx1 arrays") 
    end
    if length(nv.var) ~= length(nv.flags)
        error("Variable and flag arrays are not equally sized")
    end
    var(ismember(nv.flags, nv.flags_to_del)) = nan;
    var(ismember(var, 9999)) = nan;
elseif istable(var)
    if width(var) ~= 5
        error("Table input must match format of nnrcmp.load_wav output (nx11 table)") 
    end
    var{ismember(var.(5), nv.flags_to_del), 2:4} = nan;
    i = ismember(var{:, 2:4}, 9999);
    for col = 2:width(var) - 1
        var{i(:, col - 1), col} = nan;
    end
end
var_fr = var;

% fini