classdef Part < handle & matlab.mixin.Copyable
	properties
		segments;
		segment_manifest;
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
			obj.segment_manifest = Part.InitializeSegmentManifest(segments);
		end%Constructor

	end%methods

	methods(Static, Access = 'private')
		function manifest = InitializeSegmentManifest(segments)
			n_segments = length(segments);
			manifest = cell(1,n_segments);
			
			for i = 1:n_segments
				manifest{i} = i;
			end%for i
		end%func InitializeSegmentManifest
	end%private methods
end%class Part
