%% Constants
simulation_max_time_opt = 1500;
simulation_time_interval_opt = 0.1;

simulation_max_time_final = 1500;
simulation_time_interval_final = 0.01;

wave_amplitude = 1;
wave_period  = 10;

pump_torque_at_min_angular_velocity = 5.22;
pump_minimum_angular_velocity = 104.2 * (2*pi/60);

pump_torque = @(angular_velocity)(pump_torque_at_min_angular_velocity*(angular_velocity/pump_minimum_angular_velocity)^1.2);

bouyancy_force_coefficient = 3000;

%% Optimization
x0 = [0.01, 100];
ceq = @(x)-get_efficiency(simulation_max_time_opt, simulation_time_interval_opt, ...
    wave_amplitude, wave_period, x(1), x(2), pump_torque, bouyancy_force_coefficient);

x = fmincon(ceq,x0,[],[],[],[],[0.0001,1],[0.1,1000]);
x(1)
x(2)

set(gcf,'color','w');
hold on

[time_vector, graph_values_matrix] = simulate(simulation_max_time_final, simulation_time_interval_final, ...
    wave_amplitude, wave_period, x(1), x(2), pump_torque,...
    bouyancy_force_coefficient);
plot(time_vector(1,:), graph_values_matrix(1,:), 'DisplayName',...
    ['T =' num2str(wave_period),... 
     ' sec | A = ' num2str(wave_amplitude),... 
     ' m | R_{spool} = ', num2str(x(1)*100),... 
     ' cm | I_{flywheel} = ', num2str(int32(x(2))) ' kg m^2']);
yline(pump_minimum_angular_velocity*60/(2*pi), 'HandleVisibility','off');
xlabel('time elapsed (seconds)');
ylabel('angular velocity (rpm)');
xlabel('time elapsed (seconds)');
ylabel('angular velocity (rpm)');
title('Pump Angular Velocity vs Time');

legend('Location','southwest');

hold off
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