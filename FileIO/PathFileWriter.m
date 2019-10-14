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
		function WritePart(file_path,part)
			if(~isa(part,'Part'))
				fprintf('PathFileWrite::Write: Input 2 not a part\n');
				return;
			end%if

			file_id = fopen(file_path,'w');
			if(file_id == -1)
				fprintf('PathFileWriter::Write: File failed to open.\n');
				return;
			end%if

			last_operation_index = 1;

			for i = 1:length(part.segments)
				last_operation_index = PathFileWriter.WriteSegment(file_id,part.segments{i},last_operation_index);
			end%for i

			fclose(file_id);
		end%func Write

		function last_operation_index = WriteSegment(file_id,current_segment,start_operation_index)
			if(~isa(current_segment,'Segment'))
				fprintf('PathFileWrite::WriteSegment: Input 2 not a Segment\n');
				return;
			end%if

			last_operation_index = start_operation_index;

			for i = 1:length(current_segment.contours)
				last_operation_index = PathFileWriter.WriteContourToFile(file_id,current_segment.contours{i},last_operation_index);
			end%for i
		end%func WriteSegment

		function last_operation_index = WriteContourToFile(file_id,current_contour,current_operation_index)
			PathFileWriter.WriteHeader(file_id,current_operation_index);
			PathFileWriter.WriteContour(file_id,current_contour);
			last_operation_index = 1;
		end%func WriteContourToFile

		function WriteHeader(file_id,current_operation_index)
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
			fprintf(file_id,header,current_operation_index,current_operation_index);
		end%func WriteHeader

		function WriteContour(file_id,current_contour)
			if(~isa(current_contour,'Contour'))
				fprintf('PathFileWriter::WriteContour: Contour data is not a Contour Object!\n');
				return;
			end%if

			write_string = '';

			for i = 1:length(current_contour.moves)
				current_move = current_contour.moves{i};

				% Write first move
				if(i == 1)
					PathFileWriter.WriteRetractMotion(current_move.point1,write_string);
				end%if
			end%for i

			% StartMove();
			% if(length(positions) > 1)
			% 	for i = 2:length(positions)
			% 		LinearMove(positions{i},orientations{i},PathFileWriter.mms_welding_speed);
			% 	end%for i
			% end%if
			% EndMove();

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

		end%func WriteContour

		function appended_string = WriteStartContour(waypoint,working_string)
			% Write retract + move to start point
			motion_start_point = waypoint;

		end%func WriteStartContour

		function appended_string = WriteEndContour(waypoint,working_string)
			% Write move to end point + retract

		end%func WriteEndContour

		function appended_string = WriteRetractMotion(destination_waypoint,working_string)
			% Write generic retract motion
			appended_string = [working_string ...
			PathFileWriter.cmd_retract_move ...
			':' PathFileWriter.GetWaypointString(destination_waypoint)];

		end%func WriteRetractMove

		function appended_string = WriteLinearMotion(destination_waypoint,working_string)
			% Write generic linear motion
			appended_string = [working_string ...
			PathFileWriter.cmd_linear_move ...
			':' PathFileWriter.GetWaypointString(destination_waypoint)];

		end%func WriteLinearMotion

		function appended_string = WriteContourMotion(destination_waypoint,working_string)
			% Write generic contour motion
			appended_string = [working_string ...
			PathFileWriter.cmd_contour_move ...
			':' PathFileWriter.GetWaypointString(destination_waypoint)];

		end%func WriteLinearMotion

		function waypoint_string = GetWaypointString(waypoint)
			if(~isa(waypoint,'Waypoint'))
				fprintf('PathFileWriter::GetWaypointString: Input not a Waypoint\n');
				waypoint_string = '';
				return;
			end%if

			% Extract info w/ 3 decimal points precision
			str_x = num2str(waypoint.x,'%1.3f');
			str_y = num2str(waypoint.y,'%1.3f');
			str_z = num2str(waypoint.z,'%1.3f');

			[a,b,c] = Utils.GetABCFromQuaternion(waypoint.torch_quaternion);

			str_a = num2str(a,'%1.3f');
			str_b = num2str(b,'%1.3f');
			str_c = num2str(c,'%1.3f');
			str_speed = num2str(waypoint.speed,'%1.3f');

			% Create comma separated string
			waypoint_string = [str_x,',',str_y,',',str_z,',',...
			str_a,',',str_b,',',str_c,',',...
			str_speed];
			
		end%func GetWaypointString
	end%methods
end%class PathFileWriter