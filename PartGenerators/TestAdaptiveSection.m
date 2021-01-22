clc, close all, clear all

n_points = 50;

% h_max = 2.75;
% h_min = 2.25;

h_max = 4;
h_min = 1;

radius = h_max / (pi/(2*n_points));

% Generate test circle section
angle_samples = linspace(-1*pi/2,0,n_points);
x_external = radius .* sin(angle_samples);
y_external = radius .* cos(angle_samples);

f = PlotTools.CreateCenteredFigure(560,500);
hold on;
line([0,x_external(1)],[0,y_external(1)],'color','k');

% Algorithm parameters
buffer = 2; % indices

% Calculate subsets
for i = 2:n_points
	prev_x = linspace(0,x_external(i-1),n_points);
	prev_y = linspace(0,y_external(i-1),n_points);
	line_x = linspace(0,x_external(i),n_points);
	line_y = linspace(0,y_external(i),n_points);

	j = 1;
	d = 0;
	while d < h_min
		dx = (line_x(j) - prev_x(j))^2;
		dy = (line_y(j) - prev_y(j))^2;
		d = sqrt(dx + dy);

		if(j >= n_points)
			break;
		end%if

		j = j + 1;
	end%while

	% Update boundary

	% Plot
	line([0,x_external(i)],[0,y_external(i)],'color',[0.75,0.75,0.75]);
	line([line_x(j),x_external(i)],[line_y(j),y_external(i)],'color','k');
end%for i

hold off;

% % Plot
% f = PlotTools.CreateCenteredFigure(560,500);
% % plot(x_external,y_external,'ko');
% hold on;
% for i = 1:n_points
% 	line([0,x_external(i)],[0,y_external(i)],'color',[0.5,0.5,0.5]);
% end%for i
% for i = 1:1
% 	line([line_x(j),x_external(end)],[line_y(j),y_external(end)],'color','k');
% end%for i
% hold off;

grid on;
xlabel('X (mm)');
ylabel('Y (mm)');