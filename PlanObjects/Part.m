classdef Part < handle
	properties
		segments;
	end%properties
	methods

		function obj = Part(segments)
			if(~isa(segments,'cell'))
				fprintf('Part::Part: Input not a cell array!\n');
				return;
			end%if
			if(~Utils.AreAll(segments,'Segment'))
				fprintf('Part::Part: Input elements are not all segments!\n');
				return;
			end%if

			obj.segments = segments;
		end%Constructor

	end%methods
end%class Part