function fig_polar = plot_combinations(C,pistons,on_off_matrix)
    %with that combination of pistons, generate torque as a function of time
    %with selected combinations of cylinders on and off
    piston_vectors = simulate_config(pistons, C);
    if nargin == 2
        on_off_matrix = generate_combination_matrix(size(piston_vectors,1));
    end
    combinations = generate_combinations(piston_vectors,on_off_matrix);
    
    [on_off_matrix, combinations] = remove_duplicates(on_off_matrix, combinations);
    
    fig_polar = figure;
    %set(gcf,'color','w');
    %plot all combinations and their means on a polar graph
    num_combinations = size(combinations,1);
    colors = hsv(num_combinations);
    for i = 1:num_combinations
        radian_range = 0:(2*pi)/360:2*pi;
        combination_number = char(on_off_matrix(i,:)+48);
        %repeat first element to compensate for 0 vs 2pi position
        polarplot(radian_range, [combinations(i,:) combinations(i,1)],...
            'DisplayName',combination_number,'color',colors(i,:));
        hold on;
        polarplot(radian_range, mean(combinations(i,:))*ones(1,361),'LineWidth',1.5,...
            'DisplayName',[combination_number ' avg'],'color',colors(i,:));
    end
    legend;
end