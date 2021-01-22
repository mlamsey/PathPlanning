classdef AdaptiveBeadPlotTools
	properties(Constant)

	end%const
	methods(Static)
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

		function PlotGaussHeat(layers,min_layer_height)
			[l1x,l1y,l1z] = AdaptiveBeadProcessor.LayerObj2XYZ(layers{1});
			z_bottom = min(l1x);
			a = axes;

			hold on;
			for i = 1:length(layers)
				% y = 0 for gauss
				[x,y,z] = AdaptiveBeadProcessor.LayerObj2XYZ(layers{i});
				z = -1 .* (z - z_bottom) + (i * min_layer_height);
				y = y + i;
				plot3(x,y,z,'k','parent',a);
			end%for i
			hold off;
			view(45,45);
			grid on;
		end%func PlotGaussHeat

		function PlotLayers(layers)
			a = axes;
			% PlotLayer(layers{1},a);
			hold on;
			for i = 1:length(layers)
				if(i == 1)
					AdaptiveBeadPlotTools.PlotLayer(layers{i},a,'r');
				else
					AdaptiveBeadPlotTools.PlotLayer(layers{i},a);
				end%if
			end%for i
			hold off;
			view(45,45);
			grid on;
		end%func PlotLayers

		function PlotLayer(layer,axes_handle,plot_color)
			[x,y,z] = AdaptiveBeadProcessor.LayerObj2XYZ(layer);
			if(nargin == 2)
				plot3(x,y,z,'k','parent',axes_handle);
			elseif(nargin == 3)
				plot3(x,y,z,'k','parent',axes_handle,'color',plot_color);
			end%if
		end%func PlotLayer

		function SquareAxes3(axes_handle)
			lim = [xlim(axes_handle),ylim(axes_handle),zlim(axes_handle)];
			axis_range = [min(lim),max(lim)];
			xlim(axes_handle,axis_range);
			ylim(axes_handle,axis_range);
			zlim(axes_handle,axis_range);
		end%func SquareAxes3
	end%static methods

	methods(Static, Access = 'private')

	end%private methods
end%class AdaptiveBeadPlotTools