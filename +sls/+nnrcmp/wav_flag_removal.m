function [var_fr] = wav_flag_removal(var, nv)
% nnrcmp.wav_flag_removal - removes flagged NNRCMP qc wave data (replaces with nan) (when flag = 7 - buoy off location, nothing is removed)
%
% Inputs:
%   var - variable/s associated with flags, either nx1 double or nx11 table in the format from nnrcmp.load_wav output
%   flags_to_del - array of numbers corresponding to the flags below which specify datapoints to be removed  
%   flags - NNRCMP flags for the data (double) (to be used only with single variable inputs)
%
% Outputs:
%   var_fr - variable/s with flags removed (either nx1 double or nx11 table)

% NNRCMP Wave QC Data Quality Control Flags (as of January 2022)
% 
% Flag	Suspect Parameters          Not Suspect Parameters      Description
%	    
% 1	    Hs, Tz, Tp, Direction,      SST                         Either Hs or Tz fail,
%       Spread		                                            so all data fail, except SST
%
% 2	    Tp, Direction, Spread	    Hs, Tz, SST	                Tp fail + derivatives
%
% 3	    Direction, Spread	        Tp, Hs, Tz, SST	            Direction fail + derivatives
%
% 4	    Spread	                    Direction, Tp, Hs, Tz,      Spread fail
%                                   SST	
%
% 7		                            Hs, Tz, Tp, Direction,      Buoy off location
%                                   Spread, SST
%
% 8	    SST	                        Hs, Tz, Tp, Direction,      SST fail
%                                   Spread
%
% 9	    Hs, Tz, Tp, Direction,                                  Missing data
%       Spread, SST		

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    var
    nv.flags_to_del (1, :) double = [1, 2, 3, 4, 8, 9]
    nv.flags (:, 1) double = []
end

if isnumeric(var)
    if ~iscolumn(var) && ~isrow(var) || ~iscolumn(nv.flags) && ~isrow(nv.flags)
       error("Single variable inputs and flags must be nx1 arrays") 
    end
    if length(var) ~= length(nv.flags)
        error("Variable and flag arrays are not equally sized")
    end
    var(ismember(nv.flags, nv.flags_to_del)) = nan;
    var(ismember(var, 9999)) = nan;
elseif istable(var)
    if width(var) ~= 11
        error("Table input must match format of nnrcmp.load_wav output (nx11 table)") 
    end
    for flag = nv.flags_to_del
        switch flag
            case 1
                var{var.(4) == 1, 5:10} = nan;
            case 2
                var{var.(4) == 2, [7 9:10]} = nan;
            case 3
                var{var.(4) == 3, 9:10} = nan;
            case 4
                var{var.(4) == 4, 10} = nan;
            case 8
                var{var.(4) == 8, 11} = nan;
            case 9
                var{var.(4) == 9, 5:11} = nan;
        end
    end
    i = ismember(var{:, 2:end}, 9999);
    for col = 2:width(var)
        var{i(:, col - 1), col} = nan;
    end
end
var_fr = var;

% fini