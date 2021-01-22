function output = AdaptiveBeadHeight
	% close all;
	figure;
	% normal_vector = [0,0,1];
	min_layer_height = 2.25;
	max_layer_height = 2.75;

	% Gaussian part
	part_length = 5 * 25.4; % in -> mm
	lump_height = 1 * 25.4; % in -> mm

	% layers = WallGenerator.GenerateGaussLayerPart(lump_height,part_length,min_layer_height,max_layer_height);
	% AdaptiveBeadPlotTools.PlotLayers(layers);
	% AdaptiveBeadPlotTools.PlotGaussHeat(layers,min_layer_height);
	% GeometryProcessor.UpdateWallLayerNormals(layers{1});

	% Pringle part 1
	part_radius = 3 * 25.4; % in -> mm
	part_perturbation = 1 * 25.4; % in -> mm
	n_perturbations = 4;

	% CylinderGenerator.PringleSpiral(part_perturbation,part_radius,n_perturbations,min_layer_height,max_layer_height);

	layers = CylinderGenerator.GeneratePringleLayerPart(part_perturbation,part_radius,n_perturbations,min_layer_height,max_layer_height);
	AdaptiveBeadPlotTools.PlotLayers(layers);
	xlabel('X (mm)');
	ylabel('Y (mm)');
	zlabel('Z (mm)');
	title('Adaptive Layer Height Part');
	legend('Layer 1','Layer 2-n','location','northeast');
	% GeometryProc
	% TestHeatEqn;

	% figure;
	% indices = ceil(linspace(1,length(layers),6));
	% for i = 1:6
	% 	j = indices(i);
	% 	subplot(2,3,i);
	% 	AdaptiveBeadPlotTools.PlotLayer(layers{j},gca);
	% 	grid on;
	% 	title(sprintf('Layer %i',j));
	% 	AdaptiveBeadPlotTools.SquareAxes3(gca);
	% 	[x,y,z] = AdaptiveBeadProcessor.LayerObj2XYZ(layers{j});
	% 	layer_z = mean(z);
	% 	offset = 25; % mm
	% 	zlim([layer_z - offset,layer_z + offset]);
	% 	xlabel('X (mm)');
	% 	ylabel('Y (mm)');
	% 	zlabel('Z (mm)');
	% end%for i

	dir_path = 'C:\Users\pty883\University of Tennessee\UT_MABE_Welding - Documents\MAJIC LSAM\Adaptive Bead Height\Pringle Slices\Segment 1\';
	for i = 1:length(layers)
		s = sprintf('Layer_%i.asc',i);
		file_path = strcat(dir_path,s);
		[x,y,z] = AdaptiveBeadProcessor.LayerObj2XYZ(layers{i});
		dlmwrite(file_path,[x',y',z'],' ');
	end%for i

	output = layers;
end%func AdaptiveBeadHeight

function TestHeatEqn
	% real parameters
	part_length = 6 * 25.4; % in -> mm
	part_height = 150; % mm
	interval_size = 0.5; % mm
	decay_rate = 200; % units?
	n_points = 50;
	x = linspace(0,part_length,n_points);

	% heat equation
	L = part_length;
	t = part_height;
	k = decay_rate;
	n = n_points;
	t_steps = ceil(part_height / interval_size);
	dx = L / n;
	dt = 1 / t_steps;
	% a = k * (dt / dx ^ 2) % alpha
	a = 0.5;
	
	t0 = sin(0.05 .* x);
	t1 = zeros(1,n_points);
	t0(1) = 0;
	t0(end) = 1;

	for i = 1:t_steps
		for j = 2:n-1
			t1(j) = t0(j) + a*(t0(j+1) - 2*t0(j) + t0(j-1));
		end%for j
		plot(x,t1);
		ylim([-1,1]);
		title(sprintf('%i',i));
		pause(0.01);
		t0 = t1;
	end%for i

	

end%func TestHeatEqn