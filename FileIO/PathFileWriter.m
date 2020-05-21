classdef PathFileWriter
	properties(Constant)
		cmd_retract_move = 'R';
		cmd_linear_move = 'L';
		cmd_contour_move = 'C';
		mm_retract_z_offset = 25.4; % mm
		mms_welding_speed = 2.75; % mm/s // 2.75 mm/s // used to be 6.418
		mms_travel_speed = 75; % mm/s // 75 -- put this in the retract moves
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

			fclose('all');
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
			last_operation_index = current_operation_index + 1;
		end%func WriteContourToFile

		function WriteHeader(file_id,current_operation_index)
			header =   ['!StartHeader!\n' ...
						'op_id:%i\n' ...
						'ToolNumber:1\n' ...
						'op_num:%i\n' ...
						'opType:442\n' ...
						'ToolName: UTK WELDING\n' ...
						'WCSName:Top\n' ...
						'SpindleSpeed:0\n' ...
						'HeadNumber:-1\n' ...
						'ToolpathGroupName:UTK ADDITIVE\n' ...
						'!EndHeader!\n'];
			fprintf(file_id,header,current_operation_index + 1,current_operation_index);
		end%func WriteHeader

		function WriteContour(file_id,current_contour)
			if(~isa(current_contour,'Contour'))
				fprintf('PathFileWriter::WriteContour: Contour data is not a Contour Object!\n');
				return;
			end%if

			write_string = '';

			for i = 1:length(current_contour.moves)
				current_move = current_contour.moves{i};

				% Write moves
				if(i == 1) % first move
					write_string = PathFileWriter.WriteStartContour(current_move.point1,write_string);
					write_string = PathFileWriter.WriteLinearMotion(current_move.point2,write_string);
				elseif(i == length(current_contour.moves)) % last move
					write_string = PathFileWriter.WriteEndContour(current_move.point2,write_string);
				else
					write_string = PathFileWriter.WriteLinearMotion(current_move.point2,write_string);
				end%if
			end%for i

			% Write to file
			fprintf(file_id,write_string);
		end%func WriteContour

		function appended_string = WriteStartContour(waypoint,working_string)
			% Write retract + move to start point
			motion_start_point = waypoint;
			retracted_point = PathFileWriter.GenerateRetractedWaypoint(waypoint);

			% Write offset point and then contour start point
			appended_string = PathFileWriter.WriteTravelLinearMotion(retracted_point,working_string);
			appended_string = PathFileWriter.WriteTravelLinearMotion(motion_start_point,appended_string);

		end%func WriteStartContour

		function appended_string = WriteEndContour(waypoint,working_string)
			% Write move to end point + retract
			motion_end_point = waypoint;
			retracted_point = PathFileWriter.GenerateRetractedWaypoint(waypoint);

			% Write contour end point and then offset point
			working_string = PathFileWriter.WriteTravelLinearMotion(motion_end_point,working_string);
			appended_string = PathFileWriter.WriteTravelLinearMotion(retracted_point,working_string);

		end%func WriteEndContour

		function appended_string = WriteRetractMotion(destination_waypoint,working_string)
			% Write generic retract motion
			appended_string = [working_string ...
			PathFileWriter.cmd_retract_move ...
			':' PathFileWriter.GetWaypointStringWithCustomVelocity(destination_waypoint,PathFileWriter.mms_travel_speed) '\n'];

		end%func WriteRetractMove

		function appended_string = WriteTravelLinearMotion(destination_waypoint,working_string)
			% Write a fast p2p move
			appended_string = [working_string ...
			PathFileWriter.cmd_linear_move ...
			':' PathFileWriter.GetWaypointStringWithCustomVelocity(destination_waypoint,PathFileWriter.mms_travel_speed) '\n'];
		
		end%func WriteJointMotion

		function appended_string = WriteLinearMotion(destination_waypoint,working_string)
			% Write generic linear motion
			appended_string = [working_string ...
			PathFileWriter.cmd_linear_move ...
			':' PathFileWriter.GetWaypointString(destination_waypoint) '\n'];

		end%func WriteLinearMotion

		function appended_string = WriteContourMotion(destination_waypoint,working_string)
			% Write generic contour motion
			appended_string = [working_string ...
			PathFileWriter.cmd_contour_move ...
			':' PathFileWriter.GetWaypointString(destination_waypoint) '\n'];

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

			[a,b,c] = Utils.GetZYZEulerAnglesFromRotationMatrix(waypoint.R);
			
			str_a = num2str(a,'%1.3f');
			str_b = num2str(b,'%1.3f');
			str_c = num2str(c,'%1.3f');
			str_speed = num2str(waypoint.speed,'%1.3f');

			% Create comma separated string
			waypoint_string = [str_x,',',str_y,',',str_z,',',...
			str_a,',',str_b,',',str_c,',',...
			str_speed];

		end%func GetWaypointString

		function waypoint_string = GetWaypointStringWithCustomVelocity(waypoint,velocity)
			if(~isa(waypoint,'Waypoint'))
				fprintf('PathFileWriter::GetWaypointString: Input not a Waypoint\n');
				waypoint_string = '';
				return;
			end%if

			% Extract info w/ 3 decimal points precision
			str_x = num2str(waypoint.x,'%1.3f');
			str_y = num2str(waypoint.y,'%1.3f');
			str_z = num2str(waypoint.z,'%1.3f');

			[a,b,c] = Utils.GetZYZEulerAnglesFromRotationMatrix(waypoint.R);

			str_a = num2str(a,'%1.3f');
			str_b = num2str(b,'%1.3f');
			str_c = num2str(c,'%1.3f');
			str_speed = num2str(velocity,'%1.3f');

			% Create comma separated string
			waypoint_string = [str_x,',',str_y,',',str_z,',',...
			str_a,',',str_b,',',str_c,',',...
			str_speed];
		end%func GetWaypointStringWithCustomVelocity

		% Utilities
		function retracted_point = GenerateRetractedWaypoint(waypoint_on_contour)
			if(~isa(waypoint_on_contour,'Waypoint'))
				fprintf('PathFileWriter::GenerateRetractedWaypoint: Input not a Waypoint\n');
				retracted_point = waypoint_on_contour;
				return;
			end%if

			% Find torch direction + retract distance
			retract_vector = [0,0,PathFileWriter.mm_retract_z_offset];
			retracted_point_offset = retract_vector * transpose(waypoint_on_contour.R);

			% Generate point away from workpiece in torch direction
			retracted_x = waypoint_on_contour.x + retracted_point_offset(1);
			retracted_y = waypoint_on_contour.y + retracted_point_offset(2);
			retracted_z = waypoint_on_contour.z + retracted_point_offset(3);

			retracted_point = Waypoint(retracted_x,retracted_y,retracted_z,waypoint_on_contour.torch_quaternion,PathFileWriter.mms_welding_speed);
			retracted_point.R = waypoint_on_contour.R;
		end%func GenerateRetractedWaypoint
	end%methods
end%class PathFileWriter