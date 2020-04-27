% choose combinations with rms error as fitness to fit vector of target resitsantces
function [on_off_matrix_new, combinations_new, scaling_factor] = fit_target_resistances_by_fitness(on_off_matrix, combinations, targets, tol)
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
            if lowest_std_index == -1 || rms_error(targets(i),std_vector(j)) < rms_error(targets(i),std_vector(lowest_std_index))
                lowest_std_index = j;
            end
        end
        assert(lowest_std_index ~= -1,'no combination found');
        on_off_matrix_new(i,:) = on_off_matrix(lowest_std_index,:);
        combinations_new(i,:) = combinations(lowest_std_index,:);
    end
end

function rms = rms_error(ideal, vector)
    rms = sum((vector - ideal).^2);
end