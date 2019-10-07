classdef TestContourData
    properties
        test_contour_set
    end%properties
    
    methods
        function obj = TestContourData
            obj.test_contour_set = GenerateLayerSet(10);
            
            % Subfunctions
            function layer_set = GenerateLayerSet(number_of_layers)
                points_square = {[0,0,0],...
                    [0,10,0],...
                    [10,10,0],...
                    [10,0,0],...
                    [0,0,0]};
                
                default_orientation = {[0,0,1],...
                    [0,0,1],...
                    [0,0,1],...
                    [0,0,1],...
                    [0,0,1]};

                    speeds = {6,6,6,6,6};

                layer_set = cell(number_of_layers,1);

                % Populate layer set
                for i = 1:number_of_layers
                    layer_box = points_square;
                    % Space out vertically
                    for j = 1:length(points_square)
                        layer_box{j}(3) = i - 1;
                    end%for j
                    layer_set{i} = Contour(layer_box,default_orientation,speeds);
                end%for i
                
            end%func GenerateLayerSet
        end%func Constructor
    end%methods
end%func TestContourData