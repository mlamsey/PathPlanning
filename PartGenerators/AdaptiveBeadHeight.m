function output = AdaptiveBeadHeight
	close all;
	% normal_vector = [0,0,1];
	min_layer_height = 2.25;
	max_layer_height = 2.75;

	% Gaussian part
	part_length = 5 * 25.4; % in -> mm
	lump_height = 1 * 25.4; % in -> mm

	% GenerateGaussPart(lump_height,part_length,min_layer_height,max_layer_height);

	layers = WallGenerator.GenerateGaussLayerPart(lump_height,part_length,min_layer_height,max_layer_height);
	AdaptiveBeadPlotTools.PlotLayers(layers);

	% Pringle part 1
	part_radius = 3 * 25.4; % in -> mm
	part_perturbation = 1 * 25.4; % in -> mm
	n_perturbations = 4;

	% PringleSpiral(part_perturbation,part_radius,n_perturbations,min_layer_height,max_layer_height);

	% GeneratePringlePart(part_perturbation,part_radius,n_perturbations,min_layer_height,max_layer_height);
	% layers = CylinderGenerator.GeneratePringleLayerPart(part_perturbation,part_radius,n_perturbations,min_layer_height,max_layer_height);
	% AdaptiveBeadPlotTools.PlotLayers(layers);
	output = 0;
end%func AdaptiveBeadHeight