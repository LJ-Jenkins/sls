function tidy_downloads(files_directory, out_directory, nv)
% bodc.tidy_downloads - tidies a list of BODC UKNTGN files into folders of sites, 
%                       each containing relevant files. Works for data from primary
%                       channel, values + residuals, surges and extremes. Existing files
%                       are overwritten
%
% Inputs:
%   files_directory - where the downloaded files are kept
%   out_directory - where the tidied folders and files should go
% -name value arguments-
%   'sem' - 'm' or 'd' to move or delete the 'surges.txt', 'extremes.txt' and 'means.txt' files
%   'html' - 'm' or 'd' to move or delete the .html files (for each site)
%   'pdf' - 'm' or 'd' to move or delete the .pdf files (user agreement and format)
%-- 'm' (move) is default for all name-value arguments --%

% Luke Jenkins Jan 2024
% L.Jenkins@soton.ac.uk

arguments
    files_directory (1, 1) string
    out_directory (1, 1) string
    nv.sem (1, 1) char {mustBeMember(nv.sem, {'m', 'd'})} = 'm'
    nv.html (1, 1) char {mustBeMember(nv.html, {'m', 'd'})} = 'm'
    nv.pdf (1, 1) char {mustBeMember(nv.pdf, {'m', 'd'})} = 'm'
end

file_list = sls.fnames(files_directory); %-- get the file names
pdfs = file_list(contains(file_list, '.pdf'));
file_list(~contains(file_list, '.txt')) = []; %-- ignore files that aren't .txt
sem = {'surges', 'extremes', 'means'};
if any(contains(file_list, sem)) 
    tmp = file_list(contains(file_list, sem));
    file_list(contains(file_list, sem)) = []; %-- ignore sem files
    for mfile = tmp
        if nv.sem == 'm'
            movefile(files_directory + mfile, out_directory)
        elseif nv.sem == 'd'
            delete(files_directory + mfile)
        end
    end
end
site_code_list = erase(file_list, [string(0:10), ".txt"]); %-- create second file list without numbers (other option: regexprep(file_list,'[\d"]',''); )
u_sites = unique(site_code_list); %-- unique sites

for site = u_sites
    if exist(out_directory + site, 'dir') ~= 7 %-- check if site folder exists
        mkdir(out_directory + site) %-- make folder if not
    end
    files2move = file_list(contains(file_list, site)); %-- get list of files to move
    for mfile = files2move
        movefile(files_directory + mfile, out_directory + site) %-- move the files
    end

    if nv.html == 'm'
        movefile(files_directory + site + ".html", out_directory + site)
    elseif nv.html == 'd'
        delete(files_directory + site + ".html")
    end
end

%.. pdfs
for mfile = pdf
    if nv.pdf == 'm'
        movefile(files_directory + mfile, out_directory)
    elseif nv.pdf == 'd'
        delete(files_directory + mfile)
    end
end

% fini