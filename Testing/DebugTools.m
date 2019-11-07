classdef DebugTools
	methods(Static)
		function CheckRotationMatrixFromQuaternion
			normal_vector = [0,sqrt(2)/2,sqrt(2)/2];
			travel_vector = [1,0,0];
			if(dot(normal_vector,travel_vector))
				fprintf('DebugTools::CheckRotationMatrixFromQuaternion: Normal and Travel vectors not perpendicular\n');
				return;
			end%if

			y_vector = cross(normal_vector,travel_vector);
			
			R = [travel_vector',y_vector',normal_vector']
			q1 = quaternion(R,'rotmat','frame')
			q2 = Utils.GetQuaternionFromNormalVectorAndTravelVector(normal_vector,travel_vector)
			R1 = rotmat(q1,'frame')
			R2 = rotmat(q2,'frame')
			eulerd(q1,'ZYX','frame')

		end%func CheckRotationMatrixFromQuaternion

		function PlotContourEulerAngles(contour_data)
			a = zeros(length(contour_data.moves),1);
			b = a;
			c = a;

			for i = 1:length(contour_data.moves)
				current_point = contour_data.moves{i}.point1;
				[ai,bi,ci] = Utils.GetABCFromQuaternion(current_point.torch_quaternion);
				a(i) = ai;
				b(i) = bi;
				c(i) = ci;
			end%for i
			plot(a);
			hold on;
			plot(b);
			plot(c);
			hold off;
			legend('A/X','B/Y','C/Z');
			xlabel('Move Index (i)');
			ylabel('Euler Angle (Degrees)');
			grid on;

		end%func PlotContourEulerAngles

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
                R = rotmat(q,'frame');
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

        function PlotVectorProjection(a,b)
            [a1,a2] = Utils.VectorProjection(a,b);

            quiver3(0,0,0,a(1),a(2),a(3),'color','k','autoscalefactor',1);
            hold on;
            quiver3(0,0,0,b(1),b(2),b(3),'color',[.2,.2,.2],'autoscalefactor',1);
            quiver3(0,0,0,a1(1),a1(2),a1(3),'color','r','autoscalefactor',1);
            quiver3(a1(1),a1(2),a1(3),a2(1),a2(2),a2(3),'color','g','autoscalefactor',1);
            hold off;
        end%func PlotVectorProjection

        function PlotNumberOfMovesInEachContourForPart(original_part)
            if(~isa(original_part,'Part'))
                fprintf('PartAlgorithms::PlotNumberOfMovesInEachContour: Input not a part\n');
                return;
            end%if

            f = figure;
            a = axes('parent',f);

            move_counts = [];

            for i = 1:length(original_part.segments)
                for j = 1:length(original_part.segments{i}.contours)
                    move_counts = [move_counts,length(original_part.segments{i}.contours{j}.moves)];
                end%for j
            end%for i

            plot(move_counts);
            title('Number of Moves Per Contour');
            xlabel('Contour Index');
            ylabel('Number of Moves');
            grid on;

        end%func PlotNumberOfMovesInEachContour
	end%methods
end%class DebugTools