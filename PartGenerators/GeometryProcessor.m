classdef GeometryProcessor
	properties(Constant)

	end%const

	methods(Static)
		function UpdateWallLayerNormals(layer)
			if(~isa(layer,'Layer'))
				fprintf('GeometryProcessor::UpdateWallLayerNormals: Input 1 not a Layer\n');
				return;
			end%if

			for i = 1:length(layer.points)
				% x axis
				travel_direction = GeometryProcessor.GetPointTravelDirection(layer,i);

				% z axis
				normal_vector = cross(travel_direction,[0,1,0])
				layer.points{i}.normal_vector = normal_vector;
			end%for i
		end%func UpdateWallLayerNormals

		function UpdateCylinderLayerNormals(layer)
			if(~isa(layer,'Layer'))
				fprintf('GeometryProcessor::UpdateCylinderLayerNormals: Input 1 not a Layer\n');
				return;
			end%if

			for i = 1:length(layer.points)
				% x axis
				travel_direction = GeometryProcessor.GetPointTravelDirection(layer,i);

				% y axis
				[x,y,z] = AdaptiveBeadProcessor.PointObj2XYZ(layer.points{i});
				point_position = [x,y,z];
				point_position(3) = 0; % project into XY plane

				% z axis
				normal_vector = cross(travel_direction,point_position);
				layer.points{i}.normal_vector = normal_vector;
			end%for i
		end%func UpdateLayerNormals
	end%static methods

	methods(Static, Access = 'private')
		function travel_direction = GetPointTravelDirection(layer,i)
			current_point = layer.points{i};
			if(i == 1)
				next_point = layer.points{i + 1};
				
				[x1,y1,z1] = AdaptiveBeadProcessor.PointObj2XYZ(current_point);
				[x2,y2,z2] = AdaptiveBeadProcessor.PointObj2XYZ(next_point);

				travel_direction = [x2 - x1, y2 - y1, z2 - z1];
			elseif(i == length(layer.points))
				previous_point = layer.points{i - 1};
				
				[x1,y1,z1] = AdaptiveBeadProcessor.PointObj2XYZ(previous_point);
				[x2,y2,z2] = AdaptiveBeadProcessor.PointObj2XYZ(current_point);

				travel_direction = [x2 - x1, y2 - y1, z2 - z1];
			else
				previous_point = layer.points{i - 1};
				next_point = layer.points{i + 1};
				
				[x1,y1,z1] = AdaptiveBeadProcessor.PointObj2XYZ(previous_point);
				[x2,y2,z2] = AdaptiveBeadProcessor.PointObj2XYZ(next_point);

				travel_direction = [x2 - x1, y2 - y1, z2 - z1];
			end%if
		end%func GetPointTravelDirection
	end%private methods
end%class GeometryProcessor