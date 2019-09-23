classdef SliceManipulator < handle

	properties(Constant)
		window_width = 1400;
		window_height = 900;
		font_size_btn = 16;
	end%const

	properties
		ui_window;
		plot_axes;
		ui_elements;

		current_part;

		bool_part_updated;
	end%properties

	methods

		function obj = SliceManipulator(obj)
			close all;
			
			obj.ui_window = obj.CreateWindow;
			obj.plot_axes = obj.CreateAxes(obj.ui_window);
			obj.ui_elements = obj.CreateUIElements(obj.ui_window);
		end%func Constructor

		function figure_ref = CreateWindow(obj)
			% Build Centered Window
			screen_dimensions = get(0,'screensize');
			screen_height = screen_dimensions(4);
			screen_width = screen_dimensions(3);
			window_x = (screen_width - obj.window_width) / 2;
			window_y = (screen_height - obj.window_height) / 2;

			figure_ref = figure('Name','Slice Manipulator',...
				'NumberTitle','off',...
				'position',[window_x,window_y,obj.window_width,obj.window_height],...
				'Resize','off',...
				'Color',[0.75,0.75,0.75]);
		end%func CreateWindow

		function axes_ref = CreateAxes(obj,figure_parent)
			axes_ref = axes('position',[0.075,0.075,0.625,0.85],'parent',figure_parent,...
				'gridcolor',[0,0,0],...
				'gridalpha',0.5);
			view(45,25);
			grid on;
			xlabel('X (mm)');
			ylabel('Y (mm)');
			zlabel('Z (mm)');
			title('Slice Preview','fontsize',20);
		end%func CreateAxes

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

		function CallbackLoadPart(hObject, source, event, obj)
			part = FileTools.PromptForPartImportFromGOM;
			if(isa(part,'Part'))
				obj.current_part = part;
				obj.bool_part_updated = true;
			else
				fprintf('SliceManipulator::CallbackLoadPart: Invalid file selection.\n');
			end%if
			obj.UpdatePlot;
		end%func CallbackLoadPart

		function CallbackRemoveCollinearPoints(hObject, source, event, obj)
			if(isa(obj.current_part,'Part'))
				obj.current_part = PartAlgorithms.CombineCollinearMoves(obj.current_part);
				obj.bool_part_updated = true;
			end%if
			obj.UpdatePlot;
		end%func

		function UpdatePlot(obj)
			if(isa(obj.current_part,'Part'))
				if(obj.bool_part_updated)
					reset(obj.plot_axes);
					delete(findobj('tag','move_line'));
					PlotTools.PlotPart(obj.current_part,obj.plot_axes);
					obj.bool_part_updated = false;
				end%if
			else
				fprintf('SliceManipulator::UpdatePlot: Current Part not populated.\n');
			end%if
		end%func UpdatePlot
	end%methods
end%class