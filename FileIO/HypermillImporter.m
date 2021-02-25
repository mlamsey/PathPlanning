classdef HypermillImporter
    properties(Constant)
        default_speed = 2.75;
    end%properties
    
    
    methods(Static)
        function [part,import_path] = PromptForPartImportFromHypermill
            msg = questdlg('Please select a Hypermill file','INFO','OK','OK');
            [file,path] = uigetfile('*.APT');
            file_path = strcat(path,file);
            if isempty(file_path)
                fprintf('HypermillImporter::PromptForPartImportFromHypermill: No file selected!\n');
                part = 0;
                import_path = '';
            else
                part = HypermillImporter.ImportPart(file_path);
                import_path = file_path;
            end%if

        end%func PromptForPartImportFromHypermill
        
        function part = ImportPart(file_path)            
            
            
            % Instantiate iterator
            line_i = 2;
            
            % Create cell of file lines
            fileID = fopen(file_path);
            full_file = {};
            line = fgetl(fileID);
            while ischar(line)
                % Run through each line of file
                line = fgetl(fileID);
                full_file{line_i,1} = line;
                
                % iterate
                line_i=line_i+1;
            end%while
            fclose(fileID);
            
            % Assign contour
            segments{1} = HypermillImporter.ImportSegment(full_file);
            
            part = Part(segments);
        end%func HypermillImporterFile
        
        function imported_segment = ImportSegment(full_file)
            
            contour_strings = HypermillImporter.FindContourStringsFromFullFile(full_file);
            
            % Instantiate bonus iterator
            contour_i = 1;
            
            % Notice!
            fprintf('Segment Import - Hypermill Slices with default speed: %1.3f mm/s\n',HypermillImporter.default_speed);
            
            % Loop through all contours
            for i = 1:length(contour_strings)
                % Assign contour
                contours{contour_i} = HypermillImporter.ImportContour(contour_strings{i,1});
                
                % iterate
                contour_i = contour_i + 1;
            end%for i
            
            imported_segment = Segment(contours);
        end%func ImportSegment
        
        function contour_strings = FindContourStringsFromFullFile(full_file)
            % Instantiate bonus iterators
            contour_point_i=1;
            contour_i=1;
            
            % Create contour reading value
            contour_reading = 0;
            
            single_contour = {};
            for i = 1:length(full_file)
                current_line = full_file{i,1};
                
                % check if start of contour is reached
                if strncmpi(current_line,'FEDRAT/ 50',10)==1
                    % Start recording contour values
                    contour_reading = 1;
                    
                    % Set start of contour index
                    contour_start = i+1;
                end%if
                
                % check if end of contour is reached
                if strncmpi(current_line,'RAPID',5)==1 && contour_reading==1
                    % Stop recording contour values
                    contour_reading = 0;
                    
                    % Set end of contour index
                    contour_end = i-1;
                    
                    % Create single contour cell of waypoint strings
                    contour_point_i=1;
                    for j = contour_start:contour_end
                        if strncmpi(full_file{j,1},'GOTO',4)==1
                        single_contour{contour_point_i,1} = full_file{j,1};
                        contour_point_i=contour_point_i+1;
                        end%if
                    end%for j
                    
                    % Create cell of contours
                    if size(single_contour,1) > 1
                        contour_strings{contour_i,1} = single_contour;
                        contour_i=contour_i+1;
                    end%if
                    
                    % Clear single contour cell
                    single_contour = {};
                end%if
            end%for i
        end%func FindContourStringsFromFullFile
        
        function imported_contour = ImportContour(contour_string)
            % Input: Contour string cell
            % Output: XYZ contour points
            
            % Extract XYZ contour points from strings
            for i = 1:length(contour_string)
                % Convert waypoint string to matrix
                waypoint_number_cell = regexp(contour_string(i),'\-?\d+[\.]?\d*','match');
                waypoint = str2double([waypoint_number_cell{1}]);

                x(i,1) = waypoint(1,1);
                y(i,1) = waypoint(1,2);
                z(i,1) = waypoint(1,3);
            end%for i
            
            positions = cell(length(x),1);
            orientations = cell(length(x),1);
            
            for i = 1:length(positions)
                positions{i} = [x(i),y(i),z(i)];
                orientations{i} = quaternion.ones;
            end%for i
            
            % Spoof speed
            speeds = cell(length(positions),1);
            for j = 1:length(positions)
                speeds{j} = FileTools.default_speed;
            end%for i
            
            imported_contour = Contour(positions,orientations,speeds);
            
        end%func ImportContour

    end%Static Methods
end%class HypermillImporter