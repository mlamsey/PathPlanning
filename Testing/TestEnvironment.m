function TestEnvironment

	TestPlot;

end%func TestEnvironment

function TestPlot

	test_data = TestSliceData;
    slices = test_data.test_slice_set;

    close all;
    segments = Segment(slices);
    part = Part({segments});
    for i = 1:5
    	part.segments{1}.slices{i} = SliceAlgorithms.BisectMove(part.segments{1}.slices{i},rem(i,4)+1);
    end%for i
    PlotTools.PlotPartOnNewFigure(part);
    
end%func PlotTest

function TestAlgorithms

	close all;
	slice_directory = 'C:\Users\pty883\Documents\Slices\Test Box';
	part = FileTools.ImportSliceSetFromGOM(slice_directory);
	PlotTools.PlotPart(part);
	title('Before');
	part = PartAlgorithms.CombineCollinearMoves(part);
	PlotTools.PlotPart(part);
	title('After');

end%func TestAlgorithms

function TestImportASCIIFromGOM

	slice_directory = 'C:\Users\pty883\Documents\Slices\Test Box';
	part = FileTools.ImportSliceSetFromGOM(slice_directory);
	PlotTools.PlotPart(part);

end%func TestImportASCIIFromGOM

function TestGeneratePathFile

	slice_directory = 'C:\Users\pty883\Documents\Slices\Test Box';
	slices = SliceTools.ImportSliceSetFromGOM(slice_directory);

end%func TestGeneratePathFile