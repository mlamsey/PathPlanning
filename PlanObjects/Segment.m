classdef Segment
	properties
		slices;
		segment_type;
	end%properties
	methods

		function obj = Segment(slices)
			if(~isa(slices,'cell'))
				fprintf('Segment::Segment: Input not a cell array!\n');
				return;
			end%if
			if(~Utils.AreAll(slices,'Slice'))
				fprintf('Segment::Segment: Input elements are not all slices!\n');
				return;
			end%if

			obj.slices = slices;
			obj.segment_type = 'GA';
		end%Constructor

	end%methods
end%class Segment