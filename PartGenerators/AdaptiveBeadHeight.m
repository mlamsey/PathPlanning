function AdaptiveBeadHeight
	close all;
	% normal_vector = [0,0,1];
	min_layer_height = 2.25;
	max_layer_height = 2.75;

	% Gaussian part
	part_length = 5 * 25.4; % in -> mm
	lump_height = 1 * 25.4; % in -> mm

	% GenerateGaussPart(lump_height,part_length,min_layer_height,max_layer_height);

	layer = GenerateGaussLayer(lump_height,part_length);
	PlotLayer(layer);

	% Pringle part 1
	part_radius = 3 * 25.4; % in -> mm
	part_perturbation = 1 * 25.4; % in -> mm
	n_perturbations = 4;

	% PringleSpiral(part_perturbation,part_radius,n_perturbations,min_layer_height,max_layer_height);

	% GeneratePringlePart(part_perturbation,part_radius,n_perturbations,min_layer_height,max_layer_height);

end%func AdaptiveBeadHeight

function GenerateGaussPart(lump_height,part_length,min_layer_height,max_layer_height)

	fprintf('Generating Gaussian perturbation with height %1.3fmm and length %1.3fmm\n',lump_height,part_length);
	fprintf('Minimum layer height: %1.3fmm; Maximum layer height: %1.3fmm\n',min_layer_height,max_layer_height);

	normal_vector = [0,0,1];

	[x0,y0,z0] = GenerateGauss(lump_height,part_length);

	[x,y,z] = InterpolateToFlat(x0,y0,z0,normal_vector,min_layer_height,max_layer_height);

	% Flip z
	z = z .* -1;

	% Move part to zero z
	z = z - min(z(end,:));

	PlotGauss(x,y,z);

end%func GenerateGaussPart

function GenerateGaussLayerPart(lump_height,part_length,min_layer_height,max_layer_height)

	fprintf('Generating Gaussian perturbation with height %1.3fmm and length %1.3fmm\n',lump_height,part_length);
	fprintf('Minimum layer height: %1.3fmm; Maximum layer height: %1.3fmm\n',min_layer_height,max_layer_height);

	normal_vector = [0,0,1];

	layer = GenerateGaussPoints(lump_height,part_length);

	layers = InterpolateLayersToFlat(layer,min_layer_height,max_layer_height);

	PlotGaussLayers(layers);

end%func GenerateGaussLayerPart

function GeneratePringlePart(deviation_height,part_radius,n_perturbations,min_layer_height,max_layer_height)
	fprintf('Generating "Pringle" profile with height %1.3fmm and radius %1.3fmm\n',deviation_height,part_radius);
	fprintf('Minimum layer height: %1.3fmm; Maximum layer height: %1.3fmm\n',min_layer_height,max_layer_height);

	normal_vector = [0,0,1];

	[x0,y0,z0] = GeneratePringle(part_radius,deviation_height,n_perturbations);
	n_points = length(x0);

	[x,y,z] = InterpolateToFlat(x0,y0,z0,normal_vector,min_layer_height,max_layer_height);

	% Flip z
	z = z .* -1;

	% Move part to zero z
	z = z - min(z(end,:));

	PlotPringle(x,y,z);

end%func GeneratePringlePart

function PringleSpiral(deviation_height,part_radius,n_perturbations,min_layer_height,max_layer_height)

	[x0,y0,z0] = GeneratePringle(part_radius,deviation_height,n_perturbations);

	step = min_layer_height;
	n_layers = 25;

	[x,y,z] = SpiralUpwards(x0,y0,z0,step,n_layers,min_layer_height,max_layer_height);

	PlotPringle(x,y,z);
	SquareAxes3(gca);
end%func PringleSpiral

% Generators
function [x,y,z] = GeneratePringle(radius,z_offset,n_peaks)
	points = linspace(0,2*pi,100);
	x = radius .* sin(points);
	y = radius .* cos(points);

	% Sinusoidal offset
	n_peaks = ceil(n_peaks);
	z = z_offset .* sin(n_peaks .* points) ./ 2;
end%func GeneratePringle

function [x,y,z] = GenerateGauss(height,wall_length)
	n_points = 50;
	l = wall_length / 2;
	x = linspace(-1*l,l,n_points);
	y = zeros(1,n_points);

	% Gaussian function (w/ gain) defined from wikipedia
	z = -1 .* height .* exp(-1 .* ((x ./ (l / 3)) .^ 2));
end%func GenerateGauss

function layer = GenerateGaussLayer(height,wall_length)
	n_points = 50;
	l = wall_length / 2;
	x = linspace(-1*l,l,n_points);
	y = zeros(1,n_points);

	% Gaussian function (w/ gain) defined from wikipedia
	z = -1 .* height .* exp(-1 .* ((x ./ (l / 3)) .^ 2));

	points = cell(1,n_points);

	for i = 1:n_points
		points{i} = Point(x(i),y(i),z(i));
	end%for i

	layer = Layer(points);
end%func GenerateGaussLayer

function [x,y,z] = SpiralUpwards(x0,y0,z0,step,n_layers,min_layer_height,max_layer_height)

	n_points = length(x0);
	x = zeros(n_layers,n_points);
	y = x;
	z = x;

	for i = 1:n_layers
		[x0,y0,z0] = GenerateSpiraledLayer(x0,y0,z0,step,min_layer_height,max_layer_height);
		x(i,:) = x0;
		y(i,:) = y0;
		z(i,:) = z0;
	end%for i
end%func SpiralUpwards

function [x,y,z] = InterpolateToFlat(x0,y0,z0,normal_vector,min_layer_height,max_layer_height)
	% Need algorithm to predict size of final matrix
	n_points = length(x0);
	x = zeros(1,n_points);
	y = x;
	z = x;

	is_flat = false;
	i = 1;
	while(~is_flat)
		[x0,y0,z0,is_flat] = GenerateNextLayer(x0,y0,z0,normal_vector,min_layer_height,max_layer_height);
		x(i,:) = x0;
		y(i,:) = y0;
		z(i,:) = z0;

		i = i + 1;
	end%while

	n_layers = i - 1;

	fprintf('Profiles resolved in %i layers\n', n_layers);

end%func InterpolateToFlat

function layers = InterpolateLayerToFlat(layer0,min_layer_height,max_layer_height)
	% Need algorithm to predict size of final matrix
	n_points = length(layer0,points{1}.x);
	layers = cell(1,n_points);

	is_flat = false;
	i = 1;
	while(~is_flat)
		[layer,is_flat] = GenerateNextLayerObj(layer0,min_layer_height,max_layer_height);
		layers{i} = layer;

		i = i + 1;
	end%while

	n_layers = i - 1;

	fprintf('Profiles resolved in %i layers\n', n_layers);

end%func InterpolateToFlat

function [x,y,z] = GenerateSpiraledLayer(prev_x,prev_y,prev_z,step,min_layer_height,max_layer_height)
	x = prev_x;
	y = prev_y;
	z = prev_z + step;
end%func GenerateSpiraledLayer

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

function [layer,is_flat] = GenerateNextLayerObj(layer0,min_layer_height,max_layer_height)
	n_points = length(layer0.points);
	new_points = cell(1,n_points);

	[layer_min,layer_max] = GetLayerObjExtrema(layer0);
	layer_range = layer_max - layer_min;
	
	layer_height_range = max_layer_height - min_layer_height;

	if(layer_height_range < layer_range)
		for i = 1:n_points
			x = layer0.points{i}.x;
			y = layer0.points{i}.y;

			height_ratio = 1 - ((prev_z(i) - layer_min) / (layer_range));
			z_shift = min_layer_height + (layer_height_range * height_ratio);
			z = layer0.points{i}.z + z_shift;

			new_points{i} = Point(x,y,z);
		end%for i

		is_flat = false;
	else
		for i = 1:n_points
			x = layer0.points{i}.x;
			y = layer0.points{i}.y;
			z = layer_max + min_layer_height;

			new_points{i} = Point(x,y,z);
		end%for i
		
		is_flat = true;
	end%if

	layer = Layer(new_points);

end%func GenerateNextLayerObj

function [x,y,z] = LayerObj2XYZ(layer)
	n_points = length(layer.points);
	x = zeros(1,n_points);
	y = x;
	z = x;

	for i = 1:n_points
		x(i) = layer.points{i}.x;
		y(i) = layer.points{i}.y;
		z(i) = layer.points{i}.z;
	end%for i
end%func LayerObj2XYZ

% Analysis
function [min_height,max_height] = GetLayerExtrema(x,y,z)
	min_height = min(z);
	max_height = max(z);
end%func GetLayerExtrema

function [min_height,max_height] = GetLayerObjExtrema(layer)
	min_height = Inf;
	max_height = -Inf;

	for i = 1:length(layer.points)
		if(layer.points{i}.z < min_height)
			min_height = layer.points{i}.z;
		end%if
		if(layer.points{i}.z > max_layer_height)
			max_height = layer.points{i}.z;
		end%if
	end%for i
end%func GetLayerExtrema

% Plotting
function PlotPringle(x,y,z)
	matrix_size = size(x);
	n_layers = matrix_size(1);

	f = figure('position',[200,0,1000,800]);
	axes_handle = axes('parent',f);

	hold on;
	for i = 1:n_layers
		plot3(x(i,:),y(i,:),z(i,:),'k','parent',axes_handle);
	end%for i
	hold off;

	grid on;
	xlabel('X (mm)');
	ylabel('Z (mm)');
	title('Pringle Sinusoidal Perturbation');
	view(45,45);
end%func PlotPringle

function PlotGauss(x,y,z)
	matrix_size = size(x);
	n_layers = matrix_size(1);

	f = figure;
	axes_handle = axes('parent',f);

	hold on;
	for i = 1:matrix_size(1)
		plot(x(i,:),z(i,:),'k','parent',axes_handle);
	end%for i
	hold off;

	grid on;
	xlabel('X (mm)');
	ylabel('Z (mm)');
	title('Gaussian Perturbation');
end%func PlotPringle

function PlotLayer(layer)
	[x,y,z] = LayerObj2XYZ(layer);
	plot3(x,y,z,'k');

end%func PlotLayer

function SquareAxes3(axes_handle)
	lim = [xlim(axes_handle),ylim(axes_handle),zlim(axes_handle)];
	axis_range = [min(lim),max(lim)];
	xlim(axes_handle,axis_range);
	ylim(axes_handle,axis_range);
	zlim(axes_handle,axis_range);
end%func SquareAxes3