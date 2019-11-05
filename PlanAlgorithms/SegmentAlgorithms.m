classdef SegmentAlgorithms
	methods(Static)

		function DecimateContoursByMoveLength(original_segment,mm_decimate_move_length)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::DecimateContoursByMoveLength: Input not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.DecimateContourByMoveLength(original_segment.contours{i},mm_decimate_move_length);
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
					fprintf('Calculating Quaternions for Layer %i\n',i);
					previous_contour = original_segment.contours{i-1};
					this_contour = original_segment.contours{i};
					ContourAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(this_contour,previous_contour);
				end%for i
			end%if
		end%func UpdateTorchQuaternionsUsingInterContourVectors

		function StaggerContourStartPoints(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::StaggerContourStartPoints: Input not a segmetn\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				contour_i = original_segment.contours{i};
				max_stagger = length(contour_i.moves);

				number_of_moves_to_stagger_by = i;
				if(number_of_moves_to_stagger_by > max_stagger)
					number_of_moves_to_stagger_by = max_stagger - 1;
				end%if

				ContourAlgorithms.StaggerStartByMoves(contour_i,number_of_moves_to_stagger_by);
			end%for i
		end%func
	end%methods
end%class SegmentAlgorithms