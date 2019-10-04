classdef PartAlgorithms
	methods(Static)
		function CombineCollinearMoves(original_part)
			fprintf('Combining Collinear Moves for Part\n');
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::CombineCollinearMoves: Input not a part\n');
				return;
			end%if

			for i = 1:length(original_part.segments)
				SegmentAlgorithms.CombineCollinearMoves(original_part.segments{i});
			end%for i
		end%func
	end%methods
end%class PartAlgorithms