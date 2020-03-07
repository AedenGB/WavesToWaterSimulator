close all;
%piston : in_tension? | angular offset | bore area
pistons =  [
            [false;0;1] [true;0;3.5]...
            [false;90;1] [true;90;3.5]...
            ];

C.stroke = 10;
C.piston_min_length = 11;
C.pressure = 1;

%with that combination of pistons, generate torque as a function of time
%with all combinations of cylinders on and off
output = simulate_config(pistons, C);
combinations = generate_combinations(output);

%plot all combinations and their means on a polar graph
for combination = transpose(combinations)
    plot_polar(transpose(combination));
    hold on;
end

%plot on cartesian coordinates
figure;
for combination = transpose(combinations)
    plot(transpose(combination));
    hold on;
end