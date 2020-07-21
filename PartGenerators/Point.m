classdef Point < handle
	properties
		x;
		y;
		z;
		normal_vector;
	end%properties

	methods 
		function obj = Point(x,y,z)
			obj.x = x;
			obj.y = y;
			obj.z = z;
			obj.normal_vector = [0,0,1];
		end%func Constructor

		function set.normal_vector(obj,vector)
			if(length(vector) ~= 3)
				fprintf('Point::set.normal_vector: input not of length 3. Setting as [0,0,1]\n');
				obj.normal_vector = [0,0,1];
			else
				obj.normal_vector = vector ./ norm(vector);
			end%if
		end%func set normal_vector
	end%methods
end%class