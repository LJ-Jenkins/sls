function [t, varargout] = load_wav(sitecode, directory, nv)
% nnrcmp.load_wav - loads all NNRCMP qc wave data files in a directory
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
%   2nd - wave heights (m)
%   3rd - wave periods (s)
%   4th - flags

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
t = table('Size', [0, 11], 'VariableTypes', ["datetime", repmat("double", 1, 10)]);

%% Loop
for i = 1:length(files)
    if nv.dispfile == 'y'
        disp(files(i))
    end
    filein = fullfile(directory, files(i));
    T = readtable(filein, 'ReadVariableNames', false);
    t = [t; T];
end
t = renamevars(t, 1:width(t), ["time", "lat", "lon", "flag", "Hs (m)", "Hmax (m)", ...
    "Tp (s)", "Tz (s)", "dirp (deg)", "spread (deg)", "sst (C)"]);

if nargout >= 2
    out = {t.time, t.("Hs (m)"), t.("Tp (s)"), t.flag};
    varargout = cell(nargout - 1, 1);
    for k = 2:nargout
        varargout{k - 1} = out{k - 1};
    end
end

% fini