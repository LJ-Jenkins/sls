function data = load_file(file, path, gflag_removal, cflag_removal, nv)
    % Function to load data in GESLA-3 files
    % INPUT: 
    %    file -> string scalar or array with name/s of the individual file/s in GESLA format
    %    path -> directory to where the GESLA data files are kept
    %    gflag_removal - > 'y' for removing values flagged by GESLA
    %    cflag_removal - > remove values by entering numbers that correspond to flags by the contributor (e.g., [2,4,5])
    %                      0 - no quality control
    %                      1 - correct value 
    %                      2 - interpolated value
    %                      3 - doubtful value
    %                      4 - isolated spike or wrong value
    %                      5 - missing value
    %    'parallel' -> 'y' or 'n' to use parallel for loop
    %    'nworkers' -> (optional) number of workers for the parallel for loop
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
        nv.parallel (1, 1) char {mustBeMember(nv.parallel, {'y', 'n'})} = 'n'
        nv.nworkers (1, 1) false 
    end

    if nv.parallel == 'y'

        data = sls.gesla3.pload_file(file, path, gflag_removal, cflag_removal, nv.nworkers);

    else

        headerlength = 41;
        data = struct();

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

        for i = file
            
            %...Import data
            fid = fopen(strcat(path, q, i), 'r');
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

            data.(strrep(i, '-', '_')).ts = dt; 
            data.(strrep(i, '-', '_')).sl = sl; 
            data.(strrep(i, '-', '_')).cont_fl = cont_fl; 
            data.(strrep(i, '-', '_')).gesla_fl = gesla_fl; 
            data.(strrep(i, '-', '_')).lat = lat; 
            data.(strrep(i, '-', '_')).lon = lon;
            data.(strrep(i, '-', '_')).datum = datum;
            data.(strrep(i, '-', '_')).gauge = gauge;
            data.(strrep(i, '-', '_')).cont_fl_info = cont_fl_info;

        end

    end
    
end