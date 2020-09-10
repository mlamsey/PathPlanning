classdef MoveAlgorithms
    properties(Constant)
        coincidence_threshold = 0.0001; % mm
        parallel_threshold = 0.0001; % dmm
    end%properties

	methods(Static)

		function UpdateTorchQuaternion(move,torch_quaternion)
			if(~isa(move,'Move'))
				fprintf('MoveAlgorithms::UpdateTorchOrientation: Input 1 not a Move\n');
				return;
			end%if
			if(~isa(torch_quaternion,'quaternion'))
				fprintf('MoveAlgorithms::UpdateTorchOrientation: Input 2 not a quaternion\n');
				return;
			end%if

            move.point1.torch_quaternion = torch_quaternion;
            move.point2.torch_quaternion = torch_quaternion;
		end%func UpdateABC

		function UpdateRotationMatrix(move,R)
			if(~isa(move,'Move'))
				fprintf('MoveAlgorithms::UpdateTorchOrientation: Input 1 not a Move\n');
				return;
			end%if
			R_size = size(R);
			if(R_size(1) ~= 3 || R_size(2) ~= 3)
				fprintf('MoveAlgorithms::UpdateTorchOrientation: Input 2 not 3x3\n');
				return;
			end%if

            move.point1.R = R;
            move.point2.R = R;
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

			move_direction_vector = move_direction_vector ./ norm(move_direction_vector);

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

		function SetMoveShift(move,shift)
			if(~isa(move,'Move'))
				fprintf('MoveAlgorithms::SetMoveShift: Input 1 not a Move\n');
				return;
			end%if

			if(~isa(shift,'Shift'))
				fprintf('MoveAlgorithms::SetMoveShift: Input 2 not a Shift\n');
				return;
			end%if

			WaypointAlgorithms.SetShift(move.point1,shift);
			WaypointAlgorithms.SetShift(move.point2,shift);
		end%func SetMoveShift

		function ReverseMove(move)
			if(~isa(move,'Move'))
				fprintf('MoveAlgorithms::ReverseMove: Input not a move\n');
				return;
			end%if
			temp = move.point1;
			move.point1 = move.point2;
			move.point2 = temp;
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

		function RotateMovePointsAboutToolFrames(move,degrees_to_rotate,axis_name)
			if(~isa(move,'Move'))
				fprintf('MoveAlgorithms::RotateMovePointsAboutToolFrames: Input 1 not a Move\n');
				return;
			end%if

			WaypointAlgorithms.RotateAboutToolFrameAxis(move.point1,degrees_to_rotate,axis_name);
			WaypointAlgorithms.RotateAboutToolFrameAxis(move.point2,degrees_to_rotate,axis_name);
		end%func RotateMovePointsAboutToolFrames

		function move_list = MoveLinspaceConstantR(old_move,number_of_moves)
			if(~isa(old_move,'Move'))
				fprintf('MoveAlgorithms::MoveLinspace: Input 1 not a Move\n');
				move_list = old_move;
				return;
			end%if

			point1 = old_move.point1;
			point2 = old_move.point2;

			number_of_points = number_of_moves + 1;
			% Generate x ranges
			x_range = linspace(point1.x,point2.x,number_of_points);
			y_range = linspace(point1.y,point2.y,number_of_points);
			z_range = linspace(point1.z,point2.z,number_of_points);

			old_quaternion = point1.torch_quaternion;
			old_R = point1.R;
			old_speed = point1.speed;

			for i = 1:number_of_moves
				start_point = Waypoint(x_range(i),y_range(i),z_range(i),quaternion.ones,old_speed);
				start_point.R = old_R;
				end_point = Waypoint(x_range(i + 1),y_range(i + 1),z_range(i + 1),quaternion.ones,old_speed);
				end_point.R = old_R;
				move_list{i} = Move(start_point,end_point);
			end%for i
		end%func

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
        
        function TranslateMove(move,x_translate,y_translate,z_translate)
            if(~isa(move,'Move'))
				fprintf('MoveAlgorithms::TranslateMove: Input 1 not a Move\n');
				return;
			end%if
            
            WaypointAlgorithms.TranslateWaypoint(move.point1,x_translate,y_translate,z_translate);
            WaypointAlgorithms.TranslateWaypoint(move.point2,x_translate,y_translate,z_translate);
            
        end%func TranslateMove

	end%methods
end%class MoveAlgorithms