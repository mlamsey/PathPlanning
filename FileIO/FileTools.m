classdef FileTools
    properties(Constant)
        default_speed = 6.418;
    end%properties

    methods(Static)
        function part = PromptForPartImportFromGOM
            msg = questdlg('Please select a folder containing contours from GOM','ContourManipulator INFO','OK','OK');
            directory = uigetdir;
            if(~directory)
                fprintf('FileTools::PromptForPartImportFromGOM: No directory selected!\n');
                part = 0;
            else
                part = FileTools.ImportContourSetFromGOM(directory);
            end%if

        end%func PromptForPartImportFromGOM

        function part = ImportContourSetFromGOM(file_path)
            part = Part({Segment(FileTools.ImportGOMPath(file_path))});
        end%func ImportContourSetFromGOM

        function contours = ImportGOMPath(directory_path)
            % Input: absolute path to the directory to import
            % Output: 1D array of [x,y,z] lists (n x 3 double)

            % Get directory information
            dir_info = dir(directory_path);
            n_files = length(dir_info);
            %fprintf('%i files found\n',n_files);

            % Instantiate bonus iterators
            n_files_read = 0;
            contour_i = 1;

            % Notice!
            fprintf('GOM Import with default speed: %1.3f mm/s\n',FileTools.default_speed);

            % Loop through all files
            for i = 1:n_files
                file_name = dir_info(i).name;

                % check if filenames are NOT navigation targets
                if(~strcmp(file_name,'.') && ~strcmp(file_name,'..'))
                    % Generate path, import contour data, assign contour in set
                    if(ispc)
                        full_path = strcat(dir_info(i).folder,'\',file_name);
                    else
                        full_path = strcat(dir_info(i).folder,'/',file_name);
                    end%if
                    [positions,orientations] = FileTools.ImportContour(full_path);

                    % Spoof speed
                    speeds = cell(length(positions),1);
                    for j = 1:length(positions)
                        speeds{j} = FileTools.default_speed;
                    end%for i

                    % Assign contour
                    contours{contour_i} = Contour(positions,orientations,speeds);

                    % iterate
                    contour_i = contour_i + 1;
                    n_files_read = n_files_read + 1;
                end

            end%for i

            %fprintf('%i files read\n',n_files_read);

        end%func ImportGOMPath

        function [positions,orientations] = ImportContour(file_path)
            % Input: absolute path to contour file
            % Output: XYZ contour points

            raw_data = dlmread(file_path,' ',1,1);
            x = raw_data(:,1);
            y = raw_data(:,2);
            z = raw_data(:,3);

            positions = cell(length(x),1);
            orientations = cell(length(x),1);

            for i = 1:length(positions)
                positions{i} = [x(i),y(i),z(i)];
                orientations{i} = quaternion.ones;
            end%for i

        end%func

        function PadFileNameZerosForPlaneOffset(filename_prefix,directory)
            % Pads filenames for the output from GOM's planar slice export
            % filename_prefix specifies to only pad files containing that substring
            working_dir = dir(directory);
            if(length(working_dir) == 0)
                fprintf('FileTools::PadFileNameZeros: Directory not found\n');
                return;
            end%if

            mm_delimiter = '+';
            end_delimiter = ' ';

            % Find maximum order of magnitude
            mm_values = [];

            for i = 1:length(working_dir)
                filename = working_dir(i).name;
                if(contains(filename,filename_prefix))
                    mm_index = strfind(filename,mm_delimiter) + 1;
                    end_number_index = strfind(filename(mm_index:end),end_delimiter) + mm_index - 1;
                    mm_values = [mm_values,str2num(filename(mm_index:end_number_index))];
                end%if
            end%for i

            max_mm_order = floor(log10(max(mm_values)));

            % Pad files
            for i = 1:length(working_dir)
                filename = working_dir(i).name;
                old_file_string = strcat(working_dir(i).folder,'\',filename);

                if(contains(filename,filename_prefix))
                    mm_index = strfind(filename,mm_delimiter) + 1;
                    end_number_index = strfind(filename(mm_index:end),end_delimiter) + mm_index - 1;
                    mm_value = str2num(filename(mm_index:end_number_index));

                    mm_order = floor(log10(mm_value));
                    if(mm_order < 0)
                        mm_order = 0;
                    end%if

                    while(mm_order < max_mm_order)
                        filename = strcat(filename(1:mm_index-1),'0',filename(mm_index:end));
                        mm_order = mm_order + 1;
                    end%while

                    new_file_string = strcat(working_dir(i).folder,'\',filename);

                    if(~strcmp(old_file_string,new_file_string))
                        movefile(old_file_string,new_file_string);
                    end%if
                end%if
            end%for i

        end%func PadFileNameZeros

    end%Static Methods
end%class ContourTools