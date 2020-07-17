function AdaptiveBeadHeight
	part_length = 5 * 25.4; % in -> mm
	part_height = 1 * 25.4; % in -> mm
	[x,y,z] = GenerateGauss(part_height,part_length);
	% [x,y,z] = GeneratePringle(6,2);

	normal_vector = [0,0,1];
	min_layer_height = 2.25;
	max_layer_height = 2.75;

	a = axes;
	PlotGauss(x,y,z,a);
	hold on;

	x2 = x;
	y2 = y;
	z2 = z;

	is_flat = false;
	i = 1;
	while(~is_flat)
		[x2,y2,z2,is_flat] = GenerateNextLayer(x2,y2,z2,normal_vector,min_layer_height,max_layer_height);
		PlotGauss(x2,y2,z2,a);
		i = i + 1;
	end%while

	n_layers_to_add = 2;
	for j = 1:n_layers_to_add
		[x2,y2,z2,is_flat] = GenerateNextLayer(x2,y2,z2,normal_vector,min_layer_height,max_layer_height);
		PlotGauss(x2,y2,z2,a);
		i = i + 1;
	end%for i

	fprintf('Number of layers: %i\n',i);

	hold off;
	grid on;
	SquareAxes3(a);
end%func AdaptiveBeadHeight

% Generators
function [x,y,z] = GeneratePringle(radius,z_offset)
	points = linspace(0,2*pi,100);
	x = radius .* sin(points);
	y = radius .* cos(points);
	z = z_offset .* sin(2 .* points);
end%func GeneratePringle

function [x,y,z] = GenerateGauss(height,wall_length)
	n_points = 50;
	l = wall_length / 2;
	x = linspace(-1*l,l,n_points);
	y = zeros(1,n_points);
	z = -1 .* height .* exp(-1 .* ((x ./ (l / 3)) .^ 2));
end%func GenerateGauss

function [x,y,z,is_flat] = GenerateNextLayer(prev_x,prev_y,prev_z,normal_vector,min_layer_height,max_layer_height)
	n_points = length(prev_x);

	% Preallocate
	x = zeros(1,n_points);
	y = x;
	z = x;

	[layer_min,layer_max] = GetLayerExtrema(prev_x,prev_y,prev_z);
	layer_range = layer_max - layer_min;
	
	layer_height_range = max_layer_height - min_layer_height;

	if(layer_height_range < layer_range)
		for i = 1:n_points
			x(i) = prev_x(i);
			y(i) = prev_y(i);

			height_ratio = 1 - ((prev_z(i) - layer_min) / (layer_range));
			z_shift = min_layer_height + (layer_height_range * height_ratio);
			z(i) = prev_z(i) + z_shift;
		end%for i

		is_flat = false;
	else
		x = prev_x;
		y = prev_y;
		z = (ones(1,n_points) .* max(prev_z)) + min_layer_height;
		is_flat = true;
	end%if
end%func GenerateNextLayer

% Analysis
function [min_height,max_height] = GetLayerExtrema(x,y,z)
	min_height = min(z);
	max_height = max(z);
end%func GetLayerExtrema

% Plotting
function PlotPringle(x,y,z,axes_handle)
	plot3(x,y,z,'k','parent',axes_handle);
end%func PlotPringle

function PlotGauss(x,y,z,axes_handle)
	plot(x,-1.*z,'k','parent',axes_handle);
end%func PlotPringle

function SquareAxes3(axes_handle)
	lim = [xlim(axes_handle),ylim(axes_handle),zlim(axes_handle)];
	axis_range = [min(lim),max(lim)];
	xlim(axes_handle,axis_range);
	ylim(axes_handle,axis_range);
	zlim(axes_handle,axis_range);
end%func SquareAxes3