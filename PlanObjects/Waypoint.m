classdef Waypoint
	properties
		x;
		y;
		z;
		a;
		b;
		c;
		speed;
	end%properties

	methods
		function obj = Waypoint(x,y,z,a,b,c,speed)
			obj.x = x;
			obj.y = y;
			obj.z = z;
			obj.a = a;
			obj.b = b;
			obj.c = c;
			obj.speed = speed;
		end%func Constructor
	end%methods
end%class Waypoint