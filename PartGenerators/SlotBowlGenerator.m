classdef SlotBowlGenerator
	properties(Constant)
		length_base = 150; %mm
		width_base = 75; %mm
		n_layers_base = 20; % number of layers in base
	end%properties

	methods(Static)
		function slice_set = GenerateBowl

		end%func GenerateBowl

		function layer_slice = BuildLayer(z)

		end%func BuildLayer

		function points = GenerateArcPoints(radius_mm,max_distance_between_points_mm,start_angle,end_angle,z_mm)
			if(start_angle > end_angle)
				fprintf('SlotBowlGenerator::GeneratePointsAlongCircle: Start Angle greater than End Angle!\n');
			end%if

			generation_angle_length = end_angle - start_angle;
			generation_arc_length = (pi / 180) * radius_mm * generation_angle_length;

			n_points = ceil(generation_arc_length / max_distance_between_points_mm);
			fprintf('Generating %i points\n',n_points);

			degree_points = linspace(start_angle,end_angle,n_points);

			points = cell(n_points,1);
			for i = 1:n_points
				points{i} = [radius_mm * sind(degree_points(i)),...
				radius_mm * cosd(degree_points(i)),...
				z_mm];
			end%for i

		end%func GeneratePointsAlongCircle

	end%methods
end%class SlotBowlGenerator