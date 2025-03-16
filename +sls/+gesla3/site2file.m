function filenames = site2file(site_names, metadata)
    % Function to get the name/s of GESLA files from the site name/s 
    % INPUT: 
    %    metadata -> path to the metadata 'GESLA3_ALL.csv'
    %    site_names -> name of individual site (string) or multiple sites (string array) 
    % OUTPUT:
    %    file_names -> name of individual file (string scalar) or multiple files (string array) 

    %... Luke Jenkins, May 2022...
    
    d = readtable(metadata);
    
    filenames = string(d.FILENAME(contains(d.SITENAME, site_names)));
    
    if isempty(filenames) % no sites found
        error(['No file name found for site name: ', char(site_names)])
        
    elseif ~isStringScalar(filenames)
        prompt = {strcat("-Site: ", string(d.SITENAME(contains(d.FILENAME, filenames))), " -Country: ",...
            string(d.COUNTRY(contains(d.FILENAME, filenames))), " -File: ", filenames)};
        dlgtitle = "Multiple files found: Select which file names you wish to output (Place '1' in dialogue box)";
        answer = inputdlg(prompt{:}, dlgtitle, [1 length(char(dlgtitle)) + 15]);
        filenames = filenames(~cellfun(@isempty, answer));

    end

end