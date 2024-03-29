classdef Move < handle & matlab.mixin.Copyable
	properties
		point1;
		point2;
		move_type; % linear, ramp, ptp, etc
	end%properties

	methods
		function obj = Move(point1,point2)
			if(~isa(point1,'Waypoint') || ~isa(point2,'Waypoint'))
				fprintf('Move::Move: Inputs are not of type Waypoint!\n');
				return;
			end%if

			obj.point1 = point1;
			obj.point2 = point2;
			obj.move_type = 'linear';
		end%func Constructor
	end%methods
end%class Move
