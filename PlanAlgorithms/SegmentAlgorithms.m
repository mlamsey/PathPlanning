classdef SegmentAlgorithms
	methods(Static)

		function DecimateContoursByMoveLength(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::DecimateContoursByMoveLength: Input not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.DecimateContourByMoveLength(original_segment.contours{i});
			end%for i
		end%func DecimateContoursByMoveLength

		function CombineCollinearMoves(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::CombineCollinearMoves: Input not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.CombineCollinearMoves(original_segment.contours{i});
			end%for i
		end%func CombineLinearMoves

		function UpdateTorchQuaternionsUsingInterContourVectors(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::UpdateTorchQuaternionsUsingInterContourVectors: Input not a segment\n');
				return;
			end%if

			if(length(original_segment.contours) > 1)
				% for i = 2:end b/c first contour has GA torch orientation
				for i = 2:length(original_segment.contours)
					previous_contour = original_segment.contours{i-1};
					this_contour = original_segment.contours{i};
					ContourAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(this_contour,previous_contour);
				end%for i
			end%if
		end%func UpdateTorchQuaternionsUsingInterContourVectors

		function StaggerContourStartPoints(original_segment)

		end%func
	end%methods
end%class SegmentAlgorithms