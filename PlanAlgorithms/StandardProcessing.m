classdef StandardProcessing
	% This class contains standard processing routines. These methods can 
	% be used to execute recipes for processing data in the correct / most 
	% efficient order

	properties(Constant)
		mm_decimate_move_length = 1;
	end%properties

	methods(Static)
		function part = PromptForGOMImportAndRunDefaultCleanup
			part = FileTools.PromptForPartImportFromGOM;
			StandardProcessing.DefaultPartCleanup(part);
		end%func PromptForGOMImportAndRunDefaultCleanup

		function DefaultPartCleanup(part)
			if(~isa(part,'Part'))
				fprintf('StandardProcessing::DefaultPartCleanup: Input not a part\n');
				return;
			end%if

			fprintf('Standard Processing: Default Part Cleanup\n');

			PartAlgorithms.CombineCollinearMoves(part);
			PartAlgorithms.RepairContourEndContinuity(part);
			PartAlgorithms.DecimateContoursByMoveLength(part,StandardProcessing.mm_decimate_move_length);
			PartAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(part);

		end%func DefaultCleanup

		function ProcessEllipticalBowl(part)
			if(~isa(part,'Part'))
				fprintf('StandardProcessing::ProcessEllipticalBowl: Input not a part\n');
				return;
			end%if

			min_move_length = 2.5; % mm
			PartAlgorithms.DecimateContoursByMoveLength(part,min_move_length);

			stagger_distance = 10; % mm
			n_stagger_indices = ceil(stagger_distance / min_move_length);
			PartAlgorithms.StaggerStartPointsByIndices(part,n_stagger_indices);

			PartAlgorithms.AlternateContourDirections(part,1);
		end%func ProcessEllipticalBowl
	end%methods
end%class StandardProcessing