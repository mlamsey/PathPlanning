classdef ContourAlgorithms
	methods(Static)

        function UpdateTorchQuaternionsUsingInterContourVectors(this_contour,previous_contour)
            n_moves = length(this_contour.moves);
            for i = 1:n_moves
                current_move = this_contour.moves{i};
                norm_vector = ContourAlgorithms.GetNormalVectorFromClosestMoveOnPreviousContour(current_move,previous_contour);
                travel_vector = MoveAlgorithms.GetMoveDirectionVector(current_move);

                torch_quaternion = Utils.GetQuaternionFromNormalVectorAndTravelVector(normal_vector,travel_vector);

                current_move = MoveAlgorithms.UpdateTorchOrientation(current_move,torch_quaternion);
                this_contour.moves{i} = current_move;
            end%for i
        end%func UpdateMoveABCUsingInterLayerVectors

        function normalized_normal_vector = GetNormalVectorFromClosestMoveOnPreviousContour(move_on_current_contour,previous_contour)
            if(~isa(move_on_current_contour,'Move'))
                fprintf('ContourAlgorithms::GetNormalVectorFromClosestMoveOnPreviousContour: Input 1 not a Move\n')
                normalized_normal_vector = null;
                return;
            end%if
            if(~isa(previous_contour,'Contour'))
                fprintf('ContourAlgorithms::GetNormalVectorFromClosestMoveOnPreviousContour: Input 2 not a Contour')
                normalized_normal_vector = null;
                return;
            end%if

            previous_contour_closest_move_index = ContourAlgorithms.FindClosestContour2MoveToContour1Move(move_on_current_contour,previous_contour);
            previous_contour_closest_move = previous_contour.moves{previous_contour_closest_move_index};

            current_move_midpoint = MoveAlgorithms.GetMoveMidpoint(move_on_current_contour);
            previous_move_midpoint = MoveAlgorithms.GetMoveMidpoint(previous_contour_closest_move);

            vector_between_moves = WaypointAlgorithms.GetVectorBetweenPoints(previous_move_midpoint,current_move_midpoint);
            previous_move_direction_vector = MoveAlgorithms.GetMoveDirectionVector(previous_contour_closest_move);

            [proj,normal] = Utils.VectorProjection(vector_between_moves,previous_move_direction_vector);

            normalized_normal_vector = normal ./ norm(normal);
            
        end%func GetNormalVectorFromClosestMoveOnPreviousContour

        function closest_move_index = FindClosestContour2MoveToContour1Move(contour1_move,contour2)
            if(~isa(contour1_move,'Move'))
                fprintf('ContourAlgorithms::FindClosestContour2PointToContour1Point: contour1_move is not a Move\n');
                return;
            end%if
            if(~isa(contour2,'Contour'))
                fprintf('ContourAlgorithms::FindClosestContour2PointToContour1Point: contour2 is not a Contour\n');
                return;
            end%if

            move1_midpoint = MoveAlgorithms.GetMoveMidpoint(contour1_move);
            distances_between_moves = zeros(length(contour2.moves),1);

            for i = 1:length(contour2.moves)
                move2_i_midpoint = MoveAlgorithms.GetMoveMidpoint(contour2.moves{i});
                distances_between_moves(i) = WaypointAlgorithms.GetDistanceBetweenPoints(move1_midpoint,move2_i_midpoint);
            end%for i

            [min_distance_value,closest_move_index] = min(distances_between_moves);

        end%func FindClosestNextContourPointToCurrentContourMoveMidpoint

        function StaggerStartByMoves(original_contour,moves_to_stagger)
            if(~isa(original_contour,'Contour'))
                fprinf('ContourAlgorithms::StaggerStartByMoves: Input not a contour\n');
                updated_contour = original_contour;
                return;
            end%if

            n_moves = length(original_contour.moves);

            if(~(0 < moves_to_stagger && moves_to_stagger < n_moves))
                fprintf('ContourAlgorithms::StaggerStartByMoves: number of contours to stagger by is outside of range\n');
                updated_contour = original_contour;
                return;
            end%if

            tail_moves = {original_contour.moves{end-(moves_to_stagger-1):end,:}};
            [original_contour.moves{moves_to_stagger + 1:end,:}] = original_contour.moves{1:end-moves_to_stagger,:};
            [original_contour.moves{1:moves_to_stagger,:}] = tail_moves{:};

        end%func StaggerStartByMoves

        function BisectMove(original_contour,move_number)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::BisectMove: Input 1 not a contour\n');
                return;
            end%if
            move_to_bisect = original_contour.moves{move_number};
            [move1,move2] = MoveAlgorithms.BisectMove(move_to_bisect);

            % Insert into contours
            [original_contour.moves{move_number + 1:end + 1,:}] = original_contour.moves{move_number:end,:};
            original_contour.moves{move_number} = move1;
            original_contour.moves{move_number + 1} = move2;

        end%func BisectMove

        function ReverseContourPointOrder(original_contour)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::ReverseContourPointOrder: Input not a contour!\n');
                return;
            end%if
            original_contour = Contour(flip(original_contour.moves));
            for i = 1:length(original_contour.moves)
                MoveAlgorithms.ReverseMove(original_contour.moves{i});
            end%for i
        end%func ReverseContourPointOrder

        function CombineCollinearMoves(original_contour)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::CombineCollinearMoves: Input is not a contour\n');
                return;
            end%if

            moves = original_contour.moves;

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
            fprintf('Contour reduced from %i points to %i points\n',before_n_moves,after_n_moves);

            original_contour.moves = moves;

        end%func CombineCollinearMoves

    end%methods
end%classdef ContourAlgorithms