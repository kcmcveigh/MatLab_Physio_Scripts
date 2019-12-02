
%column is a list of strings must be in double quotes each corresponding to
%the columns you want to pull from shimmer
function [shimmer_data] = LoadConsensysData(file_name,columns)
% takes file to extra data from
    consensys_data = importdata(file_name);
    column_headers = consensys_data.textdata{2,1};
    column_array = strsplit(column_headers)
    num_rows = numel(consensys_data.data(:,1));
    num_columns = numel(columns);
    shimmer_data = nan(num_rows,num_columns);
    for i = 1:num_columns
        data_type_column = find(contains(column_array(:),columns(i)))
        shimmer_data(:,i) = consensys_data.data(:,data_type_column);
    end
    
end

