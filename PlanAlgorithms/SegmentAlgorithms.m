classdef SegmentAlgorithms
	methods(Static)
		function CombineCollinearMoves(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::CombineCollinearMoves: Input not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.slices)
				SliceAlgorithms.CombineCollinearMoves(original_segment.slices{i});
			end%for i
		end%func CombineLinearMoves

		function StaggerSliceStartPoints(original_segment)

		end%func
	end%methods
end%class SegmentAlgorithms