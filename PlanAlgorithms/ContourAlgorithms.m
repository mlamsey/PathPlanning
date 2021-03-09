classdef ContourAlgorithms
    properties(Constant)
        default_GA_torch_angle = [0,0,1];
    end%properties

	methods(Static)

        function DecimateContourByMoveLength(original_contour,mm_decimate_move_length)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::DecimateContourByMoveLength: Input not a Contour\n');
                return;
            end%if

            moves = original_contour.moves;
            threshold = mm_decimate_move_length;

            i = 1;
            while(i < length(moves))
                current_move_length = MoveAlgorithms.GetMoveDistance(moves{i});
                if(current_move_length < threshold)
                    moves{i} = MoveAlgorithms.CombineMoves(moves{i},moves{i+1});
                    % Remove the move you just combined into
                    moves{i + 1} = {}; 
                    moves = moves(~cellfun('isempty',moves));
                else
                    i = i + 1;
                end%if
            end%while

            original_contour.moves = moves;

        end%func

        function UpdateTorchQuaternionsUsingTravelVectorOnly(this_contour)
            if(~isa(this_contour,'Contour'))
                fprintf('ContourAlgorithms::UpdateTorchQuaternionUsingTravelVectorOnly: Input not a Contour\n');
                return;
            end%if

            n_moves = length(this_contour.moves);

            for i = 1:n_moves
                current_move = this_contour.moves{i};

                travel_vector = MoveAlgorithms.GetMoveDirectionVector(current_move);
                torch_quaternion = Utils.GetQuaternionFromNormalVectorAndTravelVector(ContourAlgorithms.default_GA_torch_angle,travel_vector);
                MoveAlgorithms.UpdateTorchQuaternion(current_move,torch_quaternion);

                z_axis = [0,0,1];
                x_axis = travel_vector ./ norm(travel_vector);
                y_axis = cross(z_axis,x_axis);
                y_axis = y_axis ./ norm(y_axis);

                R = [x_axis(1),y_axis(1),z_axis(1)
                x_axis(2),y_axis(2),z_axis(2)
                x_axis(3),y_axis(3),z_axis(3)];
                MoveAlgorithms.UpdateRotationMatrix(current_move,R);
            end%for i
        end%func UpdateTorchQuaternionUsingTravelVectorOnly

        function UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane(this_contour,previous_contour,plane_vector)
            if(~isa(this_contour,'Contour') || ~isa(previous_contour,'Contour'))
                fprintf('ContourAlgorithms::UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane: Inputs not all Contours\n');
                return;
            end%if

            n_moves = length(this_contour.moves);
            previous_closest_move_index = 1;

            number_of_search_iterations_average = 0;

            for i = 1:n_moves
                current_move = this_contour.moves{i};

                [normal_vector,previous_closest_move_index,number_of_search_iterations] = ContourAlgorithms.GetNormalVectorFromClosestMoveOnPreviousContour(current_move,previous_contour,previous_closest_move_index);
                x_vector_in_plane = cross(normal_vector,plane_vector);

                % Normalize Rotation Matrix Vectors
                z_axis = -1 .* normal_vector ./ norm(normal_vector);
                x_axis = x_vector_in_plane ./ norm(x_vector_in_plane);
                y_axis = cross(z_axis,x_axis);
                y_axis = y_axis ./ norm(y_axis);

                R = [x_axis(1),y_axis(1),z_axis(1)
                x_axis(2),y_axis(2),z_axis(2)
                x_axis(3),y_axis(3),z_axis(3)];

                MoveAlgorithms.UpdateRotationMatrix(current_move,R);

                number_of_search_iterations_average = number_of_search_iterations_average + ((number_of_search_iterations - number_of_search_iterations_average) / i);
            end%for i

            fprintf('Average Number of Search Iterations for Nearest Move: %1.3f\n',number_of_search_iterations_average);

        end%func UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane

        function UpdateTorchQuaternionsUsingInterContourVectors(this_contour,previous_contour)
            if(~isa(this_contour,'Contour') || ~isa(previous_contour,'Contour'))
                fprintf('ContourAlgorithms::UpdateTorchQuaternionsUsingInterContourVectors: Inputs not all Contours\n');
                return;
            end%if

            n_moves = length(this_contour.moves);
            previous_closest_move_index = 1;

            number_of_search_iterations_average = 0;

            for i = 1:n_moves
                current_move = this_contour.moves{i};

                [normal_vector,previous_closest_move_index,number_of_search_iterations] = ContourAlgorithms.GetNormalVectorFromClosestMoveOnPreviousContour(current_move,previous_contour,previous_closest_move_index);
                travel_vector = MoveAlgorithms.GetMoveDirectionVector(current_move);

                torch_quaternion = Utils.GetQuaternionFromNormalVectorAndTravelVector(normal_vector,travel_vector);

                MoveAlgorithms.UpdateTorchQuaternion(current_move,torch_quaternion);

                z_axis = -1 .* normal_vector ./ norm(normal_vector);
                x_axis = travel_vector ./ norm(travel_vector);
                y_axis = cross(z_axis,x_axis);
                y_axis = y_axis ./ norm(y_axis);

                R = [x_axis(1),y_axis(1),z_axis(1)
                x_axis(2),y_axis(2),z_axis(2)
                x_axis(3),y_axis(3),z_axis(3)];
                MoveAlgorithms.UpdateRotationMatrix(current_move,R);

                number_of_search_iterations_average = number_of_search_iterations_average + ((number_of_search_iterations - number_of_search_iterations_average) / i);
            end%for i

            fprintf('Average Number of Search Iterations for Nearest Move: %1.3f\n',number_of_search_iterations_average);

        end%func UpdateTorchQuaternionsUsingInterContourVectors

        function [thetas,shifts] = ShiftTorchAngleUsingOverhangAngle(this_contour,previous_contour)

            gravity_vector = [0,0,1];
            n_moves = length(this_contour.moves);
            thetas = zeros(1,n_moves);
            shifts = thetas;

            for i = 1:n_moves
                current_move = this_contour.moves{i};
                [normal_vector,~,~] = ContourAlgorithms.GetNormalVectorFromClosestMoveOnPreviousContour(current_move,previous_contour,1);

                x_prod = cross(gravity_vector,normal_vector);

                thetas(i) = rad2deg(asin(norm(x_prod)));
                t = thetas(i);

                % angle_shift = (-1.24e-04 * t^3) + (0.024 * t^2) - (1.22 * t);
                angle_shift = (-1.31e-04 * t^3) + (0.0196 * t^2) - (0.736 * t) - 0.52;
                shifts(i) = angle_shift;

                % Determine quadrant and shift
                if(abs(angle_shift) > 2) % check if shift > 2 degrees
                    % normal_vector
                    if(normal_vector(1) > 0)
                        % fprintf('NEG\n');
                        MoveAlgorithms.RotateAboutToolFrameAxis(current_move,angle_shift,'x');
                    else
                        % fprintf('POS\n');
                        MoveAlgorithms.RotateAboutToolFrameAxis(current_move,-1 * angle_shift,'x');
                    end%if
                end%if

            end%for i

        end%func ShiftTorchAngleUsingOverhangAngle

        function [normalized_normal_vector,previous_contour_closest_move_index,number_of_search_iterations] = GetNormalVectorFromClosestMoveOnPreviousContour(move_on_current_contour,previous_contour,initial_guess)
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

            % [previous_contour_closest_move_index,number_of_search_iterations] = ContourAlgorithms.FindClosestContour2MoveToContour1MoveWithInitialGuess(move_on_current_contour,previous_contour,initial_guess);
            [previous_contour_closest_move_index,number_of_search_iterations] = ContourAlgorithms.FindClosestContour2MoveToContour1Move(move_on_current_contour,previous_contour);

            previous_contour_closest_move = previous_contour.moves{previous_contour_closest_move_index};

            current_move_midpoint = MoveAlgorithms.GetMoveMidpoint(move_on_current_contour);
            previous_move_midpoint = MoveAlgorithms.GetMoveMidpoint(previous_contour_closest_move);

            vector_between_moves = WaypointAlgorithms.GetVectorBetweenPoints(previous_move_midpoint,current_move_midpoint);

            this_move_direction_vector = MoveAlgorithms.GetMoveDirectionVector(move_on_current_contour);
            [proj,normal] = Utils.VectorProjection(vector_between_moves,this_move_direction_vector);

            normalized_normal_vector = -1 .* normal ./ norm(normal);
            
        end%func GetNormalVectorFromClosestMoveOnPreviousContour

        function StaggerStartByMoves(original_contour,moves_to_stagger)
            if(~isa(original_contour,'Contour'))
                fprinf('ContourAlgorithms::StaggerStartByMoves: Input not a contour\n');
                return;
            end%if

            n_moves = length(original_contour.moves);

            if(~(0 < moves_to_stagger))
                fprintf('ContourAlgorithms::StaggerStartByMoves: number of contours to stagger by 0\n');
                return;
            end%if

            moves_to_stagger = mod(moves_to_stagger,n_moves);

            tail_moves = {original_contour.moves{end-(moves_to_stagger-1):end,:}};
            [original_contour.moves{moves_to_stagger + 1:end,:}] = original_contour.moves{1:end-moves_to_stagger,:};
            [original_contour.moves{1:moves_to_stagger,:}] = tail_moves{:};

        end%func StaggerStartByMoves

        function SetContourShift(original_contour,shift)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::SetContourShift: Input 1 not a Contour\n');
                return;
            end%if

            if(~isa(shift,'Shift'))
                fprintf('ContourAlgorithms::SetContourShift: Input 1 not a Contour\n');
                return;
            end%if

            for i = 1:length(original_contour.moves)
                MoveAlgorithms.SetMoveShift(original_contour.moves{i},shift);
            end%for i
        end%func SetContourShift

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

        function LinspaceMoveByDistance(original_contour,move_number,max_move_distance)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::LinspaceMoveByDistance: Input 1 not a Contour\n');
                return;
            end%if

            move_to_split = original_contour.moves{move_number};
            move_list = MoveAlgorithms.MoveLinspaceByMaxDistance(move_to_split,max_move_distance);

            n_new_moves = length(move_list);

            % Insert into contours
            [original_contour.moves{move_number + n_new_moves:end + n_new_moves,:}] = original_contour.moves{move_number:end,:};
            for i = 1:n_new_moves
                original_contour.moves{move_number + i - 1} = move_list{i};
            end%for i
        end%func LinspaceMoveByDistance

        function ReverseContourPointOrder(original_contour)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::ReverseContourPointOrder: Input not a contour!\n');
                return;
            end%if

            original_contour.moves = flip(original_contour.moves);

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

        function RepairContourEndContinuity(original_contour)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::RepairContourEndContinuity: Input 1 is not a contour\n');
                return;
            end%if

            start_move = original_contour.moves{1};
            end_move = original_contour.moves{end};
            if(~MoveAlgorithms.IsContinuous(end_move,start_move))
                repair_point1 = end_move.point2;
                repair_point2 = start_move.point1;
                repair_move = Move(repair_point1,repair_point2);
                ContourAlgorithms.AddMoveAtBeginningOfContour(original_contour,repair_move);
            end%if
        end%func RepairContourEndContinuity

        function AddMoveAtBeginningOfContour(original_contour,move)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::AddMoveAtBeginningOfContour: Input 1 is not a contour\n');
                return;
            end%if

            if(~isa(move,'Move'))
                fprintf('ContourAlgorithms::AddMoveAtBeginningOfContour: Input 2 is not a move\n');
                return;
            end%if

            n_moves = length(original_contour.moves) + 1;
            for i = 0:n_moves - 2
                j = n_moves - i;
                original_contour.moves{j} = original_contour.moves{j - 1};
            end%for i

            original_contour.moves{1} = move;

        end%func AddMoveAtBeginningOfContour

        function RotateContourPointsAboutToolFrames(original_contour,degrees_to_rotate,axis_name)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::RotateContourPointsAboutToolFrames: Input 1 not a Contour\n');
                return;
            end%if

            for i = 1:length(original_contour.moves)
                MoveAlgorithms.RotateAboutToolFrameAxis(original_contour.moves{i},degrees_to_rotate,axis_name);
            end%for i
        end%func RotateContourPointsAboutToolFrames

        function [x,y,z] = GetContourWaypointVectors(original_contour)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::GetContourWaypointVectors: Input is not a Contour\n');
                x = null;
                y = null;
                z = null;
                return;
            end%if

            n_moves = length(original_contour.moves);
            x = zeros(1,n_moves + 1);
            y = x;
            z = x;

            for i = 1:n_moves
                current_move = original_contour.moves{i};
                x(i) = current_move.point1.x;
                y(i) = current_move.point1.y;
                z(i) = current_move.point1.z;
            end%for i

            x(end) = original_contour.moves{end}.point2.x;
            y(end) = original_contour.moves{end}.point2.y;
            z(end) = original_contour.moves{end}.point2.z;
        end%func GetContourWaypointVectors
        
        function [x_avg,y_avg,z_avg] = FindContourCentroid(original_contour)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::FindContourCentroid: Input is not a Contour\n');
                return;
            end%if
            
            [x,y,z] = ContourAlgorithms.GetContourWaypointVectors(original_contour);
            x_min = min(x);
            x_max = max(x);
            y_min = min(y);
            y_max = max(y);
            z_min = min(z);
            z_max = max(z);
            
            x_avg = (x_min+x_max)./2;
            y_avg = (y_min+y_max)./2;
            z_avg = (z_min+z_max)./2;
        end%func FindContourCentroid
        
        function TranslateContour(original_contour,x_translate,y_translate,z_translate)
            if(~isa(original_contour,'Contour'))
                fprintf('ContourAlgorithms::TranslateContour: Input 1 not a Contour\n');
                return;
            end%if

            for i = 1:length(original_contour.moves)
                MoveAlgorithms.TranslateMove(original_contour.moves{i},x_translate,y_translate,z_translate);
            end%for i
            
        end%func TranslateContour        
    end%methods

    methods(Static, Access = 'private')
        function [closest_move_index,number_of_search_iterations] = FindClosestContour2MoveToContour1Move(contour1_move,contour2)
            if(~isa(contour1_move,'Move'))
                fprintf('ContourAlgorithms::FindClosestContour2MoveToContour1Move: contour1_move is not a Move\n');
                return;
            end%if
            if(~isa(contour2,'Contour'))
                fprintf('ContourAlgorithms::FindClosestContour2MoveToContour1Move: contour2 is not a Contour\n');
                return;
            end%if

            move1_midpoint = MoveAlgorithms.GetMoveMidpoint(contour1_move);
            distances_between_moves = zeros(length(contour2.moves),1);

            for i = 1:length(contour2.moves)
                move2_i_midpoint = MoveAlgorithms.GetMoveMidpoint(contour2.moves{i});
                distances_between_moves(i) = WaypointAlgorithms.GetDistanceBetweenPoints(move1_midpoint,move2_i_midpoint);
            end%for i

            [min_distance_value,closest_move_index] = min(distances_between_moves);
            number_of_search_iterations = length(contour2.moves);

        end%func FindClosestNextContourPointToCurrentContourMoveMidpoint

        function [closest_move_index,number_of_search_iterations] = FindClosestContour2MoveToContour1MoveWithInitialGuess(contour1_move,contour2,initial_guess)
            if(~isa(contour1_move,'Move'))
                fprintf('ContourAlgorithms::FindClosestContour2MoveToContour1MoveWithInitialGuess: Input 1 is not a Move\n');
                return;
            end%if
            if(~isa(contour2,'Contour'))
                fprintf('ContourAlgorithms::FindClosestContour2MoveToContour1MoveWithInitialGuess: Input 2 is not a Contour\n');
                return;
            end%if

            move1_midpoint = MoveAlgorithms.GetMoveMidpoint(contour1_move);

            if(initial_guess > length(contour2.moves))
                initial_guess = length(contour2.moves);
            end%if

            i = initial_guess; % init b/c of iterator++ at start of loop
            number_of_search_iterations = 0; % tracking var for number of search iterations

            closest_move_index = i; % init
            last_distance_between_moves = 100000; % init
            this_distance_between_moves = WaypointAlgorithms.GetDistanceBetweenPoints(move1_midpoint,MoveAlgorithms.GetMoveMidpoint(contour2.moves{i})); % init

            % Check for min distance with increasing index
            while(this_distance_between_moves < last_distance_between_moves)
                number_of_search_iterations = number_of_search_iterations + 1;
                closest_move_index = i;
                last_distance_between_moves = this_distance_between_moves;

                if(i < length(contour2.moves))
                    i = i + 1;
                else
                    i = 1;
                end%if

                move2_i_midpoint = MoveAlgorithms.GetMoveMidpoint(contour2.moves{i});
                this_distance_between_moves = WaypointAlgorithms.GetDistanceBetweenPoints(move1_midpoint,move2_i_midpoint);
            end%while

            % Coerce initial guess
            if(initial_guess > 1)
                i = initial_guess - 1;
            else
                i = length(contour2.moves);
            end%if

            this_distance_between_moves = WaypointAlgorithms.GetDistanceBetweenPoints(move1_midpoint,MoveAlgorithms.GetMoveMidpoint(contour2.moves{i})); % init

            % Check for min distance with decreasing index
            while(this_distance_between_moves < last_distance_between_moves)
                number_of_search_iterations = number_of_search_iterations + 1;
                closest_move_index = i;
                last_distance_between_moves = this_distance_between_moves;

                if(i > 1)
                    i = i - 1;
                else
                    i = length(contour2.moves);
                end%if

                move2_i_midpoint = MoveAlgorithms.GetMoveMidpoint(contour2.moves{i});
                this_distance_between_moves = WaypointAlgorithms.GetDistanceBetweenPoints(move1_midpoint,move2_i_midpoint);
            end%while

        end%func FindClosestContour2MoveToContour1MoveWithInitialGuess

        function shift = CalculateShiftUsingInterContourVectors
            shift = Shift(0,0,0,0,0,0);
        end%func CalculateShiftUsingInterContourVectors
    end%private methods
end%classdef ContourAlgorithms