classdef PlotTools
	methods(Static)
        function figure_ref = PlotPartOnNewFigure(part_data)
            f = figure;
            a = axes('parent',f);
            view(45,25);
            PlotTools.PlotPart(part_data,a);
        end%func PlotPartOnNewFigure

		function figure_ref = PlotPart(part_data,parent_axes)
            fprintf('Plotting Part...');
			if(~isa(part_data,'Part'))
				fprintf('PlotTools::PlotPart: Input not a part\n');
			end%if

			segments = part_data.segments;

			hold on;
			for i = 1:length(segments)
                if(nargin == 1)
    				PlotTools.PlotSegment(segments{i});
                elseif(nargin == 2)
                    PlotTools.PlotSegment(segments{i},parent_axes);
                else
                    fprintf('PlotTools::PlotPart: incorrect number of arguments.\n');
                    break;
                end%if
			end%for i
            hold off;

            fprintf(' Done!\n');

		end%func PlotPart

		function ref = PlotSegment(segment_data,parent_axes)
            if(~isa(segment_data,'Segment'))
                fprintf('PlotTools::PlotSliceSet: Input not a segment\n');
            end%if

            slices = segment_data.slices;
            
            for i = 1:length(slices)
                if(nargin == 1)
                    PlotTools.PlotSlice(slices{i});
                elseif(nargin == 2)
                    PlotTools.PlotSlice(slices{i},parent_axes);
                else
                    fprintf('PlotTools::PlotSegment: incorrect number of arguments.\n');
                    break;
                end%if
            end%for i

        end%func PlotSliceSet

        function ref = PlotSlice(slice_data,parent_axes)
            if(~isa(slice_data,'Slice'))
                fprintf('PlotTools::PlotSlice: Input not a slice!\n');
                return;
            end%if

            moves = slice_data.moves;
            ref = cell(length(moves),1);
            for i = 1:length(moves)
                if(nargin == 1)
                    ref{i} = PlotTools.PlotMove(moves{i});
                elseif(nargin == 2)
                    ref{i} = PlotTools.PlotMove(moves{i},parent_axes);
                else
                    fprintf('PlotTools::PlotSlice: incorrect number of arguments.\n');
                    ref{i} = null;
                    break;
                end%if

                % Color: Green [0,1,0] = Start, Red [1,0,0] = End
                if(i == 1)
                    ref{i}.Color = [0,1,0];
                elseif(i == length(moves))
                    ref{i}.Color = [1,0,0];
                end%if

            end%for i

        end%func PlotSlice

        function ref = PlotMove(move,parent_axes)
            if(~isa(move,'Move'))
                fprintf('PlotTools::PlotMove: Input not a Move!\n');
                return;
            end%if

            p1 = move.point1;
            p2 = move.point2;

            x = [p1.x,p2.x];
            y = [p1.y,p2.y];
            z = [p1.z,p2.z];

            ref = line(x,y,z,'color','k','marker','o','parent',parent_axes,'tag','move_line');

        end%func PlotMove
	end%methods
end%class PlotTooles