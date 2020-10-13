% choose combinations with rms error as fitness to fit vector of target resitsantces
function [on_off_matrix_new, combinations_new, scaling_factor] = fit_target_resistances(on_off_matrix, combinations, targets)
    combinations_new = zeros(size(targets,2),size(combinations,2));
    on_off_matrix_new = zeros(size(targets,2),size(on_off_matrix,2));
    
    max_resistance = max((mean(combinations,2)));
    max_target = max(targets);
    
    scaling_factor = max_target/max_resistance;
    
    combinations = combinations*scaling_factor;
    for i = 1:numel(targets)
        best_index = -1;
        for j = 1:size(combinations,1)
            if best_index == -1 || rms_error(targets(i),combinations(j,:)) < rms_error(targets(i),combinations(best_index,:))
                best_index = j;
            end
        end
        on_off_matrix_new(i,:) = on_off_matrix(best_index,:);
        combinations_new(i,:) = combinations(best_index,:);
    end
end

function rms = rms_error(ideal, vector)
    rms = sum((vector - ideal).^2);
end