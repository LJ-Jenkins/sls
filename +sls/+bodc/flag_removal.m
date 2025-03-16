function [var_fr] = flag_removal(var, nv)
% bodc.flag_removal - removes flagged BODC data (replaces with nan)
%
% Inputs:
%   var - variable/s associated with flags, either nx1 double or nx5 table in the format from bodc.load output
%   flags_to_del - string array of flags which correspond to datapoints to be removed (case sensitive)
%   flags - BODC flags for the data (string array) (to be used only with single variable inputs)
%
% Outputs:
%   var_fr - variable with flags removed (either nx1 double or nx5 table)

% BODC Quality Control Flags (as of March 2023)
% 
% FLAG	DESCRIPTION
% Blank	Unqualified
% <	    Below detection limit
% >	    In excess of quoted value
% A	    Taxonomic flag for affinis (aff.)
% B	    Beginning of CTD Down/Up Cast
% C	    Taxonomic flag for confer (cf.)
% D	    Thermometric depth
% E	    End of CTD Down/Up Cast
% G	    Non-taxonomic biological characteristic uncertainty
% H	    Extrapolated value
% I	    Taxonomic flag for single species (sp.)
% K	    Improbable value - unknown quality control source
% L	    Improbable value - originator's quality control
% M	    Improbable value - BODC quality control
% N	    Null value
% O	    Improbable value - user quality control
% P	    Trace/calm
% Q	    Indeterminate
% R	    Replacement value
% S	    Estimated value
% T	    Interpolated value
% U	    Uncalibrated
% W	    Control value
% X	    Excessive difference

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    var
    nv.flags_to_del (1, :) string = ["<", ">", "A", "B", "C", "D", "E", "G", "I", "K", "L", "M", "N", "O", "P", "Q", "U", "W", "X"]
    nv.flags (:, 1) string
end

if isnumeric(var)
    if ~iscolumn(var) && ~isrow(var) || ~iscolumn(nv.flags) && ~isrow(nv.flags)
       error("Single variable inputs and flags must be nx1 arrays") 
    end
    if length(var) ~= length(nv.flags)
        error("Variable and flag arrays are not equally sized")
    end
    var(ismember(nv.flags, nv.flags_to_del)) = nan;
elseif istable(var)
    if width(var) ~= 5
        error("Table input must match format of bodc.load output (nx5 table)") 
    end
    var{ismember(var.(3), nv.flags_to_del), 2} = nan; % wl flags
    var{ismember(var.(5), nv.flags_to_del), 4} = nan; % rs flags
end
var_fr = var;

% fini