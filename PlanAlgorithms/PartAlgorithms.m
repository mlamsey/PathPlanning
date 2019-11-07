classdef PartAlgorithms
	methods(Static)
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
	end%methods
end%class PartAlgorithms