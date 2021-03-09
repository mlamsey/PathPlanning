classdef SegmentAlgorithms
	methods(Static)

		function DecimateContoursByMoveLength(original_segment,mm_decimate_move_length)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::DecimateContoursByMoveLength: Input not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.DecimateContourByMoveLength(original_segment.contours{i},mm_decimate_move_length);
			end%for i
		end%func DecimateContoursByMoveLength

		function CombineCollinearMoves(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::CombineCollinearMoves: Input not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.CombineCollinearMoves(original_segment.contours{i});
			end%for i
		end%func CombineLinearMoves

		function UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane(original_segment,plane_vector)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane: Input not a segment\n');
				return;
			end%if

			if(length(original_segment.contours) > 1)
				ContourAlgorithms.UpdateNextContourTorchRotInterContourVectorsFixedXPlane(original_segment.contours{1},original_segment.contours{2},plane_vector)
				% for i = 2:end b/c first contour has GA torch orientation
				for i = 2:length(original_segment.contours)
					fprintf('Calculating Quaternions for Layer %i\n',i);
					previous_contour = original_segment.contours{i-1};
					this_contour = original_segment.contours{i};
					ContourAlgorithms.UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane(this_contour,previous_contour,plane_vector);
				end%for i
			end%if

		end%func UpdateTorchAnglesUsingInterContourVectorsWithFixedTravelPlane

		function UpdateTorchQuaternionsUsingInterContourVectors(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::UpdateTorchQuaternionsUsingInterContourVectors: Input not a segment\n');
				return;
			end%if

			if(length(original_segment.contours) > 1)
				ContourAlgorithms.UpdateNextContourTorchRotationUsingInterContourVectors(original_segment.contours{1},original_segment.contours{2});

				% for i = 2:end b/c first contour has GA torch orientation
				for i = 2:length(original_segment.contours)
					fprintf('Calculating Quaternions for Layer %i\n',i);
					previous_contour = original_segment.contours{i-1};
					this_contour = original_segment.contours{i};
					ContourAlgorithms.UpdateTorchQuaternionsUsingInterContourVectors(this_contour,previous_contour);
				end%for i
			else
				ContourAlgorithms.UpdateTorchQuaternionsUsingTravelVectorOnly(original_segment.contours{1});
			end%if
		end%func UpdateTorchQuaternionsUsingInterContourVectors

		function ShiftTorchAnglesUsingOverhangAngle(original_segment)
			theta = zeros(1,length(original_segment.contours)-1);
			shift = theta;

			for i = 2:length(original_segment.contours)
				this_contour = original_segment.contours{i};
				previous_contour = original_segment.contours{i - 1};
				[thetas,shifts] = ContourAlgorithms.ShiftTorchAngleUsingOverhangAngle(this_contour,previous_contour);
				theta(i-1) = mean(thetas);
				shift(i-1) = mean(shifts);
			end%for i

			% Uncomment below for debug plotting
			plot(-1.*theta);
			hold on;
			plot(-1.*(theta - shift));
			hold off;
			grid on;
			xlabel('Contour Number');
			ylabel('Angle (degrees)');
			legend('Overhang Angle','Optimal Torch Angle');
		end%func ShiftTorchAnglesUsingOverhangAngle

		function SetSegmentShift(original_segment,shift)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::SetSegmentShift: Input 1 not a Segment\n');
				return;
			end%if

			if(~isa(shift,'Shift'))
				fprintf('SegmentAlgorithms::SetSegmentShift: Input 2 not a Shift\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.SetContourShift(original_segment.contours{i},shift);
			end%for i
		end%func SetSegmentShift

		function DetermineGravityAlignment(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::DetermineGravityAlignment: Input not a Segment\n');
				return;
			end%if
			fprintf('Determining Gravity Alignment of Segment...\n');

			n_contours = length(original_segment.contours);
			% Counters for GA and NGA layers
			n_ga = 0;
			n_nga = 0;

			for i = 2:n_contours
				current_contour = original_segment.contours{i};
				previous_contour = original_segment.contours{i - 1};
				n_moves = length(current_contour.moves);
				
				previous_closest_move_index = 1;

				contour_is_ga = logical(ones(1,n_moves));

				for j = 1:n_moves
					current_move = current_contour.moves{i};
					[normal_vector,previous_closest_move_index,~] = ContourAlgorithms.GetNormalVectorFromClosestMoveOnPreviousContour(current_move,previous_contour,previous_closest_move_index);

					normal_vector = normal_vector ./ norm(normal_vector);
					if(abs(dot(normal_vector,[0,0,1])) < 0.999)
						contour_is_ga(j) = false;
					end%if
				end%for j

				if(contour_is_ga)
					n_ga = n_ga + 1;
				else
					n_nga = n_nga + 1;
				end%if
			end%for i
			fprintf('%i GA contours and %i NGA contours identified\n',n_ga,n_nga);

			if(n_ga == 0 && n_nga > 0)
				original_segment.segment_type = 'NGA';
			elseif(n_ga > 0 && n_nga == 0)
				original_segment.segment_type = 'GA';
			else
				original_segment.segment_type = 'TZ';
			end%if
		end%func DetermineGravityAlignment

		function StaggerSegmentStartPoints(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::StaggerSegmentStartPoints: Input not a segmetn\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				contour_i = original_segment.contours{i};
				max_stagger = length(contour_i.moves);

				number_of_moves_to_stagger_by = i;
				if(number_of_moves_to_stagger_by > max_stagger)
					number_of_moves_to_stagger_by = max_stagger - 1;
				end%if

				ContourAlgorithms.StaggerStartByMoves(contour_i,number_of_moves_to_stagger_by);
			end%for i
		end%func StaggerContourStartPoints

		function StaggerSegmentStartPointsByIndices(original_segment,indices_per_layer)
			for i = 1:length(original_segment.contours)
				n_moves = length(original_segment.contours{i}.moves);
				number_of_moves_to_stagger_by = mod(i * indices_per_layer,n_moves);
				ContourAlgorithms.StaggerStartByMoves(original_segment.contours{i},number_of_moves_to_stagger_by);
			end%for i
		end%func StaggerSegmentStartPointsByIndices

		function AlternateContourDirections(original_segment, number_of_layers_per_alternation)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::AlternateContourDirections: Input 1 not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				if(rem(i,number_of_layers_per_alternation + 1) == 0)
					for j = 1:number_of_layers_per_alternation
						if(j <= length(original_segment.contours))
							ContourAlgorithms.ReverseContourPointOrder(original_segment.contours{i});
						end%if
					end%for j
				end%if
			end%for i

		end%func AlternateContourDirections

		function ReverseSegmentContours(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::ReverseSegmentContours: Input not a Segment\n');
				return;
			end%if

			original_segment.contours = flip(original_segment.contours);
		end%func ReverseSegmentContours

		function ReverseSegmentContourDirections(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SesgmentAlgorithms::ReverseSegmentContourDirections: Input not a Segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.ReverseContourPointOrder(original_segment.contours{i});
			end%for i
		end%func ReverseSegmentContourDirections

		function RepairContourEndContinuity(original_segment)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::RepairContourEndContinuity: Input 1 not a segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.RepairContourEndContinuity(original_segment.contours{i});
			end%for i
		end%func RepairContourEndContinuity

		function RepairSubsetOfContourEndContinuity(original_segment,subset_indices)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::RepairSubsetOfContourEndContinuity: Input 1 not a part\n');
				return;
			end%if

			n_contours = length(original_segment.contours);

			if(max(subset_indices) > n_contours || min(subset_indices) < 1)
				fprintf('SegmentAlgorithms::RepairSubsetOfContourEndContinuity: Input 2 outside contour index range\n');
				return;
			end%if

			for i = 1:length(subset_indices)
				current_index = subset_indices(i);
				ContourAlgorithms.RepairContourEndContinuity(original_segment.contours{current_index});
			end%for i

		end%func RepairSubsetOfContourEndContinuity

		function RotateSegmentPointsAboutToolFrames(original_segment,degrees_to_rotate,axis_name)
			if(~isa(original_segment,'Segment'))
				fprintf('SegmentAlgorithms::RotateSegmentPointsAboutToolFrames: Input 1 not a Segment\n');
				return;
			end%if

			for i = 1:length(original_segment.contours)
				ContourAlgorithms.RotateContourPointsAboutToolFrames(original_segment.contours{i},degrees_to_rotate,axis_name);
			end%for i
		end%func RotateSegmentPointsAboutToolFrames
        
        function TranslateSegment(original_segment,x_translate,y_translate,z_translate)
            if(~isa(original_segment,'Segment'))
                fprintf('SegmentAlgorithms::TranslateSegment: Input 1 not a Segment\n');
                return;
            end%if
            
            for i = 1:length(original_segment.contours)
                ContourAlgorithms.TranslateContour(original_segment.contours{i},x_translate,y_translate,z_translate);
            end%for i
        end%func TranslateSegment
	end%methods
end%class SegmentAlgorithms