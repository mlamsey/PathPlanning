classdef SegmentPanel < handle
	properties
		panel;
		axes_segment;
		label_current_segment;
	end%properties

	methods
		function obj = SegmentPanel(parent_figure)
			panel_position_in_parent = [0.025,0.025,0.45,0.45];
			obj.panel = uipanel('position',panel_position_in_parent,'parent',parent_figure);
			obj.axes_segment = SegmentPanel.CreateSegmentAxes(obj.panel);
			obj.label_current_segment = SegmentPanel.CreateCurrentSegmentLabel(obj.panel);
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

		function label_ref = CreateCurrentSegmentLabel(panel_parent)
			label_pos = [0.7,0.8,0.25,0.15];
			label_ref = uicontrol('Style','text','units','normalized',...
				'position',label_pos,...
				'string','Current Segment: none',...
				'parent',panel_parent);
		end%func CreateCurrentSegmentLabel
	end%static methods

end%class PartPanel