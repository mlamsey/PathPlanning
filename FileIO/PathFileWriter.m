classdef PathFileWriter
	properties(Constant)
		cmd_retract_move = 'R';
		cmd_linear_move = 'L';
		cmd_contour_move = 'C';
		mm_retract_z_offset = 25.4; % mm
		mms_welding_speed = 6.418; % mm/s
		mms_travel_speed = 100; % mm/s
	end%properties

	methods(Static)
		function Write(file_path,slice_set)
			file_id = fopen(file_path,'w');
			if(file_id == -1)
				fprintf('PathFileWriter::Write: File failed to open.\n');
				return;
			end%if

			for i = 1:length(slice_set)
				PathFileWriter.WriteSliceToFile(file_id,slice_set{i},i);
			end

			fclose(file_id);
		end%func Write

		function WriteSliceToFile(file_id,slice_data,slice_number)
			PathFileWriter.WriteHeader(file_id,slice_number);
			PathFileWriter.WriteSlice(file_id,slice_data)
		end%func WriteSliceToFile

		function WriteHeader(file_id,slice_number)
			header =   ['!StartHeader!\n' ...
						'op_id:%i\n' ...
						'ToolNumber:239\n' ...
						'op_num:%i\n' ...
						'opType:1\n' ...
						'ToolName: 1/2 FLAT ENDMILL\n' ...
						'WCSName:Back\n' ...
						'SpindleSpeed:1069\n' ...
						'HeadNumber:-1\n' ...
						'ToolpathGroupName:TOOLPATH GROUP-1\n' ...
						'!EndHeader!\n'];
			fprintf(file_id,header,slice_number,slice_number);
		end%func WriteHeader

		function WriteSlice(file_id,slice_data)
			if(~isa(slice_data,'Slice'))
				fprintf('PathFileWriter::WriteSlice: Slice data is not a Slice Object!\n');
				return;
			end%if

			positions = slice_data.path_positions;
			orientations = slice_data.path_orientations;

			n_points = length(positions);

			write_string = '';

			StartMove();
			if(length(positions) > 1)
				for i = 2:length(positions)
					LinearMove(positions{i},orientations{i},PathFileWriter.mms_welding_speed);
				end%for i
			end%if
			EndMove();

			% Write to file
			fprintf(file_id,write_string);

			% Subfunctions
			function RetractMove(position,orientation,speed)
				write_string = [write_string ...
				PathFileWriter.cmd_retract_move ...
				':' ...
				GetCommaSeparatedString(position) ...
				GetCommaSeparatedString(orientation) ...
				num2str(speed,'%1.3f') '\n'];
			end%func RetractMove

			function LinearMove(position,orientation,speed)
				write_string = [write_string ...
				PathFileWriter.cmd_linear_move ...
				':' ...
				GetCommaSeparatedString(position) ...
				GetCommaSeparatedString(orientation) ...
				num2str(speed,'%1.3f') '\n'];
			end%func LinearMove

			function ContourMove

			end%func ContourMove

			function StartMove
				pos = positions{1};
				ori = orientations{1};
				pos(3) = pos(3) + PathFileWriter.mm_retract_z_offset;
				RetractMove(pos,ori,PathFileWriter.mms_welding_speed);
				RetractMove(positions{1},ori,PathFileWriter.mms_welding_speed);
			end%func StartMove

			function EndMove
				pos = positions{end};
				ori = orientations{end};
				pos(3) = pos(3) + PathFileWriter.mm_retract_z_offset;
				RetractMove(pos,ori,PathFileWriter.mms_travel_speed);
			end%func EndMove

			function str = GetCommaSeparatedString(vector)
				str = '';
				for i = 1:length(vector)
					str = [str num2str(vector(i),'%1.3f') ','];
				end%for i
			end%func GetCommaSeparatedString

		end%func WriteSlice
	end%methods
end%class pathFileWriter