%% Global Optimizer
A = [0.5:0.5:2.5];
T = [5:2.5:15];

R = ones(numel(T),numel(A));
I = ones(numel(T),numel(A));

A = ones(numel(T),1)*A;
T = transpose(ones(size(A,2),1)*T);

size(A,2)
size(T,1)

hold on
for a_i = 1:size(A,2)
    for t_i = 1:size(T,1)
        a = A(1,a_i);
        t = T(t_i,1);
        [r,i] = find_parameters(a,t);
        R(t_i,a_i) = r;
        I(t_i,a_i) = i;
        [a,t,r,i]
    end
end

%% Graph Global Optomizer
set(gcf,'color','w');
surf(A,T,R,'EdgeColor','black','FaceColor','black','FaceAlpha', 0.5);
xlabel('A_{wave} (m)'); 
ylabel('T_{wave} (s)'); 
zlabel('Ideal R_{spool}');

figure;
set(gcf,'color','w');
surf(A,T,I,'EdgeColor','black','FaceColor','black','FaceAlpha', 0.5);
xlabel('A_{wave} (m)'); 
ylabel('T_{wave} (s)'); 
zlabel('Ideal I_{flywheel}');
%% Specific Conditions
a = 1;
t = 10;
[r,i] = find_parameters(a,t);

set(gcf,'color','w');

pump_torque_at_min_angular_velocity = 5.22;
pump_minimum_angular_velocity = 104.2 * (2*pi/60);
pump_torque = @(angular_velocity)(pump_torque_at_min_angular_velocity*(angular_velocity/pump_minimum_angular_velocity)^1.2);

[time_vector, graph_values_matrix] = simulate(1000, 0.1, a, t, r, i, pump_torque, 3000);
plot(time_vector(1,:), graph_values_matrix(1,:), 'DisplayName',...
    ['T =' num2str(t),... 
     ' sec | A = ' num2str(a),... 
     ' m | R_{spool} = ', num2str(r*100),... 
     ' cm | I_{flywheel} = ', num2str(int32(i)) ' kg m^2']);
yline(pump_minimum_angular_velocity*60/(2*pi), 'HandleVisibility','off');
xlabel('time elapsed (seconds)');
ylabel('angular velocity (rpm)');
xlabel('time elapsed (seconds)');
ylabel('angular velocity (rpm)');
title('Pump Angular Velocity vs Time');

legend('Location','southwest');

hold off
%% Functions
function [radius, moment_of_intertia] = find_parameters(wave_amplitude, wave_period)
    pump_torque_at_min_angular_velocity = 5.22;
    pump_minimum_angular_velocity = 104.2 * (2*pi/60);
    pump_torque = @(angular_velocity)(pump_torque_at_min_angular_velocity*(angular_velocity/pump_minimum_angular_velocity)^1.2);
    
    ceq = @(x)-get_efficiency(1500, 0.1, wave_amplitude, wave_period, x(1), x(2), pump_torque, 3000);
    x0 = [0.008, 120];%0.008, 100
    x = fmincon(ceq,x0,[],[],[],[],[0.0001,1],[0.1,1000]);
    radius = x(1);
    moment_of_intertia = x(2);
end
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