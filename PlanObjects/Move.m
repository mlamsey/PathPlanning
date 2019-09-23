classdef Move
	properties
		point1;
		point2;
	end%properties

	methods
		function obj = Move(point1,point2)
			if(~isa(point1,'Waypoint') || ~isa(point2,'Waypoint'))
				fprintf('Move::Move: Inputs are not of type Waypoint!\n');
				return;
			end%if

			obj.point1 = point1;
			obj.point2 = point2;
		end%func Constructor
	end%methods
end%class Move