classdef PartGenerator
	properties(Constant)
		default_travel_speed = 2.75; % mm/s
	end%const

	methods(Static)
		function part = CreatePart(layers)
			% turn "layers" into "contours" and then pack them into a Part
		end%func CreatePart
	end%static methods
end%class PartGenerator