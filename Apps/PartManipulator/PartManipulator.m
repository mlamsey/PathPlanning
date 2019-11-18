classdef PartManipulator < handle

	properties(Constant)
		window_width = 1400;
		window_height = 900;
		font_size_btn = 16;
	end%const

	properties
		ui_window;
		ui_elements;

		panel_part;
		panel_segment;
		panel_contour;

		listbox_part;
		listbox_segment;

		current_part;

		bool_part_updated;
	end%properties

	methods

		function obj = PartManipulator(obj)
			close all;
			
			obj.ui_window = obj.CreateWindow;
			obj.panel_part = PartPanel(obj.ui_window);
			obj.panel_segment = SegmentPanel(obj.ui_window);
			obj.listbox_part = obj.CreatePartListbox(obj.ui_window);
			obj.listbox_segment = obj.CreateSegmentListbox(obj.ui_window);

			obj.ui_elements = obj.CreateUIElements(obj.ui_window);

		end%func Constructor

		function figure_ref = CreateWindow(obj)
			% Build Centered Window
			screen_dimensions = get(0,'screensize');
			screen_height = screen_dimensions(4);
			screen_width = screen_dimensions(3);
			window_x = (screen_width - obj.window_width) / 2;
			window_y = (screen_height - obj.window_height) / 2 - 20;

			figure_ref = figure('Name','Part Manipulator',...
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

		function listbox_ref = CreatePartListbox(obj,figure_parent)
			listbox_pos = [0.475,0.5125,0.05,0.45];
			listbox_ref = uicontrol('style','listbox','units','normalized',...
				'position',listbox_pos,'parent',figure_parent);
		end%func CreateSegmentListbox

		function listbox_ref = CreateSegmentListbox(obj,figure_parent)
			listbox_pos = [0.475,0.025,0.05,0.45];
			listbox_ref = uicontrol('style','listbox','units','normalized',...
				'position',listbox_pos,'parent',figure_parent);
		end%func CreateSegmentListbox

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
			plot_axes = obj.panel_part.axes_part;
			current_part = obj.current_part;
			
			if(isa(current_part,'Part'))
				if(obj.bool_part_updated)
					delete(findobj('tag','simple_plot'));
					axes(plot_axes);
					PlotTools.PlotPartSimple(part_data,plot_axes);
				end%if
			else
				fprintf('ContourManipulator::UpdatePlot: Current Part not populated.\n');
			end%if
		end%func UpdatePlot
	end%methods
end%class