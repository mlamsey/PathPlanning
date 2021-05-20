classdef Build < handle & matlab.mixin.Copyable
	properties
		parts;
		robot_model;
	end%properties

	methods
		function obj = Build(parts,robot_model)
			if(~isa(parts,'cell'))
				fprintf('Build::Build: Input 1 not a cell array!\n');
				return;
			end%if
			if(~isa(robot_model,'RobotModel'))
				fprintf('Build::Build: Input 2 not a RobotModel!\n');
				return;
			end%if
			obj.parts = parts;
			obj.robot_model = robot_model;
		end%Constructor
	end%methods
end%class Build