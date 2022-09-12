function superkey = get_superkey_from_table_data(table_data,primary_key)
%concatenate key tables to get a single column for primary key


superkey = repmat({''},height(table_data),1);
for j=1:length(primary_key)
        this_key = table_data.(primary_key{j});
        if isnumeric(this_key)
            this_key = num2str(this_key);
        end
        superkey = strcat(superkey, '_', this_key);
end
superkey = categorical(superkey);


end

