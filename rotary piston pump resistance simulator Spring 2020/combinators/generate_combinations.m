%generate all additive combinations of individual piston torques, given a
%list of pistons
function combinations = generate_combinations(individual)
    num_vectors = size(individual,1);
    combinations = [];
    for i = 1:2^num_vectors-1
        on_off_vector = dec2bin(i, num_vectors)-48;
        combinations = [combinations ; on_off_vector * individual];
    end
end

