%generate all additive combinations of individual piston torques
function combinations = generate_combinations_manual(individual, on_off_matrix)
    combinations = on_off_matrix*individual;
end

