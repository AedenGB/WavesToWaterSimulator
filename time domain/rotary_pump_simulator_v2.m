%% Constants
C.simulation_max_time = 1000;%run for ___ seconds
C.simulation_time_interval = 0.001;%update simulation every ____ seconds

%wave properties
C.wave_amplitude = 1;
C.wave_period  = 10;

C.pulley_radius = 0.125 * (0.0254);%convert inches to meters
C.flywheel_angular_moi = 200;%moment of inertia of flywheel

%pump specs for 800 psi
C.pump_torque_at_min_angular_velocity = 5.22;
C.pump_minimum_angular_velocity = 104.2 * (2*pi/60);%convert to rad/s

%assume hooke's law model for buoy => ____Newtons of bouyancy force/meter displaced (bogus number right now)
C.bouyancy_force_coefficient = 3000;

%newton*m_per_radian
C.return_spring_coefficient = 0;

%scale graphed angular velocity values by 1/10 to fit on the graph better
C.plot_scaling_for_angular_velocity = 1/10;
%% Executing

%state variables
time = 0;
angular_velocity = 0;
linear_displacement = 0;

%graphing setup
number_of_variables = 4;
number_of_iterations = (C.simulation_max_time/C.simulation_time_interval)+1.0;
point_arrays = zeros(number_of_variables, number_of_iterations);
global graph_values;
graph_values = zeros(number_of_variables);

step = 1;
while(time < C.simulation_max_time)
    [time, angular_velocity, linear_displacement] = functions(time, angular_velocity, linear_displacement, C);
    step = step + 1;
    
    %graph values
    point_arrays(1, step) = time;%time values
    for i = 1:number_of_variables
        point_arrays(i+1, step) = graph_values(i);
    end
end

energy = sum(point_arrays(5,900:1000));
energy
%% plotting 
for i = 2:number_of_variables+1
    plot(point_arrays(1,1:number_of_iterations), point_arrays(i,1:number_of_iterations))
    hold on
end
yline(C.pump_minimum_angular_velocity*60/(2*pi)*C.plot_scaling_for_angular_velocity);
hold off
legend('angular velocity of pump', 'water surface height', 'linear displacement of buoy', 'power', 'minimum required rpm for pump');
xlabel('time elapsed (seconds)') 
ylabel('displacement (meters) | angular velocity (rpm x 10)') 

%% Functions
function [time, angular_velocity, linear_displacement] = functions(time_old, angular_velocity_old, linear_displacement_old, C)
    global graph_values;
    
    time = time_old + C.simulation_time_interval;
    
    water_surface_height = C.wave_amplitude * sin(time*pi/C.wave_period);
    
    %pump torque is proportional to angular velocity^2
    pump_torque = C.pump_torque_at_min_angular_velocity*(angular_velocity_old/C.pump_minimum_angular_velocity)^6;
    
    %if the line is slack, take up the slack
    linear_displacement = linear_displacement_old;
    no_force_flag = false;
    if(linear_displacement_old > water_surface_height) %pulley ratchets
        linear_displacement = water_surface_height;
        no_force_flag = true; %line is slack
    end
    
    %force increases proportional to distance the buoy is pulled into the water
    linear_force = C.bouyancy_force_coefficient * (water_surface_height - linear_displacement); 
    
    return_spring_torque = C.return_spring_coefficient*linear_displacement/C.pulley_radius;
    
    torque = cap_to_positive(C.pulley_radius*linear_force-return_spring_torque) - pump_torque; %only positive torque from mooring line 
    
    angular_velocity = angular_velocity_old + C.simulation_time_interval * (torque/C.flywheel_angular_moi);%update angular velocity
    
    if(~no_force_flag)%if there is force being exerted on the mooring line, update its position
        linear_displacement = linear_displacement_old + angular_velocity*(C.pulley_radius*2*pi)*C.simulation_time_interval;
    end
    graph_values(1) = angular_velocity*60/(2*pi)*C.plot_scaling_for_angular_velocity;
    graph_values(2) = water_surface_height;
    graph_values(3) = linear_displacement;
    graph_values(4) = pump_torque*angular_velocity/25;
end

function [value_capped] = cap_to_positive(value) %return a value if it is >0, otherwise, return 0
    if(value < 0)
        value_capped = 0; 
    else
        value_capped = value;
    end
end