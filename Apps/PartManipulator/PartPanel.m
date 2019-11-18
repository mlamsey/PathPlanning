classdef PartPanel < handle
	properties
		panel;
		axes_part;
		label_number_of_segments;
	end%properties

	methods
		function obj = PartPanel(parent_figure)
			panel_position_in_parent = [0.025,0.5125,0.45,0.45];
			obj.panel = uipanel('position',panel_position_in_parent,'parent',parent_figure);
			obj.axes_part = PartPanel.CreatePartAxes(obj.panel);
			obj.label_number_of_segments = PartPanel.CreateCurrentSegmentLabel(obj.panel);
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

		function label_ref = CreateCurrentSegmentLabel(panel_parent)
			label_pos = [0.7,0.8,0.25,0.15];
			label_ref = uicontrol('Style','text','units','normalized',...
				'position',label_pos,...
				'string','Number of Segments: 0',...
				'parent',panel_parent);
		end%func CreateCurrentSegmentLabel

	end%static methods

end%class PartPanel