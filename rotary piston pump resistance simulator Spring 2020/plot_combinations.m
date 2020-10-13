%% plot all or selected combinations, given a certain set of pistons
function [on_off_matrix, scaling_factor] = plot_combinations(C,pistons,on_off_matrix,targets,cartesian)
    %with that combination of pistons, generate torque as a function of time
    %with selected combinations of cylinders on and off
    
    %convert to column vector
    targets = transpose(targets);
    
    %wrap different plotters for polar or cartesian coordinates
    if cartesian
        plotter = @(varargin) plot(varargin{:});
    else
        plotter = @(varargin) polarplot(varargin{:});
    end
    
    %create piston vectors
    piston_vectors = simulate_config(pistons, C);
    
    % assign on_off_matrix to all combinations if not set
    if numel(on_off_matrix) == 0
        on_off_matrix = generate_combination_matrix(size(piston_vectors,1));
    end
    
    %create combination resistance matrix
    combinations = on_off_matrix*piston_vectors;
    
    %if targets, fit targets; if no targets, remove duplicate combinations
    if numel(targets) == 0
        [on_off_matrix, combinations] = remove_duplicates(on_off_matrix, combinations, 0.0001);
        scaling_factor = 0;
    else
        [on_off_matrix, combinations,scaling_factor] = fit_target_resistances(on_off_matrix, combinations, targets);
    end
    
    %set up plot
    plotter(0,0);%dummy plot to edit settings
    set(gcf,'color','w');
    set(gca,'linestyleorder',{'-',':','-.','--'},...
        'colororder',[0 0 1;0 .5 0;1 0 0],'nextplot','add');
    
    %uncomment for greyscale graphs
    %set(gca, 'ColorOrder', [0 0 0; 0.5 0.5 0.5]);
    
    %plot setup
    num_combinations = size(combinations,1);
    combination_means = mean(combinations,2);
    radian_range = 0:(2*pi)/360:2*pi;
    
    %plot combinations
    figs = plotter(radian_range, [combinations combinations(:,1)]);
    
    %create legend
    legend_text = [char(on_off_matrix+48) ...
        repmat(' mean=', num_combinations,1) num2str(combination_means,'%.2f')];
    
    if numel(targets) ~= 0
        legend_text = [legend_text repmat(' target=', num_combinations,1) num2str(targets,'%.2f')];
        
        %plot targets
        hold on
        plotter(radian_range, targets*ones(1,361),'-.','LineWidth',2,'Color','Black','HandleVisibility','off');
    end
    
    legend(figs,legend_text,'Location','NorthEastOutside','AutoUpdate','on');%,'FontSize',7
    hold on;
end