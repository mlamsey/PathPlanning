function TestEnvironment

	TestPlot;

end%func TestEnvironment

function TestPlot

	test_data = TestContourData;
    contours = test_data.test_contour_set;

    close all;
    segments = Segment(contours);
    part = Part({segments});
    for i = 1:length(contours)
    	contour_i = part.segments{1}.contours{i};

    	ContourAlgorithms.BisectMove(contour_i,rem(i,length(contour_i.moves))+1);
    	ContourAlgorithms.StaggerStartByMoves(contour_i,rem(i-1,length(contour_i.moves) - 1)+1);
    	if(rem(i,2) == 0)
    		ContourAlgorithms.ReverseContourPointOrder(contour_i);
    	end%if
    end%for i
    PlotTools.PlotPartOnNewFigure(part);
    
end%func PlotTest

function TestAlgorithms

	close all;
	contour_directory = 'C:\Users\pty883\Documents\Contours\Test Box';
	part = FileTools.ImportContourSetFromGOM(contour_directory);
	PlotTools.PlotPart(part);
	title('Before');
	part = PartAlgorithms.CombineCollinearMoves(part);
	PlotTools.PlotPart(part);
	title('After');

end%func TestAlgorithms

function TestImportASCIIFromGOM

	contour_directory = 'C:\Users\pty883\Documents\Contours\Test Box';
	part = FileTools.ImportContourSetFromGOM(contour_directory);
	PlotTools.PlotPart(part);

end%func TestImportASCIIFromGOM

function TestGeneratePathFile

	contour_directory = 'C:\Users\pty883\Documents\Contours\Test Box';
	contours = ContourTools.ImportContourSetFromGOM(contour_directory);

end%func TestGeneratePathFile