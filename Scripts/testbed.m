SegmentAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(p.segments{2});
figure; axes;
for i = 1:20
	PlotTools.PlotContourWithToolCoordinateFrames(p.segments{2}.contours{i * 5},gca);
end%for i
PlotTools.PlotSegmentSimple(p.segments{2},gca);
PlotTools.SquareAxes3(gca);
view(0,0);

SegmentAlgorithms.ShiftTorchAnglesUsingOverhangAngle(p.segments{2});
figure; axes;
for i = 1:20
	PlotTools.PlotContourWithToolCoordinateFrames(p.segments{2}.contours{i * 5},gca);
end%for i
PlotTools.PlotSegmentSimple(p.segments{2},gca);
PlotTools.SquareAxes3(gca);
view(0,0);