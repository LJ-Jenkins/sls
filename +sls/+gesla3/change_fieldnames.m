function data = change_fieldnames(data, metadata)
    % Function change the field names in an output data struct to different GESLA format
    % INPUT: 
    %    data -> 3 data struct output from one of above functions
    %    metadata -> directory and filename for the metadata
    %    Pop up options:
    %                 'site' for GESLA site names
    %                 'country' for country (MUST BE USED IN CONJUCTION WITH SITE AND/OR CODE e.g., 'site country')
    %                 'cont' for abbreviated contributor (MUST BE USED IN CONJUCTION WITH SITE AND/OR CODE e.g., 'site code country cont')
    %                 'code' for GESLA site codes - some codes start with numbers so therefore have to be used in conjuction and at end
    %
    % OUTPUT, struct 'data' with new field names
    %... Luke Jenkins, May 2022

    md = readtable(metadata);

    dfields = string(strrep(fieldnames(data), '_', ''));
    files = string(replace(md.FILENAME, {'_', '-'}, {''}));

    options = {string(md.SITENAME(contains(files, dfields)));...
        string(md.COUNTRY(contains(files, dfields)));...
        string(md.CONTRIBUTOR_ABBREVIATED_(contains(files, dfields)));...
        string(md.SITECODE(contains(files, dfields)))};

    prompt = {"site name", "country", "contributor (abbreviated)", "site code"};
    dlgtitle = "Select new field names (Place '1' in dialogue box)";
    answer = inputdlg(prompt, dlgtitle, [1 length(char(dlgtitle)) + 35]);

    options = options(~cellfun(@isempty, answer));
    new_names = strings();

    for i = 1:length(options)
        switch i
            case 1
                new_names = append(new_names, string(options{i}));
            otherwise
                new_names = append(new_names, "_", string(options{i}));
        end
    end
    
    data = cell2struct(struct2cell(data), new_names);
    
end