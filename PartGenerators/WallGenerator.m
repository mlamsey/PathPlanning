classdef WallGenerator
	properties(Constant)

	end%const

	methods(Static)
		function layers = GenerateGaussLayerPart(lump_height,part_length,min_layer_height,max_layer_height)

			fprintf('Generating Gaussian perturbation with height %1.3fmm and length %1.3fmm\n',lump_height,part_length);
			fprintf('Minimum layer height: %1.3fmm; Maximum layer height: %1.3fmm\n',min_layer_height,max_layer_height);

			normal_vector = [0,0,1];

			layer = WallGenerator.GenerateGaussLayer(lump_height,part_length);

			layers = AdaptiveBeadProcessor.InterpolateLayerToFlat(layer,min_layer_height,max_layer_height);

		end%func GenerateGaussLayerPart
	end%static methods

	methods(Static, Access = 'private')
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
	end%private methods
end%class WallGenerator