classdef StandardProcessing
	methods(Static)
		function DefaultPartCleanup(part)
			if(~isa(part,'Part'))
				fprintf('StandardProcessing::DefaultPartCleanup: Input not a part\n');
				return;
			end%if

			fprintf('Standard Processing: Default Part Cleanup\n');

			PartAlgorithms.CombineCollinearMoves(part);
			PartAlgorithms.DecimateContoursByMoveLength(part);
			PartAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(part);

		end%func DefaultCleanup
	end%methods
end%class StandardProcessing