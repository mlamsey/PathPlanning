classdef SegmentAlgorithms
	methods(Static)
		function CombineCollinearMoves(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::CombineCollinearMoves: Input not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.CombineCollinearMoves(original_segment.contours{i});
			end%for i
		end%func CombineLinearMoves

		function UpdateTorchOrientationsUsingInterContourVectors(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::UpdateTorchOrientationsUsingInterContourVectors: Input not a segment\n');
				return;
			end%if

			if(length(original_segment.contours) > 1)
				% for i = 2:end b/c first contour has GA torch orientation
				for i = 2:length(original_segment.contours)
					previous_contour = original_segment.contours{i-1};
					this_contour = original_segment.contours{i};
					ContourAlgorithms.UpdateTorchOrientationsUsingInterContourVectors(this_contour,previous_contour);
				end%for i
			end%if
		end%func UpdateTorchOrientationsUsingInterContourVectors

		function StaggerContourStartPoints(original_segment)

		end%func
	end%methods
end%class SegmentAlgorithms