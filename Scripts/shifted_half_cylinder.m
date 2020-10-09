% Shifted Half Cylinder Processing
%% Import
p = FileTools.ImportPart('C:\Users\pty883\University of Tennessee\UT_MABE_Welding - Documents\MAJIC LSAM\Completed Parts\Cylinder Parts\Half Cylinder\Half Cylinder Shift Slices');

%% Processing
PartAlgorithms.CombineCollinearMoves(p);
SegmentAlgorithms.ReverseSegmentContours(p.segments{2});
PartAlgorithms.TranslatePartToPoint(p,0,0,0);

PartAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(p);
SegmentAlgorithms.ShiftTorchAnglesUsingOverhangAngle(p.segments{2});
PartAlgorithms.AlternateContourDirections(p,1);

%% Plot
f = figure;
a = axes('parent',f);
PlotTools.PlotPartSimple(p,a);
PlotTools.DefaultPlot3Setup(a);

f2 = figure;
a2 = axes('parent',f2);
for i = 1:20
	PlotTools.PlotContourWithToolCoordinateFrames(p.segments{2}.contours{i * 5},a2);
end%for i
PlotTools.PlotSegmentSimple(p.segments{1},a2);
PlotTools.PlotSegmentSimple(p.segments{2},a2);
PlotTools.SquareAxes3(a2);
view(1,1);