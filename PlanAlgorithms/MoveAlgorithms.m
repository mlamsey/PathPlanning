classdef MoveAlgorithms
    properties(Constant)
        coincidence_threshold = 0.0001; % mm
        parallel_threshold = 0.0001; % dmm
    end%properties

	methods(Static)

		function UpdateTorchOrientation(move,torch_quaternion)
                move.point1.torch_quaternion = torch_quaternion;
                move.point2.torch_quaternion = torch_quaternion;
		end%func UpdateABC

		function move_direction_vector = GetMoveDirectionVector(move)
			if(~isa(move,'Move'))
				fprintf('MoveAlgorithms::GetMoveDirectionVector: Input not a move\n');
				move_direction_vector = [0,0,0];
				return;
			end%if

			move_direction_vector(1) = move.point2.x - move.point1.x;
			move_direction_vector(2) = move.point2.y - move.point1.y;
			move_direction_vector(3) = move.point2.z - move.point1.z;

		end%func GetMoveDirectionVector

		function move_distance = GetMoveDistance(move)
			if(~isa(move,'Move'))
				fprintf('MoveAlgorithms::GetMoveDistance: Input not a move\n');
				move_distance = 0;
				return;
			end%if
			move_distance = WaypointAlgorithms.GetDistanceBetweenPoints(move.point1,move.point2);
		end%func GetMoveDistance

		function move_midpoint = GetMoveMidpoint(move)
			if(~isa(move,'Move'))
				fprintf('MoveAlgorithms::GetMoveMidpoint: Input not a move\n');
				move_midpoint = null;
				return;
			end%if
			move_midpoint = WaypointAlgorithms.GetMidpoint(move.point1,move.point2);
		end%func GetMoveMidpoint

		function ReverseMove(move)
			if(~isa(move,'Move'))
				fprintf('MoveAlgorithms::ReverseMove: Input not a move\n');
				return;
			end%if
			move = Move(move.point2,move.point1);
		end%func ReverseMove

		function [move1,move2] = BisectMove(old_move)
			if(~isa(old_move,'Move'))
				fprintf('MoveAlgorithms::BisectMove: Input not a move\n');
				return;
			end%if
			[move1,move2] = MoveAlgorithms.BisectMoveAtPercent(old_move,0.5);
		end%func BisectMove

		function [move1,move2] = BisectMoveAtPercent(old_move,percent_along_move)
			if(~isa(old_move,'Move'))
				fprintf('MoveAlgorithms::BisectMoveAtPercent: Input 1 not a move\n');
				return;
			end%if

			if(~(0.0 < percent_along_move && percent_along_move < 1.0))
				fprintf('MoveAlgorithms::BisectMoveAtPercent: Input 2 out of range 0-1\n');
				return;
			end%if

			point_start = old_move.point1;
			point_end = old_move.point2;
			point_middle = WaypointAlgorithms.GetPointBetween(point_start,point_end,percent_along_move);
			% Build 2 moves from 3 points
			move1 = Move(point_start,point_middle);
			move2 = Move(point_middle,point_end);
		end%func BisectMoveAtPercent

		function new_move = CombineMoves(move1,move2)
			if(~isa(move1,'Move') || ~isa(move2,'Move'))
                fprintf('MoveAlgorithms::IsCollinear: Inputs are not moves\n');
                return;
            end%if

            new_move = Move(move1.point1,move2.point2);

		end%func CombineMoves

		function bool_is_collinear = IsCollinear(move1,move2)
            if(~isa(move1,'Move') || ~isa(move2,'Move'))
                fprintf('MoveAlgorithms::IsCollinear: Inputs are not moves\n');
                return;
            end%if

            if(~MoveAlgorithms.IsContinuous(move1,move2))
                bool_is_collinear = false;
                return;
            end%if

            if(MoveAlgorithms.IsParallel(move1,move2))
                bool_is_collinear = true;
            else
                bool_is_collinear = false;
            end%if

        end%func IsCollinear

        function bool_is_continuous = IsContinuous(move1,move2)
            if(~isa(move1,'Move') || ~isa(move2,'Move'))
                fprintf('MoveAlgorithms::IsContinuous: Inputs are not moves\n');
                return;
            end%if

            move1_end = move1.point2;
            move2_start = move2.point1;

            if(Utils.PointDistance3D(move1_end,move2_start) < MoveAlgorithms.coincidence_threshold)
                bool_is_continuous = true;
            else
                bool_is_continuous = false;
            end%if

        end%func IsContinuous

        function bool_is_parallel = IsParallel(move1,move2)
            if(~isa(move1,'Move') || ~isa(move2,'Move'))
                fprintf('MoveAlgorithms::IsParallel: Inputs are not moves\n');
                return;
            end%if

            [dx1,dy1,dz1] = Utils.GetNormalizedSlopes(move1);
            [dx2,dy2,dz2] = Utils.GetNormalizedSlopes(move2);

            if(abs(dx2-dx1) < MoveAlgorithms.parallel_threshold && ...
                abs(dy2-dy1) < MoveAlgorithms.parallel_threshold && ...
                abs(dz2-dz1) < MoveAlgorithms.parallel_threshold)

                bool_is_parallel = true;
            else
                bool_is_parallel = false;
            end%if
        end%func IsParallel

	end%methods
end%class MoveAlgorithms