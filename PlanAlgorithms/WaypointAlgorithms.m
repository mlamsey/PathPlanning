classdef WaypointAlgorithms
	methods(Static)

		function vector_between_points = GetVectorBetweenPoints(point1,point2)
			if(~isa(point1,'Waypoint') || ~isa(point2,'Waypoint'))
				fprintf('WaypointAlgorithms::GetVectorBetweenPoints: Inputs not all Waypoints\n');
				vector_between_points = [0,0,0];
				return;
			end%if

			vector_between_points(1) = point2.x - point1.x;
			vector_between_points(2) = point2.y - point1.y;
			vector_between_points(3) = point2.z - point1.z;

		end%func GetVectorBetweenPoints

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

			quaternion_1 = Utils.NormalizeQuaternion(point1.torch_quaternion);
			quaternion_2 = Utils.NormalizeQuaternion(point2.torch_quaternion);

			torch_quaternion = slerp(quaternion_1,quaternion_2,percent_along_line);
            %torch_quaternion = quaternion_1;

			speed = n * (point2.speed - point1.speed);
			between_point = Waypoint(x,y,z,torch_quaternion,speed);

		end%func GetPointBetween

		function [x,y,z,a,b,c] = GetWaypointElements(waypoint)
			if(~isa(waypoint,'Waypoint'))
				fprintf('WaypoinyAlgorithms::GetWaypointElements: Input not a waypoint\n');
				x = [];
				y = x;
				z = x;
				a = x;
				b = x;
				c = x;
				return;
			end%if

			x = waypoint.x;
			y = waypoint.y;
			z = waypoint.z;
			a = waypoint.a;
			b = waypoint.b;
			c = waypoint.c;
		end%func GetWaypointElements

		function [x,y,z,a,b,c] = GetShiftedWaypointElements(waypoint)
			if(~isa(waypoint,'Waypoint'))
				fprintf('WaypointAlgorithms::GetShiftedWaypointElements: Input 1 not a waypoint\n');
				x = [];
				y = x;
				z = x;
				a = x;
				b = x;
				c = x;
				return;
			end%if

			shift = waypoint.shift;
			x = waypoint.x + shift.dx;
			y = waypoint.y + shift.dy;
			z = waypoint.z + shift.dz;

			[a,b,c] = Utils.GetZYZEulerAnglesFromRotationMatrix(waypoint.R);
			a = a + shift.da;
			b = b + shift.db;
			c = c + shift.dc;
		end%func GetShiftedWaypointElements
        
        function UpdateWaypointPosition(waypoint,new_x,new_y,new_z)
            if(~isa(waypoint,'Waypoint'))
                fpritnf('WaypointAlgorithms::UpdateWaypointPosition: Input 1 is not a waypoint\n');
                return;
            end%if
            
            waypoint.x = new_x;
            waypoint.y = new_y;
            waypoint.z = new_z;
            
        end%func UpdateWaypointPosition
        
        function UpdateWaypointRotation(waypoint,new_R)
            if(~isa(waypoint,'Waypoint'))
                fprintf('WaypointAlgorithms::UpdateWaypointPosition: Input 1 is not a waypoint\n');
                return;
            end%if
            
            column1_denominator = sqrt((new_R(1,1).^2)+(new_R(2,1).^2)+(new_R(3,1).^2));
            column2_denominator = sqrt((new_R(1,2).^2)+(new_R(2,2).^2)+(new_R(3,2).^2));
            column3_denominator = sqrt((new_R(1,3).^2)+(new_R(2,3).^2)+(new_R(3,3).^2));
            
            if column1_denominator ~= 0
                new_R(1,1) = new_R(1,1)./column1_denominator;
                new_R(2,1) = new_R(2,1)./column1_denominator;
                new_R(3,1) = new_R(3,1)./column1_denominator;
            else
                new_R(1,1) = 1;
                new_R(2,1) = 0;
                new_R(3,1) = 0;
            end
            
            if column2_denominator ~= 0
                new_R(1,2) = new_R(1,2)./column2_denominator;
                new_R(2,2) = new_R(2,2)./column2_denominator;
                new_R(3,2) = new_R(3,2)./column2_denominator;
            else
                new_R(1,2) = 0;
                new_R(2,2) = 1;
                new_R(3,2) = 0;
            end
            
            if column3_denominator ~= 0
                new_R(1,3) = new_R(1,3)./column3_denominator;
                new_R(2,3) = new_R(2,3)./column3_denominator;
                new_R(3,3) = new_R(3,3)./column3_denominator;
            else
                new_R(1,3) = 0;
                new_R(2,3) = 0;
                new_R(3,3) = 1;
            end
            
            waypoint.R = new_R;
            
        end%func UpdateWaypointRotation
        
        function UpdateWaypointSpeed(waypoint,new_speed)
            if(~isa(waypoint,'Waypoint'))
                fprintf('WaypointAlgorithms::UpdateWaypointPosition: Input 1 is not a waypoint\n');
                return;
            end%if
            
            waypoint.speed = new_speed;
            
        end%func UpdateWaypointSpeed

        function SetShift(waypoint,shift)
        	if(~isa(waypoint,'Waypoint'))
        		fprintf('WaypointAlgorithms::SetShift: Input 1 not a waypoint\n');
        		return;
        	end%if

        	if(~isa(shift,'Shift'))
        		fprintf('WaypointAlgorithms::SetShift: Input 2 not a Shift\n');
        		return;
        	end%if

        	waypoint.shift = shift;
        end%func SetShift
        
	end%methods
end%class WaypointAlgorithms