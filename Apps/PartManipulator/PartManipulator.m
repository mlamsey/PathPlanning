classdef ContourManipulator < handle

	properties(Constant)
		window_width = 1400;
		window_height = 900;
		font_size_btn = 16;
	end%const

	properties
		ui_window;
		ui_elements;

		part_panel;
		segment_panel;
		contour_panel;

		current_part;

		bool_part_updated;
	end%properties

	methods

		function obj = ContourManipulator(obj)
			close all;
			
			obj.ui_window = obj.CreateWindow;
			obj.part_panel = PartPanel(obj.ui_window);
			ui.segment_panel = SegmentPanel(obj.ui_window);

			obj.ui_elements = obj.CreateUIElements(obj.ui_window);

		end%func Constructor

		function figure_ref = CreateWindow(obj)
			% Build Centered Window
			screen_dimensions = get(0,'screensize');
			screen_height = screen_dimensions(4);
			screen_width = screen_dimensions(3);
			window_x = (screen_width - obj.window_width) / 2;
			window_y = (screen_height - obj.window_height) / 2 - 20;

			figure_ref = figure('Name','Contour Manipulator',...
				'NumberTitle','off',...
				'position',[window_x,window_y,obj.window_width,obj.window_height],...
				'Resize','off',...
				'Color',[0.75,0.75,0.75]);
		end%func CreateWindow

		function ui_elements = CreateUIElements(obj,figure_parent)
			ui_elements.btn_load_part = uicontrol('style','pushbutton',...
				'units','normalized',...
				'position',[0.75,0.875,0.2,0.075],...
				'string','Load Part',...
				'fontsize',obj.font_size_btn,...
				'callback',{@obj.CallbackLoadPart,obj});

			ui_elements.btn_remove_collinear_points = uicontrol('style','pushbutton',...
				'units','normalized',...
				'position',[0.75,0.775,0.2,0.075],...
				'string','Remove Collinear Points',...
				'fontsize',obj.font_size_btn,...
				'callback',{@obj.CallbackRemoveCollinearPoints,obj});
		end%CreateUIElements

		% UI Pushbutton Callbacks
		function CallbackLoadPart(hObject, source, event, obj)
			part = FileTools.PromptForPartImportFromGOM;
			if(isa(part,'Part'))
				obj.current_part = part;
				obj.bool_part_updated = true;
			else
				fprintf('ContourManipulator::CallbackLoadPart: Invalid file selection.\n');
			end%if
			pause(1);
			obj.UpdatePartPlot;
		end%func CallbackLoadPart

		function CallbackRemoveCollinearPoints(hObject, source, event, obj)
			if(isa(obj.current_part,'Part'))
				PartAlgorithms.CombineCollinearMoves(obj.current_part);
				obj.bool_part_updated = true;
			end%if
			obj.UpdatePartPlot;
		end%func

		% Plotting
		function UpdatePartPlot(obj)
			part_axes = obj.part_panel.part_axes;
			current_part = obj.current_part;

			axes(part_axes);
			
			if(isa(current_part,'Part'))
				if(obj.bool_part_updated)
					reset(part_axes);
					delete(findobj('tag','move_line'));
					PlotTools.PlotPart(current_part,part_axes);
					obj.bool_part_updated = false;
				end%if
			else
				fprintf('ContourManipulator::UpdatePlot: Current Part not populated.\n');
			end%if
		end%func UpdatePlot
	end%methods
end%class