classdef WaypointAlgorithms
	methods(Static)

		function distance_between_points = GetDistanceBetweenPoints(point1,point2)
			if(~isa(point1,'Waypoint') || ~isa(point2,'Waypoint'))
				fprintf('WaypointAlgorithms::GetDistanceBetweenPoints: Inputs not all Waypoints\n');
				distance_between_points = 0;
				return;
			end%if
			x1 = point1.x;
			y1 = point1.y;
			z1 = point1.z;
			x2 = point2.x;
			y2 = point2.y;
			z2 = point2.z;

			distance_between_points = sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2);
		end%func GetDistanceBetweenPoints

		function midpoint = GetMidpoint(point1,point2)
			if(~isa(point1,'Waypoint') || ~isa(point2,'Waypoint'))
				fprintf('WaypointAlgorithms::GetMidpoint: Inputs not all Waypoints\n');
				midpoint = null;
				return;
			end%if

			midpoint = WaypointAlgorithms.GetPointBetween(point1,point2,0.5);

		end%GetMidpoint

		function between_point = GetPointBetween(point1,point2,percent_along_line)
			if(~isa(point1,'Waypoint') || ~isa(point2,'Waypoint'))
				fprintf('WaypointAlgorithms::GetPointBetween: Inputs 1 & 2 not Waypoints\n');
				midpoint = null;
				return;
			end%if
			if(~(0 <= percent_along_line <= 1))
				fprintf('WaypointAlgorithms::GetPointBetween: Input 3 not 0-1\n');
				midpoint = null;
				return;
			end%if

			n = (1 - percent_along_line);

			x = point2.x - n * (point2.x - point1.x);
			y = point2.y - n * (point2.y - point1.y);
			z = point2.z - n * (point2.z - point1.z);
			a = point2.a - n * (point2.a - point1.a);
			b = point2.b - n * (point2.b - point1.b);
			c = point2.c - n * (point2.c - point1.c);
			speed = n * (point2.speed - point1.speed);
			between_point = Waypoint(x,y,z,a,b,c,speed);

		end%func GetPointBetween
	end%methods
end%class WaypointAlgorithms