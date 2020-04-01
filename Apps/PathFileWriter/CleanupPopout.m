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

		function ui_elements = CreateUIElements(obj)
			ui_elements.btn_standard_processing = CleanupPopout.CreateButton(obj.ui_window,...
				[0.05,0.85,0.9,0.1],'Standard Processing',...
				@obj.CallbackStandardProcessing,{obj});

			ui_elements.testbtn = CleanupPopout.CreateButton(obj.ui_window,...
				[0.05,0.7,0.9,0.1],'test',...
				@obj.CallbackTest);
		end%func CreateUIElements

		function CallbackStandardProcessing(hObject, source, event, obj)
			disp('Standard Processing');
		end%func CallbackStandardProcessing

		function CallbackTest(hObject, source, event)
			disp('oh boy');
		end
	end%methods

	methods(Static)
		function button_reference = CreateButton(button_parent, position, string, callback_function_handle, callback_arguments)
			if(nargin == 4)
				button_reference = uicontrol('parent',button_parent,...
					'style','pushbutton',...
					'units','normalized',...
					'position',position,...
					'string',string,...
					'fontsize',CleanupPopout.font_size_btn,...
					'callback',{callback_function_handle});
			elseif(nargin == 5)
				button_reference = uicontrol('parent',button_parent,...
					'style','pushbutton',...
					'units','normalized',...
					'position',position,...
					'string',string,...
					'fontsize',CleanupPopout.font_size_btn,...
					'callback',{callback_function_handle,callback_arguments{:}});
			else
				fprintf('CleanupPopout::CreateButton: Incorrect number of arguments!\n');
				button_reference = '';
			end%if
		end%func CreateButton
	end%Static methods

end%class CleanupPopout