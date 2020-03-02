%generate a vector containing pump resistances at any given position
function vector = generate_vector(C, in_tension, angular_offset, bore_area)
    vector = zeros(C.range);
    hold on;
    for angle = [1:C.range]
        vector(angle) = calculate_value(C.stroke,C.pivot_distance,in_tension,angle);
    end
    
    vector = circshift(vector,angular_offset);
    vector = vector*bore_area*C.pressure;
    plot([1:C.range],vector);
end