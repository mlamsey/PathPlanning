classdef MoveAlgorithms
    properties(Constant)
        coincidence_threshold = 0.0001; % mm
        parallel_threshold = 0.0001; % dmm
    end%properties
    
	methods(Static)

		function [move1,move2] = BisectMove(old_move)
			[move1,move2] = MoveAlgorithms.BisectMoveAtPercent(old_move,0.5);
		end%func BisectMove

		function [move1,move2] = BisectMoveAtPercent(old_move,percent_along_move)
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