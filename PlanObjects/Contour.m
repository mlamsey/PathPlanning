classdef Contour < handle & matlab.mixin.Copyable
    properties
        moves;
    end%properties
    
    methods
        function obj = Contour(positions, orientations, speeds)

            if(nargin == 3) % Position, Orientation, Speed

                if(~isa(positions,'cell') || ~isa(orientations,'cell') || ~isa(speeds,'cell'))
                    fprintf('Contour::Contour: At least one input is not a cell array\n');
                    return;
                end%if
                
                if(length(positions) ~= length(orientations) || length(positions) ~= length(speeds) ...
                    || length(orientations) ~= length(speeds))
                    fprintf('Contour::Contour: Input vector size mismatch\n');
                    return;
                end%if
                
                if(~Utils.IsOneByThreeVector(positions{1}))
                    fprintf('Contour::Contour: Input 1 is not the correct size\n');
                    return;
                end%if

                if(~isa(orientations{1},'quaternion'))
                    fprintf('Contour::Contour: Input 2 does not contain quaternions\n');
                end%if

                % Create moves
                n_moves = length(positions) - 1;
                moves = cell(n_moves,1);
                for i = 1:n_moves
                    points = cell(2,1);
                    for j = 1:2
                        k = i + j - 1;

                        x = positions{k}(1);
                        y = positions{k}(2);
                        z = positions{k}(3);
                        torch_quaternion = orientations{k}(1);
                        speed = speeds{k};
                        points{j} = Waypoint(x,y,z,torch_quaternion,speed);
                    end%for j

                    moves{i} = Move(points{1},points{2});
                end%for i

                obj.moves = moves;

            elseif(nargin == 1) % move list

                obj.moves = positions;

            else
                fprintf('Contour::Contour: Incorrect number of arguments.\n')
                obj = null;
            end%if    
        end%func Constructor
    end%methods
end%class Contour
