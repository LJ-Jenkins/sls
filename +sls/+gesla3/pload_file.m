function data = pload_file(file, path, gflag_removal, cflag_removal, nworkers)
    % Function to load data from GESLA-3 files in parallel
    % INPUT: 
    %    file -> string scalar or array with name/s of the individual file/s in GESLA format
    %    path -> directory to where the GESLA data files are kept
    %    gflag_removal -> 'y' for removing values flagged by GESLA
    %    cflag_removal -> remove values by entering numbers that correspond to flags by the contributor (e.g., [2,4,5])
    %                      0 - no quality control
    %                      1 - correct value 
    %                      2 - interpolated value
    %                      3 - doubtful value
    %                      4 - isolated spike or wrong value
    %                      5 - missing value
    %    nworkers -> number of workers for the parallel for loop
    %
    % OUTPUT, struct 'data' containing for each site:
    %    ts -> time in datetime 
    %    sl -> tide gauge sea level measurements (with or w/o flag corrections)
    %    cont_fl -> flag - contributor flags
    %    gesla_fl -> flag - gesla checks, 0 = flagged value, 1 = correct value
    %    lat -> latitude
    %    lon -> longitude
    %    datum -> datum information
    %    gauge -> gauge type and information (e.g., 'bubbler - coastal')
    %    cont_fl_info -> flag information from the contributor to be used with cont_fl
    % 
    % Removes wrong values as defined in metadata
    % Removes NULL values as defined in metadata
    %... Marta Marcos and Ivan Haigh, September 2021... Amended Luke Jenkins, May 2022...
    
    arguments
        file string
        path (1, 1) string
        gflag_removal (1, 1) char {mustBeMember(gflag_removal, {'y', 'n'})}
        cflag_removal double
        nworkers (1, 1)
    end

    headerlength = 41;

    if endsWith(path, '\') || endsWith(path, '/')
        q = '';
    elseif contains(path, '\') && ~endsWith(path, '\')
        q = '\';
    elseif contains(path, '/') && ~endsWith(path, '/')
        q = '/';
    end
    
    if ischar(file)
        file = strtrim(string(file));
    end
    
    if ~isrow(file)
        file = file';
    end
    
    d = cell([size(file, 2), 1]);
    
    if isempty(gcp('nocreate')) && isnumeric(nworkers)
        parpool('local', nworkers); % start a pool with nworkers workers if no pool running
    end

    parfor i = 1:size(file, 2)
    
        %...Import data
        fid = fopen(strcat(path, q, file(i)), 'r');
        hd = cell(headerlength, 1);
        for ih = 1:headerlength
            hd(ih) = {fgetl(fid)};
        end
        d = textscan(fid, '%q %q %f %f %d');
        fclose(fid);
    
        %...Get datenum and datetime
        dt = datetime(d{:, 1}, 'Format', 'yyyy/MM/dd');
        dt.Format = 'yyyy/MM/dd HH:mm:ss';
        dt = dt + timeofday(datetime(d{:, 2}, 'Format', 'HH:mm:ss'));
        dn = datenum(dt);

        %...Read sea level observations 
        sl = cell2mat(d(3));
    
        % remove incorrect values (according to gesla flag)
        cont_fl = cell2mat(d(4));
        gesla_fl = cell2mat(d(5));
    
        if strcmp(gflag_removal, 'y')
            sl(gesla_fl == 0) = NaN;
        end 
    
        % remove incorrect values (according to contributor flags)
        ii = ismember(cont_fl, cflag_removal);
        sl(ii) = NaN;
    
        %...Read lat & lon
        lat = str2double(extractAfter(hd(~cellfun(@isempty, cellfun(@(x) strfind(x, 'LATITUDE'),...
            hd, 'UniformOutput', 0)), 1), '# LATITUDE'));
    
        lon = str2double(extractAfter(hd(~cellfun(@isempty, cellfun(@(x) strfind(x, 'LONGITUDE'),...
            hd, 'UniformOutput', 0)), 1), '# LONGITUDE'));
        
        %...Read metadata info
        datum = strtrim(string(extractAfter(hd(~cellfun(@isempty, cellfun(@(x) strfind(x, 'DATUM INFORMATION'),...
            hd, 'UniformOutput', 0)), 1), '# DATUM INFORMATION')));
    
        gauge = strcat(strtrim(string(extractAfter(hd(~cellfun(@isempty, cellfun(@(x) strfind(x, 'INSTRUMENT'),...
            hd, 'UniformOutput', 0)), 1), '# INSTRUMENT'))), " - ", ...
            strtrim(string(extractAfter(hd(~cellfun(@isempty, cellfun(@(x) strfind(x, 'GAUGE TYPE'),...
            hd, 'UniformOutput', 0)), 1), '# GAUGE TYPE'))));
    
        cont_fl_info = string(hd(find(string(hd(1:headerlength, 1)) ==...
            '# Quality-control (QC) flags for column 4'):headerlength, 1));
        
        % create cell and fill cell array
        tmp = {datenum(dt), sl, cont_fl, gesla_fl, lat, lon, datum, gauge, cont_fl_info};
        d{i} = tmp;
    
    end
    
    % fill struct now outside of parfor
    data = struct();
    for i = 1:size(d, 1)
        data.(strrep(file(i), '-', '_')).ts = d{i}{1}; 
        data.(strrep(file(i), '-', '_')).sl = d{i}{2};  
        data.(strrep(file(i), '-', '_')).cont_fl = d{i}{3};  
        data.(strrep(file(i), '-', '_')).gesla_fl = d{i}{4}; 
        data.(strrep(file(i), '-', '_')).lat = d{i}{5}; 
        data.(strrep(file(i), '-', '_')).lon = d{i}{6}; 
        data.(strrep(file(i), '-', '_')).datum = d{i}{7}; 
        data.(strrep(file(i), '-', '_')).gauge = d{i}{8}; 
        data.(strrep(file(i), '-', '_')).cont_fl_info = d{i}{9};
    end
end