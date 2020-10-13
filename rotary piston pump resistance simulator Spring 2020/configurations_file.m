%% Setup
add_paths
C.stroke = 10;
C.piston_min_length = 11;
C.pressure = 1;
m = 3.5;%factor for compression vs extension stroke sizes

%% Testing
pistons =  [
            [false;0;1] [true;0;m]...
            [false;90;1] [true;90;m]...
            [false;180;1] [true;180;m]...
            [false;270;1] [true;270;m]...
            ];


on_off_matrix = [0 1 0 1;...
                 0 1 1 1;...
                 1 1 1 1;...
                 ];

plot_combinations(C,pistons,[],[],true);


%% Big Study
%close all
targets = [1 2 3 4];
cartesian = false;
if cartesian
    subplot = @(m,n,p) subtightplot (m, n, p, [0.08 0.02], [0.04 0.03], [0.02 0.01]);
else
    subplot = @(m,n,p) subtightplot (m, n, p, [0 0.03], [0 0], [0.02 0.01]);
end


% 2 single acting
subplot(2, 3, 1);
pistons =  [
            [false;0;1]...
            [false;180;1]...
            ];

plot_combinations(C,pistons,[],targets,cartesian);
title("2 Single Acting");

% 2 double acting
subplot(2, 3, 4);
pistons =  [
            [false;0;1] [true;0;m]...
            [false;180;1] [true;180;m]...
            ];

plot_combinations(C,pistons,[],targets,cartesian);
title("2 Double Acting");

% 3 single acting
subplot(2, 3, 2);
pistons =  [
            [false;0;1]...
            [false;120;1]...
            [false;240;1]...
            ];

plot_combinations(C,pistons,[],targets,cartesian);
title("3 Single Acting");

% 3 double acting
subplot(2, 3, 5);
pistons =  [
            [false;0;1] [true;0;m]...
            [false;120;1] [true;120;m]...
            [false;240;1] [true;240;m]...
            ];

plot_combinations(C,pistons,[],targets,cartesian);
title("3 Double Acting");

% 4 single acting
subplot(2, 3, 3);
pistons =  [
            [false;0;1]...
            [false;90;1]...
            [false;180;1]...
            [false;270;1]...
            ];

plot_combinations(C,pistons,[],targets,cartesian);
title("4 Single Acting");

% 4 double acting
subplot(2, 3, 6);
pistons =  [
            [false;0;1] [true;0;m]...
            [false;90;1] [true;90;m]...
            [false;180;1] [true;180;m]...
            [false;270;1] [true;270;m]...
            ];

plot_combinations(C,pistons,[],targets,cartesian);
title("4 Double Acting");
