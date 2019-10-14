classdef TestPart
    properties
        test_part;
    end%properties
    
    methods
        function obj = TestPart
            contour_set = TestPart.GenerateContourSet(10);
            obj.test_part = Part({Segment(contour_set)});
        end%func Constructor
    end%methods

    methods(Static)
        function contour_set = GenerateContourSet(number_of_contours)
            points_square = {[0,0,0],...
                [0,10,0],...
                [10,10,0],...
                [10,0,0],...
                [0,0,0]};
            
            q = quaternion.ones;
            default_orientation = {q,q,q,q,q};

            speeds = {6,6,6,6,6};

            contour_set = cell(number_of_contours,1);

            % Populate layer set
            for i = 1:number_of_contours
                layer_box = points_square;
                % Space out vertically
                for j = 1:length(points_square)
                    layer_box{j}(3) = i - 1;
                end%for j
                contour_set{i} = Contour(layer_box,default_orientation,speeds);
            end%for i
            
        end%func GenerateContourSet
    end%Static methods
end%func TestPart