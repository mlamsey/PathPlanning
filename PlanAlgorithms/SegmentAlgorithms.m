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

		function UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane(original_segment,plane_vector)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane: Input not a segment\n');
				return;
			end%if

			if(length(original_segment.contours) > 1)
				% for i = 2:end b/c first contour has GA torch orientation
				for i = 2:length(original_segment.contours)
					fprintf('Calculating Quaternions for Layer %i\n',i);
					previous_contour = original_segment.contours{i-1};
					this_contour = original_segment.contours{i};
					ContourAlgorithms.UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane(this_contour,previous_contour,plane_vector);
				end%for i
			end%if

		end%func UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane

		function UpdateTorchQuaternionsUsingInterContourVectors(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::UpdateTorchQuaternionsUsingInterContourVectors: Input not a segment\n');
				return;
			end%if

			ContourAlgorithms.UpdateTorchQuaternionsUsingTravelVectorOnly(original_segment.contours{1});

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

		function StaggerSegmentStartPoints(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::StaggerSegmentStartPoints: Input not a segmetn\n');
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
		end%func StaggerContourStartPoints

		function StaggerSegmentStartPointsByIndices(original_segment,indices_per_layer)
			for i = 1:length(original_segment.contours)
				n_moves = length(original_segment.contours{i}.moves);
				number_of_moves_to_stagger_by = mod(i * indices_per_layer,n_moves);
				ContourAlgorithms.StaggerStartByMoves(original_segment.contours{i},number_of_moves_to_stagger_by);
			end%for i
		end%func StaggerSegmentStartPointsByIndices

		function AlternateContourDirections(original_segment, number_of_layers_per_alternation)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::AlternateContourDirections: Input 1 not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				if(rem(i,number_of_layers_per_alternation + 1) == 0)
					for j = 1:number_of_layers_per_alternation
						if(j <= length(original_segment.contours))
							ContourAlgorithms.ReverseContourPointOrder(original_segment.contours{i});
						end%if
					end%for j
				end%if
			end%for i

		end%func AlternateContourDirections

		function RepairContourEndContinuity(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::RepairContourEndContinuity: Input 1 not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.RepairContourEndContinuity(original_segment.contours{i});
			end%for i
		end%func RepairContourEndContinuity

		function RepairSubsetOfContourEndContinuity(original_segment,subset_indices)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::RepairSubsetOfContourEndContinuity: Input 1 not a part\n');
				return;
			end%if

			n_contours = length(original_segment.contours);

			if(max(subset_indices) > n_contours || min(subset_indices) < 1)
				fprintf('SegmentAlgorithms::RepairSubsetOfContourEndContinuity: Input 2 outside contour index range\n');
				return;
			end%if

			for i = 1:length(subset_indices)
				current_index = subset_indices(i);
				ContourAlgorithms.RepairContourEndContinuity(original_segment.contours{current_index});
			end%for i

		end%func RepairSubsetOfContourEndContinuity
	end%methods
end%class SegmentAlgorithms