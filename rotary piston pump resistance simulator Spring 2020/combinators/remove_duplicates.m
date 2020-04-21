function [on_off_matrix_new, combinations_new] = remove_duplicates(on_off_matrix, combinations)
    combinations_new = zeros(0,size(combinations,2));
    on_off_matrix_new = zeros(0,size(combinations,2));
    %find parameters fo each combination
    avg_vector = transpose(mean(transpose(combinations)))
    std_vector = transpose(std(transpose(combinations)))
    
    num_combinations = size(combinations,1);
    for i = 1:num_combinations
        if std_vector(i) ~=Inf%%have we looked at vectors with this average before
            lowest_std_index = i;
            for j = i+1:num_combinations
                if avg_vector(j) == avg_vector(lowest_std_index)%do they represent same avg resistance
                    if std_vector(j) >= std_vector(lowest_std_index) %%are vectors just circshifted twins, or is this one more erratic
                        std_vector(j) = Inf;
                    else
                        std_vector(lowest_std_index) = Inf;
                        lowest_std_index = j;
                    end
                end
            end
            std_vector(lowest_std_index) = Inf;
            on_off_matrix_new = [on_off_matrix_new; on_off_matrix(lowest_std_index,:)];
            combinations_new = [combinations_new; combinations(lowest_std_index,:)];
        end
    end 
end