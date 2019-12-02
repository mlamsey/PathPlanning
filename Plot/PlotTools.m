classdef PlotTools
	methods(Static)
        function figure_ref = PlotPartSimple(part_data,parent_axes)
            if(~isa(part_data,'Part'))
                fprintf('PlotTools::PlotPartSimple: Input is not a Part\n');
                figure_ref = null;
                return;
            end%if

            hold on;

            for i_segment = 1:length(part_data.segments)
                current_segment = part_data.segments{i_segment};
                for i_contour = 1:length(current_segment.contours)
                    current_contour = current_segment.contours{i_contour};
                    [x,y,z] = ContourAlgorithms.GetContourWaypointVectors(current_contour);
                    plot3(x,y,z,'k-','parent',parent_axes,'tag','simple_plot');
                end%for i_contour
            end%for i_segment

            hold off;

        end%func PlotPartSimple

        function figure_ref = PlotPartOnNewFigure(part_data)
            f = figure;
            a = axes('parent',f,'gridcolor',[0,0,0],'gridalpha',0.5);
            view(45,25);
            grid on;
            PlotTools.PlotPart(part_data,a);
        end%func PlotPartOnNewFigure

		function figure_ref = PlotPart(part_data,parent_axes)
            if(nargin ~= 2)
                fprintf('PlotTools.PlotPart: Not enough input arguments\n');
                return;
            end%if

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

            PlotTools.BufferPlotAxes(parent_axes,0.15);

            parent_axes.GridColor = [0,0,0];
            parent_axes.GridAlpha = 0.5;
            view(45,25);
            grid on;

            fprintf(' Done!\n');

		end%func PlotPart

		function ref = PlotSegment(segment_data,parent_axes)
            if(~isa(segment_data,'Segment'))
                fprintf('PlotTools::PlotContourSet: Input not a segment\n');
            end%if

            contours = segment_data.contours;
            
            for i = 1:length(contours)
                if(nargin == 1)
                    PlotTools.PlotContour(contours{i});
                elseif(nargin == 2)
                    PlotTools.PlotContour(contours{i},parent_axes);
                else
                    fprintf('PlotTools::PlotSegment: incorrect number of arguments.\n');
                    break;
                end%if
            end%for i

        end%func PlotContourSet

        function ref = PlotContour(contour_data,parent_axes)
            if(~isa(contour_data,'Contour'))
                fprintf('PlotTools::PlotContour: Input not a contour!\n');
                return;
            end%if

            moves = contour_data.moves;
            ref = cell(length(moves),1);
            for i = 1:length(moves)

                % Color: Green [0,1,0] = Start, Red [1,0,0] = End, Black [0,0,0] = else
                if(i == 1)
                    color_vector = [0,1,0];
                elseif(i == length(moves))
                    color_vector = [1,0,0];
                else
                    color_vector = [0,0,0];
                end%if

                if(nargin == 1)
                    if(i == 1)
                        ref{i} = PlotTools.PlotMoveVector(moves{i},gca,color_vector);
                    else
                        ref{i} = PlotTools.PlotMoveLine(moves{i},gca,color_vector);
                    end%if
                elseif(nargin == 2)
                    if(i == 1)
                        ref{i} = PlotTools.PlotMoveVector(moves{i},parent_axes,color_vector);
                    else
                        ref{i} = PlotTools.PlotMoveLine(moves{i},parent_axes,color_vector);
                    end%if
                else
                    fprintf('PlotTools::PlotContour: incorrect number of arguments.\n');
                    ref{i} = null;
                    break;
                end%if

            end%for i

        end%func PlotContour

        function ref = PlotMoveLine(move,parent_axes,color_vector)
            if(~isa(move,'Move'))
                fprintf('PlotTools::PlotMoveLine: Input not a Move!\n');
                return;
            end%if

            p1 = move.point1;
            p2 = move.point2;

            x = [p1.x,p2.x];
            y = [p1.y,p2.y];
            z = [p1.z,p2.z];

            if(nargin == 2)
                ref = line(x,y,z,'color','k','marker','o',...
                'parent',parent_axes,'tag','move_line');
            elseif(nargin == 3)
                ref = line(x,y,z,'color',color_vector,'marker','o',...
                'parent',parent_axes,'tag','move_line');
            else
                fprintf('PlotTools::PlotMoveLine: Wrong number of inputs\n');
            end%if
        end%func PlotMoveLine

        function ref = PlotMoveVector(move,parent_axes,color_vector)
            if(~isa(move,'Move'))
                fprintf('PlotTools::PlotMoveVector: Input not a move\n');
                ref = null;
                return;
            end%if

            p1 = move.point1;
            p2 = move.point2;

            x = [p1.x,p2.x];
            y = [p1.y,p2.y];
            z = [p1.z,p2.z];

            dx = p2.x - p1.x;
            dy = p2.y - p1.y;
            dz = p2.z - p1.z;

            if(nargin == 2)
                ref = quiver3(p1.x,p1.y,p1.z,dx,dy,dz,0,...
                    'parent',parent_axes,...
                    'color','k',...
                    'autoscale','off',...
                    'tag','move_line',...
                    'linewidth',2);
            elseif(nargin == 3)
                ref = quiver3(p1.x,p1.y,p1.z,dx,dy,dz,0,...
                    'parent',parent_axes,...
                    'color',color_vector,...
                    'autoscale','off',...
                    'tag','move_line',...
                    'linewidth',2);
            else
                fprintf('PlotTools::PlotMoveVector: Wrong number of inputs\n');
            end%if
        end%func PlotMoveVector

        function ref = BufferPlotAxes(ax,percent_buffer)
            x_lim = xlim(ax);
            y_lim = ylim(ax);
            z_lim = zlim(ax);

            x_range = x_lim(2) - x_lim(1);
            y_range = y_lim(2) - y_lim(1);
            z_range = z_lim(2) - z_lim(1);

            x_inc = percent_buffer * x_range;
            y_inc = percent_buffer * y_range;
            z_inc = percent_buffer * z_range;

            xlim([x_lim(1) - x_inc, x_lim(2) + x_inc]);
            ylim([y_lim(1) - y_inc, y_lim(2) + y_inc]);
            zlim([z_lim(1) - z_inc, z_lim(2) + z_inc]);

        end%func BufferPlotAxes
	end%methods
end%class PlotTooles