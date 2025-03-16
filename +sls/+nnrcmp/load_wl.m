function [t, varargout] = load_wl(sitecode, directory, nv)
% nnrcmp.load_wl - loads all NNRCMP water level data files in a directory
%
% Inputs:
%   sitecode - NNRCMP three letter sitecode, does not use files without this 
%              code in the filename (case sensitive)
%   directory - where the NNRCMP text files are stored (must have original names
%               and therefore be in date order)
% -name-value arguments-
%   'dispfile' - (default) 'n' or 'y' to show file currently being loaded
%
% Outputs:
%   t - table of all variables and times
% Optional (in order):
%   1st - times (datetime)
%   2nd - water levels (ordnance datum) (m)
%   3rd - water levels (chart datum) (m)
%   4th - residual (m)
%   5th - flags

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

arguments
    sitecode string {mustBeTextScalar}
    directory string {mustBeTextScalar}
    nv.dispfile (1, 1) char {mustBeMember(nv.dispfile, {'y', 'n'})} = 'n'
end

if ~endsWith(directory, ["\", "/"]) && contains(directory, "\")
    directory = directory + "\";
elseif ~endsWith(directory, ["\", "/"]) && contains(directory, "/")
    directory = directory + "/";
end

%% File arrangement
files = string(extractfield(dir(fullfile(directory, '*.txt')), 'name'));
files = files(contains(files, sitecode));

%% Preallocate
t = table('Size', [0, 5], 'VariableTypes', ["datetime", repmat("double", 1, 4)]);

%% Loop
for i = 1:length(files)
    if nv.dispfile == 'y'
        disp(files(i))
    end
    filein = fullfile(directory, files(i));
    T = readtable(filein, 'ReadVariableNames', false);
    t = [t; T];
end
t = renamevars(t, 1:width(t), ["time", "wl (OD)", "wl (CD)", "residual (m)", "flag"]);

if nargout >= 2
    varargout = cell(nargout - 1, 1);
    for k = 2:nargout
        varargout{k - 1} = t.(k - 1);
    end
end

% fini