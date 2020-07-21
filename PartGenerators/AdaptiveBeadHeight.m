function output = AdaptiveBeadHeight
	close all;
	% normal_vector = [0,0,1];
	min_layer_height = 2.25;
	max_layer_height = 2.75;

	% Gaussian part
	part_length = 5 * 25.4; % in -> mm
	lump_height = 1 * 25.4; % in -> mm

	layers = WallGenerator.GenerateGaussLayerPart(lump_height,part_length,min_layer_height,max_layer_height);
	% AdaptiveBeadPlotTools.PlotLayers(layers);
	AdaptiveBeadPlotTools.PlotGaussHeat(layers,min_layer_height);
	% GeometryProcessor.UpdateWallLayerNormals(layers{1});

	% Pringle part 1
	part_radius = 3 * 25.4; % in -> mm
	part_perturbation = 1 * 25.4; % in -> mm
	n_perturbations = 4;

	% CylinderGenerator.PringleSpiral(part_perturbation,part_radius,n_perturbations,min_layer_height,max_layer_height);

	% layers = CylinderGenerator.GeneratePringleLayerPart(part_perturbation,part_radius,n_perturbations,min_layer_height,max_layer_height);
	% AdaptiveBeadPlotTools.PlotLayers(layers);
	% GeometryProcessor.UpdateCylinderLayerNormals(layers{1});

	output = layers;
end%func AdaptiveBeadHeight