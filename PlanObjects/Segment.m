classdef Segment
	properties
		slices;
	end%properties
	methods

		function obj = Segment(slices)
			if(~isa(slices,'cell'))
				disp('c')
				fprintf('Segment::Segment: Input not a cell array!\n');
				disp('d')
				return;
			end%if
			if(~Utils.AreAll(slices,'Slice'))
				fprintf('Segment::Segment: Input elements are not all slices!\n');
				return;
			end%if

			obj.slices = slices;
		end%Constructor

	end%methods
end%class Segment