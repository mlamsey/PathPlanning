classdef SegmentAlgorithms
	methods(Static)
		function new_segment = CombineCollinearMoves(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::CombineCollinearMoves: Input not a segment\n');
				return;
			end%if

			new_segment = original_segment;

			for i = 1:length(original_segment.slices)
				new_segment.slices{i} = SliceAlgorithms.CombineCollinearMoves(original_segment.slices{i});
			end%for i
		end%func CombineLinearMoves

		function new_segment = StaggerSliceStartPoints(original_segment)

		end%func
	end%methods
end%class SegmentAlgorithms