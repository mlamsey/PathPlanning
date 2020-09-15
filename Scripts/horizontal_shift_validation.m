%% Import
% Script for Horizontal Wall Shift Validation
if(~exist('reimport','var'))
	reimport = true;
end%if

if(reimport)
	part = FileTools.PromptForPartImportFromGOM;
	n_segments = length(part.segments);

	%% Cleanup
	% Clean up raw part import
	PartAlgorithms.CombineCollinearMoves(part);

	minimum_move_length = 3; % mm
	PartAlgorithms.DecimateContoursByMoveLength(part,minimum_move_length);
	PartAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(part);

	manifest_all_simultaneous = 1:n_segments;
	PartAlgorithms.ParallelizeSegments(part,manifest_all_simultaneous);

	% Rest of commands
	PartAlgorithms.AlternateContourDirections(part,1);
	PartAlgorithms.TranslatePartToPoint(part,-88.9,31.75,0);

	reimport = false;
end%if

%% Shift
% Set shift
if(~exist('shiftpos','var'))
	shiftpos = true;
end%if

% 45
shifts = [1.941, 0.9158, 0.611, -0.221, 0.3329, 0.8196, 0.1263, -0.4002, -1.978];
% 65
% shifts = [4.8369, 3.8607, 2.0646, 0.4356, 0.8402, 0.4972, -0.3417, -0.6770, -3.2889];
%90
% shifts = [-0.3549, -0.1903, -0.1488, -0.0152, 0.8907, 1.5158, 2.0144, 1.5433, 0.2923];

if(shiftpos)
	for i = 1:n_segments
		y = shifts(i);
		shift = Shift(0,y,0,0,0,0); % x,y,z,a,b,c
	    
		SegmentAlgorithms.SetSegmentShift(part.segments{i},shift);
	end%for i
	shiftpos = false;
end%if

%% Angle Offset
% Set angle offsets
if(~exist('shiftangle','var'))
	shiftangle = true;
end%if

if(shiftangle)
	wall_angles = [40,30,20,10,0,-10,-20,-30,-40];
	wall_rotation_axis = 'x';

	for i = 1:n_segments
		rotation_angle = wall_angles(i);
		SegmentAlgorithms.RotateSegmentPointsAboutToolFrames(part.segments{i},rotation_angle,wall_rotation_axis);
	end%for i
	shiftangle = false;
end%if

%% Export
if(~exist('export','var'))
	export = true;
end%if
if(export)
	file_path = '45_Shifted_Walls.path';
	PathFileWriter.WritePartWithManifest(file_path,part);
	export = false;
end%if