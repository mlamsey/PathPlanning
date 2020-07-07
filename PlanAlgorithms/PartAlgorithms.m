classdef PartAlgorithms
	methods(Static)
		function UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane(original_part,plane_vector)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane: Input not a part\n');
				return;
			end%if

			fprintf('Updating torch angles...\n');
			tic;
			for i = 1:length(original_part.segments)
				SegmentAlgorithms.UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane(original_part.segments{i},plane_vector);
			end%for i
			
			fprintf('Torch angles calculated in %1.2f seconds\n',toc);
		end%func UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane

		function UpdateTorchQuaternionsUsingInterContourVectors(original_part)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::UpdateTorchQuaternionsUsingInterContourVectors: Input not a part\n');
				return;
			end%if

			fprintf('Updating torch quaternions...\n');
			tic;
			for i = 1:length(original_part.segments)
				SegmentAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(original_part.segments{i});
			end%for i
			
			fprintf('Quaternions calculated in %1.2f seconds\n',toc);
		end%func UpdateTorchQuaternionsUsingInterContourVectors

		function DecimateContoursByMoveLength(original_part,mm_decimate_move_length)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::DecimateContoursByMoveLength: Input not a part\n');
				return;
			end%if

			fprintf('Decimating Part Contours by Minimum Move Length: %1.3fmm\n',mm_decimate_move_length);
			for i = 1:length(original_part.segments)
				SegmentAlgorithms.DecimateContoursByMoveLength(original_part.segments{i},mm_decimate_move_length);
			end%for i
		end%func DecimateContoursByMoveLength

		function CombineCollinearMoves(original_part)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::CombineCollinearMoves: Input not a part\n');
				return;
			end%if

			fprintf('Combining Collinear Moves for Part\n');

			for i = 1:length(original_part.segments)
				SegmentAlgorithms.CombineCollinearMoves(original_part.segments{i});
			end%for i
		end%func

		function StaggerPartStartPoints(original_part)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::StaggerPartStartPoints: Input not a part\n');
				return;
			end%if

			for i = 1:length(original_part.segments)
				SegmentAlgorithms.StaggerSegmentStartPoints(original_part.segments{i});
			end%for i 
		end%func StaggerPartStartPoints

		function StaggerStartPointsByIndices(original_part,indices_per_layer)
			for i = 1:length(original_part.segments)
				SegmentAlgorithms.StaggerSegmentStartPointsByIndices(original_part.segments{i},indices_per_layer);
			end%for i
		end%func StaggerStartPointsByIndices

		function AlternateContourDirections(original_part, number_of_layers_per_alternation)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::AlternateContourDirections: Input not a part\n');
				return;
			end%if

			for i = 1:length(original_part.segments)
				SegmentAlgorithms.AlternateContourDirections(original_part.segments{i},number_of_layers_per_alternation);
			end%for i
		end%func AlternateContourDirections

		function RepairContourEndContinuity(original_part)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::RepairContourEndContinuity: Input 1 not a part\n');
				return;
			end%if

			for i = 1:length(original_part.segments)
				SegmentAlgorithms.RepairContourEndContinuity(original_part.segments{i});
			end%for i
		end%func RepairContourEndContinuity

		function RemoveTailOfContours(original_part,percent_of_each_contour_to_remove)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgoritms::RemoveTailOfContours: Input 1 not a contour!\n');
				return;
			end%if
			if(percent_of_each_contour_to_remove <= 0 || percent_of_each_contour_to_remove >= 1)
				fprintf('PartAlgorithms::RemoveTailOfContours: Input 2 outside range [0,1]\n');
				return;
			end%if

			for i = 1:length(original_part.segments)
				current_segment = original_part.segments{i};

				for j = 1:length(current_segment.contours)
					current_contour = current_segment.contours{j};
					n_moves = length(current_contour.moves);
					reduced_n_moves = floor(n_moves * percent_of_each_contour_to_remove);
					current_contour.moves = {current_contour.moves{1:reduced_n_moves}};
				end%for j
			end%for i
		end%func RemoveTailOfContour

		function RemoveContourLessThanZero(original_part)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgoritms::RemoveContourLessThanZero: Input 1 not a contour!\n');
				return;
			end%if

			for i = 1:length(original_part.segments)
				current_segment = original_part.segments{i};

				for j = 1:length(current_segment.contours)
					current_contour = current_segment.contours{j};
					n_moves = length(current_contour.moves);
					state = zeros(1,n_moves);
					for k = 1:n_moves
						if(current_contour.moves{k}.point2.x < 0.1)
							state(k) = 0;
						else
							state(k) = 1;
						end%if
					end%for k
					current_contour.moves = {current_contour.moves{logical(state)}};
				end%for j
			end%for i
		end%func RemoveContourLessThanZero
	end%methods
end%class PartAlgorithms