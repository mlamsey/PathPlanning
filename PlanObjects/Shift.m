classdef Shift < handle
	properties
		% Shift distances (in parent coordinate frame)
		dx;
		dy;
		dz;
		% Shift angles (about parent coordinate axes)
		da;
		db;
		dc;
	end%properties

	methods
		function obj = Shift(dx,dy,dz,da,db,dc)
		% Shift distances (in parent coordinate frame)
		obj.dx = dx;
		obj.dy = dy;
		obj.dz = dz;
		% Shift angles (about parent coordinate axes)
		obj.da = da;
		obj.db = db;
		obj.dc = dc;
		end%Constructor
	end%methods
end%class Shift