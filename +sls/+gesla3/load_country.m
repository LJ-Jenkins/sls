function data = load_country(country, path, metadata, gflag_removal, cflag_removal, nv)
    % Function to load data in GESLA-3 files from specific country
    % INPUT: 
    %    country -> 3 letter country code used in GESLA, e.g. 'GBR' or 'JPN'
    %               takes as many country codes as you give as either string or char array
    %    path -> directory to where the GESLA data files are kept
    %    metadata -> directory and filename for the metadata
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
    %... Luke Jenkins, May 2022

    arguments
        country string
        path string
        metadata string
        gflag_removal (1, 1) char {mustBeMember(gflag_removal, {'y', 'n'})}
        cflag_removal double
        nv.parallel (1, 1) char {mustBeMember(nv.parallel, {'y', 'n'})} = 'n'
        nv.nworkers (1, 1) false 
    end

    md = readtable(metadata);

    filenames = string(md.FILENAME(contains(md.COUNTRY,string(country))));

    if nv.parallel == 'y'

        data = sls.gesla3.pload_file(filenames, path, gflag_removal, cflag_removal, nv.nworkers);

    else

        data = sls.gesla3.load_file(filenames, path, gflag_removal, cflag_removal);

    end

end