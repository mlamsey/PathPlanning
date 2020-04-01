classdef CleanupPopout
	properties(Constant)
		window_width = 300;
		window_height = 600;
		font_size_btn = 16;
	end%const

	properties
		ui_window;
		ui_elements;
		part_reference;
	end%properties

	methods
		function obj = CleanupPopout(part_reference)
			obj.ui_window = obj.CreateWindow;
			obj.ui_elements = obj.CreateUIElements;
			obj.part_reference = part_reference;
		end%Constructor

		function figure_ref = CreateWindow(obj)
			% Build Centered Window
			screen_dimensions = get(0,'screensize');
			screen_height = screen_dimensions(4);
			screen_width = screen_dimensions(3);
			window_x = (screen_width - obj.window_width) / 2;
			window_y = (screen_height - obj.window_height) / 2 - 20;

			figure_ref = figure('Name','Part Cleanup Menu',...
				'NumberTitle','off',...
				'position',[window_x,window_y,obj.window_width,obj.window_height],...
				'Resize','off');
		end%func CreateWindow

		function button_reference = CreateButton(position, string, callback_handle,callback_args)

		end%func CreateButton

		function ui_elements = CreateUIElements(obj)
			ui_elements.btn_standard_processing = uicontrol('style','pushbutton',...
				'units','normalized',...
				'position',[0.05,0.85,0.9,0.1],...
				'string','Standard Processing',...
				'fontsize',obj.font_size_btn,...
				'callback',{@obj.CallbackStandardProcessing,obj});
			% ui_elements.btn_
		end%func CreateUIElements

		function CallbackStandardProcessing(hObject, source, event, obj)

		end%func CallbackStandardProcessing
	end%methods

end%class CleanupPopout