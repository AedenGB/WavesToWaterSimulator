%% Constants
C.simulation_max_time = 1002;%run for ___ seconds
C.simulation_time_interval = 0.001;%update simulation every ____ seconds

%wave properties
C.wave_amplitude = 1;
C.wave_period  = 10;

C.flywheel_angular_moi = 100;%moment of inertia of flywheel

%pump specs for 800 psi
C.pump_torque_at_min_angular_velocity = 5.22;
C.pump_minimum_angular_velocity = 104.2 * (2*pi/60);%convert to rad/s

%assume hooke's law model for buoy => ____Newtons of bouyancy force/meter displaced
C.bouyancy_force_coefficient = 3000;

%% Executing

%state variables
time = 0;
angular_velocity = 0;
linear_displacement = 0;

%graphing setup
number_of_iterations = (C.simulation_max_time/C.simulation_time_interval);
global point_arrays;
point_arrays = zeros(5, number_of_iterations);

time = 0;
angular_velocity = 0;
linear_displacement = 0;
step = 1;
while(time <= C.simulation_max_time)
    [time, angular_velocity, linear_displacement] = functions(time, angular_velocity, linear_displacement, C , 0.5 * (0.0254));
    step = step + 1;
    
    point_arrays(1, step) = time;%time values
    point_arrays(2, step) = angular_velocity*60/(2*pi);
    point_arrays(5, step) = C.wave_amplitude * sin(time*pi/C.wave_period);
end

time = 0;
angular_velocity = 0;
linear_displacement = 0;
step = 1;

while(time <= C.simulation_max_time)
    [time, angular_velocity, linear_displacement] = functions(time, angular_velocity, linear_displacement, C , 0.75 * (0.0254));
    step = step + 1;
    point_arrays(3, step) = angular_velocity*60/(2*pi);
end

time = 0;
angular_velocity = 0;
linear_displacement = 0;
step = 1;

while(time <= C.simulation_max_time)
    [time, angular_velocity, linear_displacement] = functions(time, angular_velocity, linear_displacement, C , 1 * (0.0254));
    step = step + 1;
    point_arrays(4, step) = angular_velocity3*60/(2*pi);
end

%% plotting 
set(gcf,'color','w');
number_of_iterations
for i = 2:5
    plot(point_arrays(1,1:number_of_iterations), point_arrays(i,1:number_of_iterations));
    hold on
end
hold off
title(['T_{wave} = ' num2str(C.wave_period),... 
' sec  |  A_{wave} = ' num2str(C.wave_amplitude),... 
' m  |  R_{spool} = 0.50, 0.75, 1.00',... 
' m  |  I_{flywheel} = ', num2str(C.flywheel_angular_moi) ' kg m^2']);

legend('\omega_{pump}, r_{spool} = 0.5 in',...
    '\omega_{pump}, r_{spool} = 0.75 in',...
    '\omega_{pump}, r_{spool} = 0.1 in',...
    'water surface height', 'minimum required rpm for pump');
xlabel('time elapsed (seconds)') 
ylabel('displacement (meters) | angular velocity (rpm x 10)') 

%% Functions
function [time, angular_velocity, linear_displacement] = functions(time_old, angular_velocity_old, linear_displacement_old, C, pulley_radius)
    time = time_old + C.simulation_time_interval;
    
    water_surface_height = C.wave_amplitude * sin(time*pi/C.wave_period);
    
    %pump torque is proportional to angular velocity^2
    pump_torque = C.pump_torque_at_min_angular_velocity*(angular_velocity_old/C.pump_minimum_angular_velocity)^2;
    
    %force increases proportional to distance the buoy is pulled into the water
    linear_force = C.bouyancy_force_coefficient * (water_surface_height - linear_displacement_old); 
    
    torque = cap_to_positive(pulley_radius*linear_force) - pump_torque; %only positive torque from mooring line 
    
    angular_velocity = angular_velocity_old + C.simulation_time_interval * (torque/C.flywheel_angular_moi);%update angular velocity
    
    %if the line is slack, take up the slack
    if(linear_displacement_old > water_surface_height) %pulley ratchets
        linear_displacement = water_surface_height;  
    else %if there is force being exerted on the mooring line, update its position
        linear_displacement = linear_displacement_old + angular_velocity*(pulley_radius*2*pi)*C.simulation_time_interval;
    end
end

function [value_capped] = cap_to_positive(value) %return a value if it is >0, otherwise, return 0
    if(value < 0)
        value_capped = 0; 
    else
        value_capped = value;
    end
end