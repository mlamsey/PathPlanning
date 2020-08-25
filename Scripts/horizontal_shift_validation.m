%% Import
% Script for Horizontal Wall Shift Validation

part = FileTools.PromptForPartImportFromGOM;
n_segments = length(p.segments);

%% Cleanup
% Clean up raw part import
PartAlgorithms.CombineCollinearMoves(part);

minimum_move_length = 3; % mm
PartAlgorithms.DecimateContoursByMoveLength(part,minimum_move_length);

manifest_all_simultaneous = 1:n_segments;
PartAlgorithms.ParallelizeSegments(part,manifest_all_simultaneous);

%% Shift
% Set shift
for i = 1:n_segments
	% INSERT SHIFT BELOW
	shift = Shift(0,0,0,0,0,0); % x,y,z,a,b,c
    
	SegmentAlgorithms.SetSegmentShift(part.segments{i},shift);
end%for i

%% Angle Offset
% Set angle offsets
wall_angles = [-40,-30,-20,-10,0,10,20,30,40];
wall_rotation_axis = 'x';

for i = 1:n_segments
	rotation_angle = wall_angles(i);
	SegmentAlgorithms.RotateSegmentPointsAboutToolFrames(part.segments{i},rotation_angle,wall_rotation_axis);
end%for i

%% Export
file_path = 'Shifted_Walls.path';
PathFileWriter.WritePart(file_path,part);