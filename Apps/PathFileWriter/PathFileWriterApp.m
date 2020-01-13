classdef PathFileWriterApp < handle
	properties(Constant)
		window_width = 600;
		window_height = 400;
		font_size_btn = 16;
	end%const

	properties
		ui_window;
		ui_elements;

		axes_part;

		current_part;

		save_path;

		bool_part_updated;
	end%properties

	methods
		function obj = PathFileWriterApp(obj)
			obj.ui_window = obj.CreateWindow;
			obj.axes_part = obj.CreatePartAxes(obj.ui_window);
			obj.ui_elements = obj.CreateUIElements(obj.ui_window);
		end%func Constructor

		function figure_ref = CreateWindow(obj)
			% Build Centered Window
			screen_dimensions = get(0,'screensize');
			screen_height = screen_dimensions(4);
			screen_width = screen_dimensions(3);
			window_x = (screen_width - obj.window_width) / 2;
			window_y = (screen_height - obj.window_height) / 2 - 20;

			figure_ref = figure('Name','Path File Writer',...
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

			ui_elements.btn_run_cleanup = uicontrol('style','pushbutton',...
				'units','normalized',...
				'position',[0.05,0.6,0.35,0.15],...
				'string','Standard Cleanup',...
				'fontsize',obj.font_size_btn,...
				'callback',{@obj.CallbackDefaultCleanup,obj});

			ui_elements.btn_set_save_path = uicontrol('style','pushbutton',...
				'units','normalized',...
				'position',[0.05,0.4,0.35,0.15],...
				'string','Set Save Path',...
				'fontsize',obj.font_size_btn,...
				'callback',{@obj.CallbackSetSavePath,obj});

			ui_elements.btn_generate_path_file = uicontrol('style','pushbutton',...
				'units','normalized',...
				'position',[0.05,0.2,0.35,0.15],...
				'string','Generate Path File',...
				'fontsize',obj.font_size_btn,...
				'callback',{@obj.CallbackGeneratePathFile,obj});

			ui_elements.edit_save_directory = uicontrol('style','edit',...
				'units','normalized',...
				'position',[0.05,0.05,0.9,0.075],...
				'string','Select Save Directory',...
				'horizontalalignment','left');

		end%CreateUIElements

		function axes_ref = CreatePartAxes(obj,axes_parent)
			part_axes_pos = [0.4875,0.225,0.45,0.65];
			axes_ref = axes('position',part_axes_pos,'parent',axes_parent,...
				'gridcolor',[0,0,0],...
				'gridalpha',0.5);
			view(45,25);
			grid on;
			xlabel('X (mm)');
			ylabel('Y (mm)');
			zlabel('Z (mm)');
			title('Part Preview','fontsize',20);
		end%func CreatePartAxes

		% Callbacks
		function CallbackLoadPart(hObject, source, event, obj)
			fprintf('Loading Part...\n');

			part = FileTools.PromptForPartImportFromGOM;
			if(isa(part,'Part'))
				obj.current_part = part;
				obj.bool_part_updated = true;
			else
				fprintf('PathFileWriterApp::CallbackLoadPart: Invalid file selection.\n');
			end%if
			pause(1);
			obj.UpdatePartPlot;

		end%func CallbackLoadPart

		function CallbackDefaultCleanup(hObject, source, event, obj)
			StandardProcessing.DefaultPartCleanup(obj.current_part);
			UpdatePartPlot(obj);
		end%func CallbackDefaultCleanup

		function CallbackSetSavePath(hObject, source, event, obj)
			msg_quest = questdlg('Please select a destination folder for the path file','INFO','OK','OK');
            directory = uigetdir;
            if(~directory)
                fprintf('PathFileWriterApp::CallbackSetSavePath: No directory selected!\n');
                directory = 'No Directory Selected';
                obj.save_path = '';
            else
		        msg_input = inputdlg('Enter a file name (without .path extension)','INPUT');
		        directory = strcat(directory,'\',msg_input,'.path');
		        obj.save_path = directory;
            end%if

            obj.ui_elements.edit_save_directory.String = directory;
		end%func CallbackDoSomething

		function CallbackGeneratePathFile(hObject, source, event, obj)
			if(~isa(obj.current_part,'Part'))
				fprintf('PathFileWriterApp::CallbackGeneratePathFile: Part not populated\n');
				return;
			end%if
			if(isempty(obj.save_path))
				fprintf('Save path not populated.\n');
				return;
			end%if
			fprintf('Writing Path File...\n');
			PathFileWriter.WritePart(obj.save_path{1},obj.current_part);
			fprintf('Done!\n');
		end%func CallbackLoadPart

		% Plotting
		function UpdatePartPlot(obj)
			plot_axes = obj.axes_part;
			current_part = obj.current_part;
			
			if(isa(current_part,'Part'))
				if(obj.bool_part_updated)
					delete(findobj('tag','simple_plot'));
					axes(plot_axes);
					PlotTools.PlotPartSimple(current_part,plot_axes);
				end%if
			else
				fprintf('PathFileWriterApp::UpdatePlot: Current Part not populated.\n');
			end%if
		end%func UpdatePlot

	end%methods
end%class PathFileWriterApp