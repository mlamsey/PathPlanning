classdef SliceAlgorithms
	methods(Static)

        function FindClosestSlice2PointToSlice1Point(slice1,slice1_point,slice2)

        end%func FindClosestNextSlicePointToCurrentSliceMoveMidpoint

        function updated_slice = StaggerStartByMoves(original_slice,moves_to_stagger)
            if(~isa(original_slice,'Slice'))
                fprinf('SliceAlgorithms::StaggerStartByMoves: Input not a slice\n');
                updated_slice = original_slice;
                return;
            end%if

            n_moves = length(original_slice.moves);

            if(~(0 < moves_to_stagger && moves_to_stagger < n_moves))
                fprintf('SliceAlgorithms::StaggerStartByMoves: number of slices to stagger by is outside of range\n');
                updated_slice = original_slice;
                return;
            end%if

            tail_moves = {original_slice.moves{end-(moves_to_stagger-1):end,:}};
            [original_slice.moves{moves_to_stagger + 1:end,:}] = original_slice.moves{1:end-moves_to_stagger,:};
            [original_slice.moves{1:moves_to_stagger,:}] = tail_moves{:};

            updated_slice = original_slice;

        end%func StaggerStartByMoves

        function updated_slice = BisectMove(original_slice,move_number)
            if(~isa(original_slice,'Slice'))
                fprintf('SliceAlgorithms::BisectMove: Input 1 not a slice\n');
                updated_slice = original_slice;
                return;
            end%if
            move_to_bisect = original_slice.moves{move_number};
            [move1,move2] = MoveAlgorithms.BisectMove(move_to_bisect);

            % Insert into slices
            [original_slice.moves{move_number + 1:end + 1,:}] = original_slice.moves{move_number:end,:};
            original_slice.moves{move_number} = move1;
            original_slice.moves{move_number + 1} = move2;

            updated_slice = original_slice;

        end%func BisectMove

        function reversed_slice = ReverseSlicePointOrder(original_slice)
            if(~isa(original_slice,'Slice'))
                fprintf('SliceAlgorithms::ReverseSlicePointOrder: Input not a slice!\n');
                return;
            end%if
            reversed_slice = Slice(flip(original_slice.moves));
            for i = 1:length(reversed_slice.moves)
                reversed_slice.moves{i} = MoveAlgorithms.ReverseMove(reversed_slice.moves{i});
            end%for i
        end%func ReverseSlicePointOrder

        function new_slice = CombineCollinearMoves(original_slice)
            if(~isa(original_slice,'Slice'))
                fprintf('SliceAlgorithms::CombineCollinearMoves: Input is not a slice\n');
                new_slice = original_slice;
                return;
            end%if

            moves = original_slice.moves;

            before_n_moves = length(moves);

            i = 1;
            while(i < length(moves))
                if(MoveAlgorithms.IsCollinear(moves{i},moves{i+1}))
                    moves{i} = MoveAlgorithms.CombineMoves(moves{i},moves{i+1});
                    % Remove the move that you just combined into
                    moves{i + 1} = {}; 
                    moves = moves(~cellfun('isempty',moves));
                else
                    i = i + 1;
                end%if
            end%while

            after_n_moves = length(moves);
            fprintf('Slice reduced from %i points to %i points\n',before_n_moves,after_n_moves);

            new_slice = original_slice;
            new_slice.moves = moves;

        end%func CombineCollinearMoves

    end%methods
end%classdef SliceAlgorithms