%make array of vectors, one for each piston accross 360 degrees
function individual = simulate_config(pistons, C)
    individual = [];
    for piston = pistons
        vector = generate_vector(C, piston(1), piston(2), piston(3));
        individual = [individual; vector];
    end
end

