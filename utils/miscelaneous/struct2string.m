function strings = struct2string(struc, with_fields)

if nargin < 2
    with_fields = 0;
end

fields = fieldnames(struc);

for i = 1:length(struc)
    
    celo = struct2cell(struc(i));
    
    string_cell = cellfun(@(x) string(x), celo);
    string_cell = strcat(string_cell,",");
    string_cell{end} = string_cell{end}(1:end-1);
    
    if with_fields
        string_fields = cellfun(@(x) string(x), fields);
        string_fields = strcat(string_fields,":");
        n_strings(1:2:length(string_fields)*2-1) = string_fields;
        n_strings(2:2:length(string_fields)*2) = string_cell;
        string_cell = n_strings;
    end

    strings{i} = strjoin(string_cell,"  ");
      
end