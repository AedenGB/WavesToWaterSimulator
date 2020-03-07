function plot_polar(vector)
    radian_range = 0:(2*pi)/360:2*pi;
    polarplot(radian_range, [vector vector(1,1)]);%repeat first element to compensate for 0 vs 2pi position
    hold on;
    graph_circle(mean(vector));
end
