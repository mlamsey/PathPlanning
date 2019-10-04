classdef Slice < handle
    properties
        moves;
    end%properties
    
    methods
        function obj = Slice(positions, orientations, speeds)

            if(nargin == 3) % Position, Orientation, Speed

                if(~isa(positions,'cell') || ~isa(orientations,'cell') || ~isa(speeds,'cell'))
                    fprintf('Slice::Slice: At least one input is not a cell array\n');
                    return;
                end%if
                
                if(length(positions) ~= length(orientations) || length(positions) ~= length(speeds) ...
                    || length(orientations) ~= length(speeds))
                    fprintf('Slice::Slice: Input vector size mismatch\n');
                    return;
                end%if
                
                if(~IsOneByThreeVector(positions{1}) || ~IsOneByThreeVector(orientations{1}))
                    fprintf('Slice::Slice: At least one of the inputs is not the correct size\n');
                    return;
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
                        a = orientations{k}(1);
                        b = orientations{k}(2);
                        c = orientations{k}(3);
                        speed = speeds{k};
                        points{j} = Waypoint(x,y,z,a,b,c,speed);
                    end%for j

                    moves{i} = Move(points{1},points{2});
                end%for i

                obj.moves = moves;

            elseif(nargin == 1) % move list

                obj.moves = positions;

            else
                fprintf('Slice::Slice: Incorrect number of arguments.\n')
                obj = null;
            end%if

            % Subfunctions (nested b/c constructor needs it in this scope)
            function is_formatted = IsOneByThreeVector(test_data)
                data_size = size(test_data);
                if(length(data_size) > 2)
                    is_formatted = false;
                elseif(data_size(1) ~= 3 && data_size(2) ~= 3)
                    is_formatted = false;
                elseif(data_size(1) ~= 1 && data_size(2) ~= 1)
                    is_formatted = false;
                else
                    is_formatted = true;
                end%if
            end%func IsOneByThreeVector
            
        end%func Constructor
    end%methods
end%class Slice