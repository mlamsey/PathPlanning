classdef Utils
	methods(Static)
		%hi
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
