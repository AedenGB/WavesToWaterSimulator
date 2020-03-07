%graph a circle of a specified radius on a polar plot
function graph_circle(radius)
    radian_range = 0:(2*pi)/360:2*pi;
    polarplot(radian_range, radius*ones(1,361));
end