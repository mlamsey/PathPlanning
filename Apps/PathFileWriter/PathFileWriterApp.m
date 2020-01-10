classdef PathFileWriterApp
	properties(Constant)
		window_width = 600;
		window_height = 400;
		font_size_btn = 16;
	end%const

	properties
		ui_window;
		ui_elements;
	end%properties

	methods
		function obj = PathFileWriterApp(obj)
			obj.ui_window = obj.CreateWindow;
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
				'Resize','off');
		end%func CreateWindow

		function ui_elements = CreateUIElements(obj,figure_parent)
			ui_elements.btn_load_part = uicontrol('style','pushbutton',...
				'units','normalized',...
				'position',[0.05,0.8,0.35,0.15],...
				'string','Load Part',...
				'fontsize',obj.font_size_btn,...
				'callback',{@obj.CallbackLoadPart,obj});

			ui_elements.btn_generate_path_file = uicontrol('style','pushbutton',...
				'units','normalized',...
				'position',[0.05,0.625,0.35,0.15],...
				'string','Generate Path File',...
				'fontsize',obj.font_size_btn,...
				'callback',{@obj.CallbackGeneratePathFile,obj});
		end%CreateUIElements

		function CallbackLoadPart(hObject, source, event, obj)
			fprintf('Loading Part...\n');
		end%func CallbackLoadPart

		function CallbackGeneratePathFile(hObject, source, event, obj)
			fprintf('Generating Path File...\n');
		end%func CallbackLoadPart

	end%methods
end%class PathFileWriterApp