classdef PartAlgorithms
	methods(Static)
		function new_part = CombineCollinearMoves(original_part)
			fprintf('Combining Collinear Moves for Part\n');
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::CombineCollinearMoves: Input not a part\n');
				return;
			end%if

			new_part = original_part;

			for i = 1:length(original_part.segments)
				new_part.segments{i} = SegmentAlgorithms.CombineCollinearMoves(original_part.segments{i});
			end%for i
		end%func
	end%methods
end%class PartAlgorithms