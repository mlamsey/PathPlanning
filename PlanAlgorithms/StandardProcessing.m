classdef StandardProcessing
	% This class contains standard processing routines. These methods can 
	% be used to execute recipes for processing data in the correct / most 
	% efficient order
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
			PartAlgorithms.DecimateContoursByMoveLength(part);
			PartAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(part);

		end%func DefaultCleanup
	end%methods
end%class StandardProcessing