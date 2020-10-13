%% plot all or selected combinations, given a certain set of pistons
function [on_off_matrix, scaling_factor] = plot_combinations(C,pistons,on_off_matrix,targets)
    %with that combination of pistons, generate torque as a function of time
    %with selected combinations of cylinders on and off
    piston_vectors = simulate_config(pistons, C);
    if numel(on_off_matrix) == 0
        on_off_matrix = generate_combination_matrix(size(piston_vectors,1));
    end
    
    % generate matrix of combinations
    combinations = on_off_matrix*piston_vectors;
    
    if numel(targets) == 0
        [on_off_matrix, combinations] = remove_duplicates(on_off_matrix, combinations, 0.0001);
        scaling_factor = 0;
    else
        [on_off_matrix, combinations,scaling_factor] = fit_target_resistances(on_off_matrix, combinations, targets);
    end
    
    %figure;
    set(gcf,'color','w');
    %plot all combinations and their means on a polar graph
    num_combinations = size(combinations,1);
    colors = hsv(num_combinations);
    line_styles = ["-" "--" ":" "-."];
    radian_range = 0:(2*pi)/360:2*pi;
    legend_subset = zeros(1,num_combinations);
    for i = 1:num_combinations
        combination_number = char(on_off_matrix(i,:)+48);
        
        %repeat first element to compensate for 0 vs 2pi position
        polarplot(radian_range, [combinations(i,:) combinations(i,1)],line_styles(mod(i,numel(line_styles))+1),'color',colors(i,:));
        hold on;
        if numel(targets) ~= 0
           target_string = [' target = ' char(string(targets(i)))];
        else
            target_string = '';
        end
        legend_subset(i) = polarplot(radian_range, mean(combinations(i,:))*ones(1,361), line_styles(mod(i,numel(line_styles))+1), 'color',colors(i,:),'LineWidth',1.5,...
            'DisplayName',[combination_number ' mean = ' char(string(mean(combinations(i,:)))) target_string],'color',colors(i,:));
    end
    if numel(targets) ~= 0
        for target = targets
            polarplot(radian_range, mean(target)*ones(1,361),'LineWidth',2,...
            'DisplayName','Target','color','black');
        end
    end
    legend(legend_subset,'Location','NorthEastOutside','FontSize',7);
end