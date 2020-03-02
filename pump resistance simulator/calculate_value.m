%calculate level of resistance at any given point for any single piston
function value = calculate_value(stroke, pivot_distance, in_tension, angle) 
    radius = stroke/2;
    
    %calculate perpendicular lever arm adjusted for pivoting pistons
    value = radius*pivot_distance*sind(angle)/...
        ((radius^2 + pivot_distance^2 - 2*radius*pivot_distance*cosd(angle))^(1/2));
    
    %if the piston is only active in tension, drop the resistance values
    %for compression
    if (in_tension && value < 0) || (~in_tension && value > 0)
        value = 0;
    else
        value = abs(value);
    end
end