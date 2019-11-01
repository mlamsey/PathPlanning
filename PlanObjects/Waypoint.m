classdef Waypoint < handle & matlab.mixin.Copyable
	properties
		x;
		y;
		z;
		torch_quaternion;
		speed;
	end%properties

	methods
		function obj = Waypoint(x,y,z,torch_quaternion,speed)
			obj.x = x;
			obj.y = y;
			obj.z = z;
			obj.torch_quaternion = torch_quaternion;
			obj.speed = speed;
		end%func Constructor
	end%methods
end%class Waypoint