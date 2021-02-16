classdef FileTools
    properties(Constant)
        default_speed = 2.75;
    end%properties

    methods(Static)
        function [part,import_path] = PromptForPartImportFromGOM
            msg = questdlg('Please select a folder containing contours from GOM','INFO','OK','OK');
            directory = uigetdir;
            if(~directory)
                fprintf('FileTools::PromptForPartImportFromGOM: No directory selected!\n');
                part = 0;
                import_path = '';
            else
                part = FileTools.ImportPart(directory);
                import_path = directory;
            end%if

        end%func PromptForPartImportFromGOM

        function part = ImportPart(part_directory)
             % Get directory information
            dir_info = dir(part_directory);
            n_paths = length(dir_info);

            % Instantiate bonus iterator
            segment_i = 1;

            % Loop through all files
            for i = 1:n_paths
                path_name = dir_info(i).name;

                % check if filenames are NOT navigation targets
                if(~strcmp(path_name,'.') && ~strcmp(path_name,'..'))
                    % Generate path, import contour data, assign contour in set
                    if(ispc)
                        full_path = strcat(dir_info(i).folder,'\',path_name);
                    else
                        full_path = strcat(dir_info(i).folder,'/',path_name);
                    end%if

                    % Assign contour
                    segments{segment_i} = FileTools.ImportSegment(full_path);

                    % iterate
                    segment_i = segment_i + 1;
                end%if

            end%for i

            part = Part(segments);
        end%func ImportPart

        function imported_segment = ImportSegment(segment_directory)
            % Get directory information
            dir_info = dir(segment_directory);
            n_files = length(dir_info);

            % Instantiate bonus iterator
            contour_i = 1;

            % Notice!
            fprintf('Segment Import - GOM Slices with default speed: %1.3f mm/s\n',FileTools.default_speed);

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

                    % Assign contour
                    contours{contour_i} = FileTools.ImportContour(full_path);

                    % iterate
                    contour_i = contour_i + 1;
                end%if

            end%for i

            imported_segment = Segment(contours);
        end%func ImportSegment

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

                    % Assign contour
                    contours{contour_i} = FileTools.ImportContour(full_path);

                    % iterate
                    contour_i = contour_i + 1;
                    n_files_read = n_files_read + 1;
                end

            end%for i

            %fprintf('%i files read\n',n_files_read);

        end%func ImportGOMPath

        function imported_contour = ImportContour(file_path)
            % Input: absolute path to contour file
            % Output: XYZ contour points

            raw_data = dlmread(file_path,' ',0,0);
            x = raw_data(:,1);
            y = raw_data(:,2);
            z = raw_data(:,3);

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

        end%func

        function PadFileNameZerosForPlaneOffset(filename_prefix,directory)
            % Pads filenames for the output from GOM's planar slice export
            % filename_prefix specifies to only pad files containing that substring
            working_dir = dir(directory);
            if(length(working_dir) == 0)
                fprintf('FileTools::PadFileNameZeros: Directory not found\n');
                return;
            end%if

            mm_delimiter = '+'; % 'Radial';
            end_delimiter = ' '; % 'degrees';
            mm_front_offset = 1; % 7 for radial
            mm_end_offset = 1; % 2 for radial

            % Find maximum order of magnitude
            mm_values = [];

            for i = 1:length(working_dir)
                filename = working_dir(i).name;
                if(contains(filename,filename_prefix))
                    mm_index = strfind(filename,mm_delimiter) + mm_front_offset;
                    end_number_index = strfind(filename(mm_index:end),end_delimiter) + mm_index - mm_end_offset;
                    value_string = filename(mm_index:end_number_index);
                    mm_values = [mm_values,str2num(value_string)];
                end%if
            end%for i

            max_mm_order = floor(log10(max(mm_values)));

            % Pad files
            for i = 1:length(working_dir)
                filename = working_dir(i).name;
                old_file_string = strcat(working_dir(i).folder,'\',filename);

                if(contains(filename,filename_prefix))
                    mm_index = strfind(filename,mm_delimiter) + mm_front_offset;
                    end_number_index = strfind(filename(mm_index:end),end_delimiter) + mm_index - mm_end_offset;
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

        function ReverseFileOrder(filename_prefix,directory)
            working_dir = dir(directory);
            if(length(working_dir) == 0)
                fprintf('FileTools::PadFileNameZeros: Directory not found\n');
                return;
            end%if

            file_numbers = [];

            for i = 1:length(working_dir)
                filename = working_dir(i).name;
                if(contains(filename,filename_prefix));
                    file_number_index = max(strfind(filename,' ')) + 1;
                    end_number_index = strfind(filename(file_number_index:end),'.') + file_number_index - 1;
                    file_numbers = [file_numbers,str2num(filename(file_number_index:end_number_index))];
                end%if
            end%for i
            % file_numbers is now in the order found in the directory

            max_file_number_order = floor(log10(max(file_numbers)));

            reversed_file_numbers = flip(file_numbers);
            j = 1;

            for i = 1:length(working_dir)
                filename = working_dir(i).name;
                old_file_string = strcat(working_dir(i).folder,'\',filename);

                if(contains(filename,filename_prefix))
                    file_number_index = max(strfind(filename,' ')) + 1;
                    end_number_index = strfind(filename(file_number_index:end),'.') + file_number_index - 1;

                    filename = strcat(filename(1:file_number_index - 1),{' '},num2str(reversed_file_numbers(j)),filename(end_number_index:end));
                    filename = filename{1};

                    file_number_order = floor(log10(reversed_file_numbers(j)));

                    if(file_number_order < 0)
                        file_number_order = 0;
                    end%if

                    while(file_number_order < max_file_number_order)
                        filename = strcat(filename(1:file_number_index-1),{' '},'0',filename(file_number_index:end));
                        filename = filename{1};
                        file_number_order = file_number_order + 1;
                    end%while

                    % move to temp to prevent overwrite
                    new_file_string = strcat(working_dir(i).folder,'\','temp',filename);

                    if(~strcmp(old_file_string,new_file_string))
                        movefile(old_file_string,new_file_string);
                    end%if
                    j = j + 1;
                end%if
            end%for i

            working_dir = dir(directory);
            j = 1;
            for i = 1:length(working_dir)
                filename = working_dir(i).name;
                old_file_string = strcat(working_dir(i).folder,'\',filename);
                if(contains(filename,filename_prefix))
                    filename = filename(5:end)
                    new_file_string = strcat(working_dir(i).folder,'\',filename);

                    if(~strcmp(old_file_string,new_file_string))
                        movefile(old_file_string,new_file_string);
                    end%if
                    j = j + 1;
                end%if
            end%for i
        end%func ReverseFileOrder

    end%Static Methods
end%class ContourTools