%generate a vector containing pump resistances at any given position
function vector = generate_vector(C, in_tension, angular_offset, bore_area)
    range = 360;
    vector = zeros(1,range);
    
    for angle = [1:range]
        vector(1,angle) = calculate_value(C.stroke,C.piston_min_length+C.stroke/2,in_tension,angle);
    end
    
    %shift function by angular offset
    vector = circshift(vector,angular_offset);
    
    vector = vector*bore_area*C.pressure;
end