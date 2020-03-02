C.stroke = 5;
C.pivot_distance = 10;%distance from the pivot point of the pistons to the crankshaft axis
C.range = 2*360;
C.pressure = 1;

%piston : in_tension? | angular offset | bore area
pistons =  [
            [false;0;1] [false;85;1]...
            [true;0;1] [true;85;1]...
            ];

total = zeros(C.range);
for piston = pistons
    total = total + generate_vector(C, piston(1), piston(2), piston(3));
end
plot([1:C.range],total);
