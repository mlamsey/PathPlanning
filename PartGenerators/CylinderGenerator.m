classdef CylinderGenerator
	properties(Constant)

	end%const

	methods(Static)
		function [x,y,z] = GeneratePringlePart(deviation_height,part_radius,n_perturbations,min_layer_height,max_layer_height)
			fprintf('Generating "Pringle" profile with height %1.3fmm and radius %1.3fmm\n',deviation_height,part_radius);
			fprintf('Minimum layer height: %1.3fmm; Maximum layer height: %1.3fmm\n',min_layer_height,max_layer_height);

			normal_vector = [0,0,1];

			[x0,y0,z0] = CylinderGenerator.GeneratePringle(part_radius,deviation_height,n_perturbations);
			n_points = length(x0);

			[x,y,z] = AdaptiveBeadProcessor.InterpolateToFlat(x0,y0,z0,normal_vector,min_layer_height,max_layer_height);

			% Flip z
			z = z .* -1;

			% Move part to zero z
			z = z - min(z(end,:));

		end%func GeneratePringlePart

		function layers = GeneratePringleLayerPart(deviation_height,part_radius,n_perturbations,min_layer_height,max_layer_height)
			fprintf('Generating "Pringle" profile with height %1.3fmm and radius %1.3fmm\n',deviation_height,part_radius);
			fprintf('Minimum layer height: %1.3fmm; Maximum layer height: %1.3fmm\n',min_layer_height,max_layer_height);

			layer = CylinderGenerator.GeneratePringleLayer(part_radius,deviation_height,n_perturbations);

			layers = AdaptiveBeadProcessor.InterpolateLayerToFlat(layer,min_layer_height,max_layer_height);

		end%func GeneratePringleLayerPart


		function PringleSpiral(deviation_height,part_radius,n_perturbations,min_layer_height,max_layer_height)

			[x0,y0,z0] = CylinderGenerator.GeneratePringle(part_radius,deviation_height,n_perturbations);

			step = min_layer_height;
			n_layers = 25;

			[x,y,z] = AdaptiveBeadProcessor.SpiralUpwards(x0,y0,z0,step,n_layers,min_layer_height,max_layer_height);
			
		end%func PringleSpiral

	end%static methods

	methods(Static, Access = 'private')
		function [x,y,z] = GeneratePringle(radius,z_offset,n_peaks)
			points = linspace(0,2*pi,100);
			x = radius .* sin(points);
			y = radius .* cos(points);

			% Sinusoidal offset
			n_peaks = ceil(n_peaks);
			z = z_offset .* sin(n_peaks .* points) ./ 2;
		end%func GeneratePringle

		function layer = GeneratePringleLayer(radius,z_offset,n_peaks)
			n_points = 100;
			points = linspace(0,2*pi,n_points);
			x = radius .* sin(points);
			y = radius .* cos(points);

			% Sinusoidal offset
			n_peaks = ceil(n_peaks);
			z = z_offset .* sin(n_peaks .* points) ./ 2;

			point_objects = cell(1,n_points);
			for i = 1:n_points
				point_objects{i} = Point(x(i),y(i),z(i));
			end%for i

			layer = Layer(point_objects);
		end%func GeneratePringle
	end%private methods

end%class CylinderGenerator