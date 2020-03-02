%% Graphing
A.lb = 0.5;
A.step = 0.25;
A.ub = 2.5;

T.lb = 5;
T.step = 1;
T.ub = 15;

hold on
i = 1;
for a = [(A.lb/A.step):(A.ub/A.step)]
    for t = [(T.lb/T.step):(T.ub/T.step)]
        [r,~] = find_parameters(a,t);
        values_matrix(1,i) = a;
        values_matrix(2,i) = t;
        values_matrix(3,i) = r*1000;
        scatter3(a,t,r*1000,'filled','black');
        i = i+1;
        [a, t, r]
    end
end
%% Section
surf(values_matrix(1,:),values_matrix(2,:),values_matrix(3,:),'black');
hold off
%% Optimization
function [radius, moment_of_intertia] = find_parameters(wave_amplitude, wave_period)
    pump_torque_at_min_angular_velocity = 5.22;
    pump_minimum_angular_velocity = 104.2 * (2*pi/60);
    pump_torque = @(angular_velocity)(pump_torque_at_min_angular_velocity*(angular_velocity/pump_minimum_angular_velocity)^1.2);
    
    ceq = @(x)-get_efficiency(1500, 0.1, wave_amplitude, wave_period, x(1), x(2), pump_torque, 3000);
    x0 = [0.05, 100];
    x = fmincon(ceq,x0,[],[],[],[],[0.0001,1],[0.1,1000]);
    radius = x(1);
    moment_of_intertia = x(2);
end
%% Functions
function [steady_state_velocity] = get_efficiency(simulation_max_time, simulation_time_interval, ...
    wave_amplitude, wave_period, pulley_radius, flywheel_angular_moi, pump_torque, bouyancy_force_coefficient)
    
    [~, graph_values_matrix] = simulate(simulation_max_time, simulation_time_interval, ...
    wave_amplitude, wave_period, pulley_radius, flywheel_angular_moi, pump_torque, bouyancy_force_coefficient);
    

    a = (simulation_max_time - mod(simulation_max_time, wave_period))/simulation_time_interval;
    
    steady_state_velocity = graph_values_matrix(a);
end

function [time_vector, graph_values_matrix] = simulate(simulation_max_time, simulation_time_interval, ...
    wave_amplitude, wave_period, pulley_radius, flywheel_angular_moi, pump_torque, bouyancy_force_coefficient)

    C.simulation_max_time = simulation_max_time;
    C.simulation_time_interval = simulation_time_interval;
    C.wave_amplitude = wave_amplitude;
    C.wave_period  = wave_period;
    C.pulley_radius = pulley_radius;
    C.flywheel_angular_moi = flywheel_angular_moi;
    C.pump_torque = pump_torque;
    C.bouyancy_force_coefficient = bouyancy_force_coefficient;
    
    number_of_iterations = (C.simulation_max_time/C.simulation_time_interval);
    
    time_vector = zeros(1, number_of_iterations);
    graph_values_matrix = zeros(1, number_of_iterations);
    
    %state variables
    time = 0;
    angular_velocity = 0;
    linear_displacement = 0;
    step = 1;
    while(step < number_of_iterations)
        [time, angular_velocity, linear_displacement, graph_values_vector] = functions(time, angular_velocity, linear_displacement, C);
        step = step + 1;
        time_vector(1,step) = time;
        graph_values_matrix(step) = graph_values_vector;
    end   
end

function [time, angular_velocity, linear_displacement, graph_values_vector] = functions(time_old, angular_velocity_old, linear_displacement_old, C)
    time = time_old + C.simulation_time_interval;
    
    water_surface_height = C.wave_amplitude * sin(time*pi/C.wave_period);
    
    %pump torque
    pump_torque = C.pump_torque(angular_velocity_old);
    
    %force increases proportional to distance the buoy is pulled into the water
    linear_force = C.bouyancy_force_coefficient * (water_surface_height - linear_displacement_old); 
    
    torque = cap_to_positive(C.pulley_radius*linear_force) - pump_torque; %only positive torque from mooring line 
    
    angular_velocity = angular_velocity_old + C.simulation_time_interval * (torque/C.flywheel_angular_moi);%update angular velocity
    
    %if the line is slack, take up the slack
    if(linear_displacement_old > water_surface_height) %pulley ratchets
        linear_displacement = water_surface_height;  
    else %if there is force being exerted on the mooring line, update its position
        linear_displacement = linear_displacement_old + angular_velocity*(C.pulley_radius*2*pi)*C.simulation_time_interval;
    end
    
    graph_values_vector(1) = angular_velocity*60/(2*pi);
end

function [value_capped] = cap_to_positive(value) %return a value if it is >0, otherwise, return 0
    if(value < 0)
        value_capped = 0; 
    else
        value_capped = value;
    end
end