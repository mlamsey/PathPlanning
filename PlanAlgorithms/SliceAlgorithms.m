classdef SliceAlgorithms
	methods(Static)

        function new_slice = UpdateMoveABCUsingInterLayerVectors(this_slice,previous_slice)
            n_moves = length(this_slice.moves);
            for i = 1:n_moves
                current_move = this_slice.moves{i};
                norm_vector = SliceAlgorithms.GetNormalVectorFromClosestMoveOnPreviousSlice(current_move,previous_slice);
                travel_vector = MoveAlgorithms.GetMoveDirectionVector(current_move);
                [a,b,c] = Utils.GetXYZEulerAnglesFromNormalVectorAndTravelVector(norm_vector,travel_vector);

                current_move = MoveAlgorithms.UpdateABC(current_move,a,b,c);
                this_slice.moves{i} = current_move;
            end%for i
            new_slice = this_slice;
        end%func UpdateMoveABCUsingInterLayerVectors

        function normalized_normal_vector = GetNormalVectorFromClosestMoveOnPreviousSlice(move_on_current_slice,previous_slice)
            if(~isa(move_on_current_slice,'Move'))
                fprintf('SliceAlgorithms::GetNormalVectorFromClosestMoveOnPreviousSlice: Input 1 not a Move\n')
                normalized_normal_vector = null;
                return;
            end%if
            if(~isa(previous_slice,'Slice'))
                fprintf('SliceAlgorithms::GetNormalVectorFromClosestMoveOnPreviousSlice: Input 2 not a Slice')
                normalized_normal_vector = null;
                return;
            end%if

            previous_slice_closest_move_index = SliceAlgorithms.FindClosestSlice2MoveToSlice1Move(move_on_current_slice,previous_slice);
            previous_slice_closest_move = previous_slice.moves{previous_slice_closest_move_index};

            current_move_midpoint = MoveAlgorithms.GetMoveMidpoint(move_on_current_slice);
            previous_move_midpoint = MoveAlgorithms.GetMoveMidpoint(previous_slice_closest_move);

            vector_between_moves = WaypointAlgorithms.GetVectorBetweenPoints(previous_move_midpoint,current_move_midpoint);
            previous_move_direction_vector = MoveAlgorithms.GetMoveDirectionVector(previous_slice_closest_move);

            [proj,normal] = Utils.VectorProjection(vector_between_moves,previous_move_direction_vector);

            normalized_normal_vector = normal ./ norm(normal);
            
        end%func GetNormalVectorFromClosestMoveOnPreviousSlice

        function closest_move_index = FindClosestSlice2MoveToSlice1Move(slice1_move,slice2)
            if(~isa(slice1_move,'Move'))
                fprintf('SliceAlgorithms::FindClosestSlice2PointToSlice1Point: slice1_move is not a Move\n');
                return;
            end%if
            if(~isa(slice2,'Slice'))
                fprintf('SliceAlgorithms::FindClosestSlice2PointToSlice1Point: slice2 is not a Slice\n');
                return;
            end%if

            move1_midpoint = MoveAlgorithms.GetMoveMidpoint(slice1_move);
            distances_between_moves = zeros(length(slice2.moves),1);

            for i = 1:length(slice2.moves)
                move2_i_midpoint = MoveAlgorithms.GetMoveMidpoint(slice2.moves{i});
                distances_between_moves(i) = WaypointAlgorithms.GetDistanceBetweenPoints(move1_midpoint,move2_i_midpoint);
            end%for i

            [min_distance_value,closest_move_index] = min(distances_between_moves);

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