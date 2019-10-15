classdef PartAlgorithms
	methods(Static)
		function PlotNumberOfMovesInEachContour(original_part)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::PlotNumberOfMovesInEachContour: Input not a part\n');
				return;
			end%if

			f = figure;
			a = axes('parent',f);

			move_counts = [];

			for i = 1:length(original_part.segments)
				for j = 1:length(original_part.segments{i}.contours)
					move_counts = [move_counts,length(original_part.segments{i}.contours{j}.moves)];
				end%for j
			end%for i

			plot(move_counts);
			title('Number of Moves Per Contour');
			xlabel('Contour Index');
			ylabel('Number of Moves');
			grid on;

		end%func PlotNumberOfMovesInEachContour

		function DecimateContoursByMoveLength(original_part)
			if(~isa(original_part,'Part'))
				fprintf('PartAlgorithms::DecimateContoursByMoveLength: Input not a part\n');
				return;
			end%if

			for i = 1:length(original_part.segments)
				SegmentAlgorithms.DecimateContoursByMoveLength(original_part.segments{i});
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
	end%methods
end%class PartAlgorithms