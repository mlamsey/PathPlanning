classdef Utils
	properties(Constant)
		e = 10^-4; % epsilon
	end%properties

	methods(Static)
        function is_formatted = IsOneByThreeVector(test_data)
            data_size = size(test_data);
            if(length(data_size) > 2)
                is_formatted = false;
            elseif(data_size(1) ~= 3 && data_size(2) ~= 3)
                is_formatted = false;
            elseif(data_size(1) ~= 1 && data_size(2) ~= 1)
                is_formatted = false;
            else
                is_formatted = true;
            end%if
        end%func IsOneByThreeVector

		function are_all_of_type = AreAll(cell_array,type)
			% Checks if all elements of the input array are of the specified type
			are_all_of_type = true;

			if(~isa(cell_array,'cell'))
				fprintf('Utils::AreAll: input 1 not a cell array!\n');
				are_all_of_type = false;
			end%if

			for i = 1:length(cell_array)
				if(~isa(cell_array{i},type))
					are_all_of_type = false;
					break;
				end%if
			end%for i

		end%func AreAll

		function [a,b,c] = GetABCFromQuaternion(torch_quaternion)
			[a,b,c] = eulerd(torch_quaternion,'XYZ',frame);
		end%func GetABCFromQuaternion

		function q = GetQuaternionFromNormalVectorAndTravelVector(normal_vector,travel_vector)
			if(dot(normal_vector,travel_vector) > Utils.e)
				fprintf('Utils::GetQuaternionFromNormalVectorAndTravelVector: Inputs not orthogonal\n');
				fprintf('Normal Vector: ');
				disp(normal_vector)
				fprintf('Travel Vector: ')
				disp(travel_vector)
				q = quaternion.ones;
				return;
			end%if

			z_axis = normal_vector ./ norm(normal_vector);
			x_axis = travel_vector ./ norm(travel_vector);
			y_axis = cross(x_axis,z_axis);
			y_axis = y_axis ./ norm(y_axis);

			R = [x_axis(1),y_axis(1),z_axis(1)
			x_axis(2),y_axis(2),z_axis(2)
			x_axis(3),y_axis(3),z_axis(3)];

			q = quaternion(R,'rotmat','frame');
			% Normalize quaternion
			q = quaternion(quatnormalize(q.compact));

		end%func GetQuaternionFromNormalVectorAndTravelVector

		function [a1,a2] = VectorProjection(a,b)
			% Projects vector A onto vector B
			% a1 is projection, a2 is normal remainder
			b_normalized = b ./ norm(b);
			a1 = dot(a,b_normalized) .* b_normalized;
			a2 = a - a1;
		end%func VectorProjection

		function distance_between_points = PointDistance3D(point1,point2)
			if(~isa(point1,'Waypoint') || ~isa(point2,'Waypoint'))
				fprintf('Utils::PointDistance3D: Inputs are not waypoints\n');
				return;
			end%if

			x1 = point1.x;
			x2 = point2.x;
			y1 = point1.y;
			y2 = point2.y;
			z1 = point1.z;
			z2 = point2.z;

			distance_between_points = sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2);
		end%if

		function [dx,dy,dz] = GetNormalizedSlopes(move)
			% 0-1 scale
			if(~isa(move,'Move'))
				fprintf('Utils::GetNormalizedSlopes: Input is not a move\n');
				return;
			end%if

			move_distance = Utils.PointDistance3D(move.point1,move.point2);
			dx = (move.point2.x - move.point1.x) / move_distance;
			dy = (move.point2.y - move.point1.y) / move_distance;
			dz = (move.point2.z - move.point1.z) / move_distance;

		end%func GetNormalizedSlopes

		function str = GetCommaSeparatedString(vector)
			str = '';
			for i = 1:length(vector)
				str = [str num2str(vector(i),'%1.3f') ','];
			end%for i
		end%func GetCommaSeparatedString

	end%methods
end%class Utils
