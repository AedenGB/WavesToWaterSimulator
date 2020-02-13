%% Optimization

x0 = [0.08 * (0.0254), 100];
ceq = @(x)-get_efficiency(600, 0.01, 1 ,10 , x(1) , x(2) , 5.22, 104.2 * (2*pi/60), 3000);
x = fmincon(ceq,x0,[],[],[],[],[0.0001,10],[0.1,1000]);
x(1)
x(2)

set(gcf,'color','w');
hold on

[time_vector, graph_values_matrix] = simulate(600, 0.01, 1 ,10, x(1), x(2), 5.22, 104.2 * (2*pi/60), 3000);
plot(time_vector(1,:), graph_values_matrix(1,:));
yline(C.pump_minimum_angular_velocity*60/(2*pi));
xlabel('time elapsed (seconds)') 
ylabel('angular velocity (rpm)')
xlabel('time elapsed (seconds)') 
ylabel('displacement (meters) | angular velocity (rpm x 10)') 
title('Pump Angular Velocity vs Time for Various Pulley Radii');
hold off

%% Functions

function [steady_state_velocity] = get_efficiency(simulation_max_time, simulation_time_interval, ...
    wave_amplitude, wave_period, pulley_radius, flywheel_angular_moi, pump_torque_at_min_angular_velocity,...
    pump_minimum_angular_velocity, bouyancy_force_coefficient)
    
    [~, graph_values_matrix] = simulate(simulation_max_time, simulation_time_interval, ...
    wave_amplitude, wave_period, pulley_radius, flywheel_angular_moi, pump_torque_at_min_angular_velocity,...
    pump_minimum_angular_velocity, bouyancy_force_coefficient);
    

    a = int32(simulation_max_time/wave_period)*wave_period/simulation_time_interval;
    
    steady_state_velocity = graph_values_matrix(a);
end

function [time_vector, graph_values_matrix] = simulate(simulation_max_time, simulation_time_interval, ...
    wave_amplitude, wave_period, pulley_radius, flywheel_angular_moi, pump_torque_at_min_angular_velocity,...
    pump_minimum_angular_velocity, bouyancy_force_coefficient)

    C.simulation_max_time = simulation_max_time;
    C.simulation_time_interval = simulation_time_interval;
    C.wave_amplitude = wave_amplitude;
    C.wave_period  = wave_period;
    C.pulley_radius = pulley_radius;
    C.flywheel_angular_moi = flywheel_angular_moi;
    C.pump_torque_at_min_angular_velocity = pump_torque_at_min_angular_velocity;
    C.pump_minimum_angular_velocity = pump_minimum_angular_velocity;
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
    
    %pump torque is proportional to angular velocity^2
    pump_torque = C.pump_torque_at_min_angular_velocity*(angular_velocity_old/C.pump_minimum_angular_velocity)^2;
    
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