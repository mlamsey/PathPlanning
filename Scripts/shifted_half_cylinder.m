% Shifted Half Cylinder Processing
%% Import
p = FileTools.ImportPart('C:\Users\pty883\University of Tennessee\UT_MABE_Welding - Documents\MAJIC LSAM\Completed Parts\Cylinder Parts\Half Cylinder\Half Cylinder Shift Slices');

%% Processing
PartAlgorithms.CombineCollinearMoves(p);
SegmentAlgorithms.ReverseSegmentContours(p.segments{2});
PartAlgorithms.TranslatePartToPoint(p,0,0,0);

PartAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(p);
% SegmentAlgorithms.CalculateShift for Segment 2
PartAlgorithms.AlternateContourDirections(p,1);

%% Plot
f = figure;
a = axes('parent',f);
PlotTools.PlotPartSimple(p,a);
PlotTools.DefaultPlot3Setup(a);