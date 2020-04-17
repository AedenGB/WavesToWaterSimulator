%generate all additive combinations of individual piston torques, given a
%list of pistons
function combination_matrix = generate_combination_matrix(num_vectors)
    combination_matrix = [];
    for i = 1:2^num_vectors-1
        on_off_vector = dec2bin(i, num_vectors)-48;
        combination_matrix = [combination_matrix ; on_off_vector];
    end
end

