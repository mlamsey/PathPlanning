classdef SegmentPanel < handle
	properties
		panel;
		segment_axes;
		contour_listbox;
	end%properties

	methods
		function obj = SegmentPanel(parent_figure)
			panel_position_in_parent = [0.025,0.025,0.45,0.475];
			obj.panel = uipanel('position',panel_position_in_parent,'parent',parent_figure);
			obj.segment_axes = SegmentPanel.CreateSegmentAxes(obj.panel);
			obj.contour_listbox = SegmentPanel.CreateContourListbox(obj.panel);
		end%func Constructor
	end%methods

	methods(Static)
		function axes_ref = CreateSegmentAxes(panel_parent)
			segment_axes_pos = [0.1,0.1,0.6,0.8];
			axes_ref = axes('position',segment_axes_pos,'parent',panel_parent,...
				'gridcolor',[0,0,0],...
				'gridalpha',0.5);
			view(45,25);
			grid on;
			xlabel('X (mm)');
			ylabel('Y (mm)');
			zlabel('Z (mm)');
			title('Segment Preview','fontsize',20);
		end%func CreateSegmentAxes

		function listbox_ref = CreateContourListbox(panel_parent)
			listbox_pos = [0.8,0.1,0.175,0.8];
			listbox_ref = uicontrol('style','listbox','units','normalized',...
				'position',listbox_pos,'parent',panel_parent);
		end%func CreateContourListbox
	end%static methods

end%class PartPanel