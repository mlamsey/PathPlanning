classdef PartGenerator
	properties(Constant)

	end%const

	methods(Static)
		function part = GeneratePringlePart(deviation_height,part_radius,n_perturbations,min_layer_height,max_layer_height)
			layers = CylinderGenerator.GeneratePringleLayerPart(deviation_height,part_radius,n_perturbations,min_layer_height,max_layer_height);
			n_layers = length(layers);

			contours = cell(1,n_layers);
			for i = 1:n_layers
				current_layer = layers{i};
				n_points = length(current_layer.points);

				positions = cell(1,n_points);
				orientations = positions;
				speeds = positions;

				for j = 1:n_points
					positions{j} = [current_layer.points{j}.x,current_layer.points{j}.y,current_layer.points{j}.z];
					orientations{j} = quaternion.ones;
					speeds{j} = 6.25;
				end%for i

				contours{i} = Contour(positions,orientations,speeds);
			end%for i

			part = Part({Segment(contours)});
		end%func GeneratePringlePart
	end%static methods
end%class