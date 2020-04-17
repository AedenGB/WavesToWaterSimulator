resolution = 0.01;
range = 20;
t = [1:(range/resolution)]*resolution;
r_1 = 0.2;
r_2 = 3;
r_3 = 2;
hold on;
plot(sin(t));
plot(asin(sin(t)/r_2));

plot(sqrt(r_3^2  -  2*r_3*r_1*sin(t)/r_2  -  r_1^2));

legend('surge position',  'absorber angle', 'piston position');
hold off;