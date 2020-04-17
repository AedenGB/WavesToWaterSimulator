close all;
%piston : in_tension? | angular offset | bore area
m = 3.5;
pistons =  [
            [false;0;m] [true;0;1]...
            [false;90;m] [true;90;1]...
            [false;180;m] [true;180;1]...
            [false;270;m] [true;270;1]...
            ];

C.stroke = 10;
C.piston_min_length = 11;
C.pressure = 1;

%with that combination of pistons, generate torque as a function of time
%with all combinations of cylinders on and off
output = simulate_config(pistons, C);
combinations = generate_combinations_manual(output);

set(gcf,'color','w');
%plot all combinations and their means on a polar graph
for graph = transpose(combinations)
    plot_polar(transpose(graph));
    hold on;
end

%plot on cartesian coordinates
figure;set(gcf,'color','w');
for graph = transpose(combinations)
    plot(transpose(graph));
    hold on;
end