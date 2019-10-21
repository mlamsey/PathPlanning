classdef DebugTools
	methods(Static)
		function IterativeSegmentQuatPlot(seg)
            for i = 1:length(seg.contours)
                p = PlotTools.PlotContourWithTorchQuaternions(seg.contours{i});
                title(p,num2str(i));
                pause;
            end%for i
        end%func IterativeSegmentQuatPlot

        function ref = PlotContourWithTorchQuaternions(previous_contour,this_contour)
            if(~isa(previous_contour,'Contour') || ~isa(this_contour,'Contour'))
                fprintf('DebugTools::PlotContourWithTorchQuaternions: Inputs not a contour\n');
                return;
            end%if

            close all;
            f = figure('units','normalized','outerposition',[0,0,1,1]);
            a = axes('parent',f);
            view(25,45);
            hold on;

            for i = 1:length(this_contour.moves)
                move = this_contour.moves{i};
                q = move.point1.torch_quaternion;
                R = rotmat(q,'point');
                v = 25.*(R*[0;0;-1]);

                x = move.point1.x;
                y = move.point1.y;
                z = move.point1.z;

                x = x - v(1);
                y = y - v(2);
                z = z - v(3);

                %fprintf('%i: x:%1.3f y:%1.3f z:%1.3f a:%1.3f b:%1.3f z:%1.3f\n',i,x,y,z,v(1),v(2),v(3));
                quiver3(x,y,z,v(1),v(2),v(3),...
                    'color','k',...
                    'linewidth',0.5,...
                    'autoscale','on',...
                    'maxheadsize',2);
                % hold off;
                % pause;
                % hold on;
            end%for i

            PlotTools.PlotContour(previous_contour,a);
            PlotTools.PlotContour(this_contour,a);

            hold off;
            view(25,45);
            grid on;
            zlim([0,max(xlim)]);
            xlabel('X (mm)');
            ylabel('Y (mm)');
            zlabel('Z (mm)');

            PlotTools.BufferPlotAxes(a,0.25);

            ref = a;

        end%func PlotContourWithTorchQuaternions
	end%methods
end%class DebugTools