function [fig_polar, fig_cartesian] = plot_combinations(C,pistons,on_off_matrix)
    %with that combination of pistons, generate torque as a function of time
    %with selected combinations of cylinders on and off
    output = simulate_config(pistons, C);
    if nargin == 2
        combinations = generate_combinations(output);
    else
        combinations = generate_combinations_manual(output,on_off_matrix);
    end
    
    fig_polar = figure;
    set(gcf,'color','w');
    %plot all combinations and their means on a polar graph
    for graph = transpose(combinations)
        plot_polar(transpose(graph));
        hold on;
        graph_circle(mean(transpose(graph)));
    end

    %plot on cartesian coordinates
    fig_cartesian = figure;
    set(gcf,'color','w');
    for graph = transpose(combinations)
        plot(transpose(graph));
        hold on;
    end
end