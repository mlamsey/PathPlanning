classdef Segment < handle & matlab.mixin.Copyable
	properties
		contours;
		segment_type;
	end%properties
	methods

		function obj = Segment(contours)
			if(~isa(contours,'cell'))
				fprintf('Segment::Segment: Input not a cell array!\n');
				return;
			end%if
			if(~Utils.AreAll(contours,'Contour'))
				fprintf('Segment::Segment: Input elements are not all Contours!\n');
				return;
			end%if

			obj.contours = contours;
			obj.segment_type = 'GA';
		end%Constructor

	end%methods
end%class Segment
