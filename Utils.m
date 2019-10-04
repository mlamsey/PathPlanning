classdef Utils
	methods(Static)
		function are_all_of_type = AreAll(cell_array,type)
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

		function [a,b,c] = GetXYZEulerAnglesFromNormalVectorAndTravelVector(norm_vector,travel_vector)
			% Normalize inputs
			norm_vector = norm_vector ./ norm(norm_vector); % Z
			travel_vector = travel_vector ./ norm(travel_vector); % X
			y_vector = cross(norm_vector,travel_vector);

			R = [travel_vector',y_vector',norm_vector'];

			% Defined by equations on Siciliano p.33 - Roll-Pitch-Yaw
			c = radtodeg( atan2(-1*R(2,1),-1*R(1,1)) );
			b = radtodeg( atan2(-1*R(3,1),-1*sqrt(R(3,2)^2 + R(3,3)^2)) );
			a = radtodeg( atan2(-1*R(3,2),-1*R(3,3)) );

		end%func GetEulerAnglesFromDirectionVector

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

	end%methods
end%class Utils
