classdef PartPanel < handle
	properties
		panel;
		part_axes;
		segment_listbox;
	end%properties

	methods
		function obj = PartPanel(parent_figure)
			panel_position_in_parent = [0.025,0.5125,0.45,0.45];
			obj.panel = uipanel('position',panel_position_in_parent,'parent',parent_figure);
			obj.part_axes = PartPanel.CreatePartAxes(obj.panel);
			obj.segment_listbox = PartPanel.CreateSegmentListbox(obj.panel);
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

		function listbox_ref = CreateSegmentListbox(panel_parent)
			listbox_pos = [0.8,0.1,0.175,0.8];
			listbox_ref = uicontrol('style','listbox','units','normalized',...
				'position',listbox_pos,'parent',panel_parent);
		end%func CreateSegmentListbox
	end%static methods

end%class PartPanel