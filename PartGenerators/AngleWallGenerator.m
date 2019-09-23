classdef AngleWallGenerator

	function slice_set = GenerateAngleWall(wall_width,vert_length,angle_length,theta,layer_height)
		n_vert_layers = vert_length / layer_height;
		n_angle_layers = angle_length / layer_height;
		n_total_layers = n_vert_layers + n_angle_layers;

		slice_set = cell(n_total_layers);

		for i = 1:n_vert_layers
			z = (i-1) * layer_height;
			pos = {[0,0,z],[0,wall_width,z]};
			ori = {[0,0,0],[0,0,0]};
			slice_set{i} = Slice(pos,ori);
		end%for i

		for i = 1 + n_vert_layers:n_total_layers
			x = (i-1) * sind(theta) * layer_height;
			z = (i-1) * cosd(theta) * layer_height;
			pos = {[x,0,z],[x,wall_width,z]};
			ori = {[0,0,0],[0,0,0]};
			slice_set{i} = Slice(pos,ori);
		end%for i

	end%func GenerateAngleWall

end%class AngleWallGenerator