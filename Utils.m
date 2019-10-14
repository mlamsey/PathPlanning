classdef Utils
	methods(Static)
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
			if(dot(normal_vector,travel_vector))
				fprintf('Utils::GetQuaternionFromNormalVectorAndTravelVector: Inputs not orthogonal\n');
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
			
		% function [a,b,c] = GetXYZEulerAnglesFromNormalVectorAndTravelVector(norm_vector,travel_vector)
		% 	% Check orthogonality
		% 	if(dot(norm_vector,travel_vector))
		% 		fprintf('Utils::GetXYZEulerAnglesFromNormalVectorAndTravelVector: Inputs not orthogonal\n');
		% 		a = 0;
		% 		b = 0;
		% 		c = 0;
		% 		return;
		% 	end%if

		% 	% Normalize inputs
		% 	norm_vector = norm_vector ./ norm(norm_vector); % Z
		% 	travel_vector = travel_vector ./ norm(travel_vector); % X
		% 	y_vector = cross(norm_vector,travel_vector) ./ norm(cross(norm_vector,travel_vector));

		% 	R = [travel_vector',y_vector',norm_vector'];

		% 	% Defined by equations on Siciliano p.33 - Roll-Pitch-Yaw
		% 	c = radtodeg( atan2(R(2,1),R(1,1)) );
		% 	b = radtodeg( atan2(-1*R(3,1),sqrt(R(3,2)^2 + R(3,3)^2)) );
		% 	a = radtodeg( atan2(R(3,2),R(3,3)) );

		% end%func GetEulerAnglesFromDirectionVector

		% function normal_vector = GetNormalVectorFromXYZEulerAnglesDegrees(a,b,c)
		% 	r11 = cosd(c) * cosd(b);
		% 	r12 = cosd(c) * sind(b) * sind(a) - sind(c) * cosd(a);
		% 	r13 = cosd(c) * sind(b) * cosd(a) + sind(c) * sind(a);
		% 	r21 = sind(c) * cosd(b);
		% 	r22 = sind(c) * sind(b) * sind(a) + cosd(c) * cosd(a);
		% 	r23 = sind(c) * sind(b) * cosd(a) - cosd(c) * sind(a);
		% 	r31 = -1*sind(c);
		% 	r32 = cosd(b) * sind(a);
		% 	r33 = cosd(c) * cosd(a);

		% 	R = [r11,r12,r13
		% 	r21,r22,r23
		% 	r31,r32,r33];

		% 	% Define original normal vector as Z axis
		% 	normal_vector = R * [0;0;1];
		% end%func GetNormalVectorFromXYZEulerAngles

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
