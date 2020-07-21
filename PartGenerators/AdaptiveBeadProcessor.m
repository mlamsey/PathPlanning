classdef AdaptiveBeadProcessor
	properties(Constant)

	end%const

	methods(Static)
		function layers = InterpolateLayerToFlat(layer,min_layer_height,max_layer_height)
			% Need algorithm to predict size of final matrix
			n_points = length(layer.points{1}.x);
			layers = cell(1,n_points);
			layers{1} = layer;

			is_flat = false;
			i = 2;
			while(~is_flat)
				[layer,is_flat] = AdaptiveBeadProcessor.GenerateNextLayer(layer,min_layer_height,max_layer_height);
				layers{i} = layer;

				i = i + 1;
			end%while

			n_layers = i - 1;

			fprintf('Profiles resolved in %i layers\n', n_layers);

		end%func InterpolateToFlat

		function [x,y,z] = SpiralUpwards(x0,y0,z0,step,n_layers,min_layer_height,max_layer_height)
			% NEEDS WORK >:(
			n_points = length(x0);
			x = zeros(n_layers,n_points);
			y = x;
			z = x;

			for i = 1:n_layers
				[x0,y0,z0] = AdaptiveBeadProcessor.GenerateSpiraledLayer(x0,y0,z0,step,min_layer_height,max_layer_height);
				x(i,:) = x0;
				y(i,:) = y0;
				z(i,:) = z0;
			end%for i
		end%func SpiralUpwards

		% Utilities
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

	end%static methods

	methods(Static, Access = 'private')
		function [layer,is_flat] = GenerateNextLayer(layer0,min_layer_height,max_layer_height)
			n_points = length(layer0.points);
			new_points = cell(1,n_points);

			[layer_min,layer_max] = AdaptiveBeadProcessor.GetLayerExtrema(layer0,max_layer_height);
			layer_range = layer_max - layer_min;
			
			layer_height_range = max_layer_height - min_layer_height;

			if(layer_height_range < layer_range)
				for i = 1:n_points
					x = layer0.points{i}.x;
					y = layer0.points{i}.y;

					height_ratio = 1 - ((layer0.points{i}.z - layer_min) / (layer_range));
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

		end%func GenerateNextLayer

		function [x,y,z] = GenerateSpiraledLayer(prev_x,prev_y,prev_z,step,min_layer_height,max_layer_height)
			% NEEDS WORK >:(
			x = prev_x;
			y = prev_y;
			z = prev_z + step;
		end%func GenerateSpiraledLayer

		function [min_height,max_height] = GetLayerExtrema(layer,max_layer_height)
			[x,y,z] = AdaptiveBeadProcessor.LayerObj2XYZ(layer);

			min_height = min(z);
			max_height = max(z);
		end%func GetLayerExtrema
	end%private methods
end%class AdaptiveBeadProcessor