% choose combinations with low standard deviations to fit vector of target
% resitsantces. When possible, keep combination with lowest standard deviation
function [on_off_matrix_new, combinations_new, scaling_factor] = fit_target_resistances(on_off_matrix, combinations, targets, tol)
    combinations_new = zeros(size(targets,2),size(combinations,2));
    on_off_matrix_new = zeros(size(targets,2),size(on_off_matrix,2));
    %find parameters fo each combination
    avg_vector = transpose(mean(transpose(combinations)));
    std_vector = transpose(std(transpose(combinations)));
    
    max_resistance = max(avg_vector);
    max_target = max(targets);
    
    scaling_factor = max_target/max_resistance;
    
    targets = targets./scaling_factor;
    for i = 1:size(targets,2)
        lowest_std_index = -1;
        for j = 1:size(combinations,1)
            if abs(avg_vector(j) - targets(1,i))<tol% do they represent same avg resistance, within tolerance
                if lowest_std_index == -1 || std_vector(j) < std_vector(lowest_std_index)
                    lowest_std_index = j;
                end
            end
        end
        assert(lowest_std_index ~= -1,'no combination found with given tolerance');
        on_off_matrix_new(i,:) = on_off_matrix(lowest_std_index,:);
        combinations_new(i,:) = combinations(lowest_std_index,:);
    end
end