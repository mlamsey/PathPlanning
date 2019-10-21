function TestEnvironment

	n_points = 100;
	v = linspace(-1,1,n_points);
	
	%TestPlot;

end%func TestEnvironment

function TestPlot
    close all;
	T = TestPart;

    part = T.test_part;

    for i = 1:length(part.segments{1}.contours)
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