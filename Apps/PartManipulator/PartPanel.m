classdef PartPanel < handle
	properties
		panel;
		axes_part;
	end%properties

	methods
		function obj = PartPanel(parent_figure)
			panel_position_in_parent = [0.025,0.5125,0.45,0.45];
			obj.panel = uipanel('position',panel_position_in_parent,'parent',parent_figure);
			obj.axes_part = PartPanel.CreatePartAxes(obj.panel);
		end%func Constructor
	end%methods

	methods(Static)
		function axes_ref = CreatePartAxes(panel_parent)
			part_axes_pos = [0.1,0.1,0.6,0.8];
			axes_ref = axes('position',part_axes_pos,'parent',panel_parent,...
				'gridcolor',[0,0,0],...
				'gridalpha',0.5);
			view(45,25);
			grid on;
			xlabel('X (mm)');
			ylabel('Y (mm)');
			zlabel('Z (mm)');
			title('Part Preview','fontsize',20);
		end%func CreatePartAxes

		function UpdatePlot(part_data,plot_axes)
			axes(plot_axes);
			PlotTools.PlotPartSimple(part_data,plot_axes);
		end%func UpdatePlot
	end%static methods

end%class PartPanel