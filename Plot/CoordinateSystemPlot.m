classdef CoordinateSystemPlot < handle
	properties
		% Data
		x_axis_direction;
		y_axis_direction;
		z_axis_direction;
		origin;

		% Plot Objects
		x_line;
		y_line;
		z_line;
		plot_parent;
	end%properties
	methods
		function obj = CoordinateSystemPlot(origin,x_direction,y_direction,z_direction)
			if(length(x_direction) ~= 3)
				fprintf('CoordinateSystemPlot::CoordinateSystemPlot: X Direction not 1x3 vector\n');
				return;
			end%if
			if(length(y_direction) ~= 3)
				fprintf('CoordinateSystemPlot::CoordinateSystemPlot: Y Direction not 1x3 vector\n');
				return;
			end%if
			if(length(z_direction) ~= 3)
				fprintf('CoordinateSystemPlot::CoordinateSystemPlot: Z Direction not 1x3 vector\n');
				return;
			end%if
			if(length(origin) ~= 3)
				fprintf('CoordinateSystemPlot::CoordinateSystemPlot: Origin not 1x3 vector\n');
				return;
			end%if

			obj.x_axis_direction = x_direction' ./ norm(x_direction);
			obj.y_axis_direction = y_direction' ./ norm(y_direction);
			obj.z_axis_direction = z_direction' ./ norm(z_direction);
			obj.origin = origin;
		end%func Constructor

		function obj = Plot(obj,plot_parent,line_length)
			if(~isa(plot_parent,'matlab.graphics.axis.Axes'))
				fprintf('CoordinateSystemPlot::Plot: Input 1 not axes\n');
				return;
			end%if

			obj.plot_parent = plot_parent;

			x_start = obj.origin;
			x_end = x_start + (obj.x_axis_direction .* line_length);
			obj.x_line = line([x_start(1),x_end(1)],[x_start(2),x_end(2)],[x_start(3),x_end(3)],...
				'parent',plot_parent,'color','r');

			y_start = obj.origin;
			y_end = y_start + (obj.y_axis_direction .* line_length);
			obj.y_line = line([y_start(1),y_end(1)],[y_start(2),y_end(2)],[y_start(3),y_end(3)],...
				'parent',plot_parent,'color','g');

			z_start = obj.origin;
			z_end = z_start + (obj.z_axis_direction .* line_length);
			obj.z_line = line([z_start(1),z_end(1)],[z_start(2),z_end(2)],[z_start(3),z_end(3)],...
				'parent',plot_parent,'color','b');
		end%func Plot
	end%methods
end%class CoordinateSystemPlot