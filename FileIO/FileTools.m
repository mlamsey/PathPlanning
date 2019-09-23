classdef FileTools
    properties(Constant)
        default_speed = 6.418;
    end%properties

    methods(Static)
        function part = PromptForPartImportFromGOM
            msg = questdlg('Please select a folder containing slices from GOM','SliceManipulator INFO','OK','OK');
            directory = uigetdir;
            if(~directory)
                fprintf('FileTools::PromptForPartImportFromGOM: No directory selected!\n');
                part = 0;
            else
                part = FileTools.ImportSliceSetFromGOM(directory);
            end%if

        end%func PromptForPartImportFromGOM

        function part = ImportSliceSetFromGOM(file_path)
            part = Part({Segment(FileTools.importGOMPath(file_path))});
        end%func ImportSliceSetFromGOM

        function slices = importGOMPath(directory_path)
            % Input: absolute path to the directory to import
            % Output: 1D array of [x,y,z] lists (n x 3 double)

            % Get directory information
            dir_info = dir(directory_path);
            n_files = length(dir_info);
            %fprintf('%i files found\n',n_files);

            % Instantiate bonus iterators
            n_files_read = 0;
            slice_i = 1;

            % Notice!
            fprintf('GOM Import with default speed: %1.3f mm/s\n',FileTools.default_speed);

            % Loop through all files
            for i = 1:n_files
                file_name = dir_info(i).name;

                % check if filenames are NOT navigation targets
                if(~strcmp(file_name,'.') && ~strcmp(file_name,'..'))
                    % Generate path, import slice data, assign slice in set
                    full_path = strcat(dir_info(i).folder,'\',file_name);
                    [positions,orientations] = FileTools.importSlice(full_path);

                    % Spoof speed
                    speeds = cell(length(positions),1);
                    for j = 1:length(positions)
                        speeds{j} = FileTools.default_speed;
                    end%for i

                    % Assign slice
                    slices{slice_i} = Slice(positions,orientations,speeds);

                    % iterate
                    slice_i = slice_i + 1;
                    n_files_read = n_files_read + 1;
                end

            end%for i

            %fprintf('%i files read\n',n_files_read);

        end%func importGOMPath

        function [positions,orientations] = importSlice(file_path)
            % Input: absolute path to slice file
            % Output: XYZ slice points

            raw_data = dlmread(file_path,' ',1,1);
            x = raw_data(:,1);
            y = raw_data(:,2);
            z = raw_data(:,3);
            a = raw_data(:,4);
            b = raw_data(:,5);
            c = raw_data(:,6);

            positions = cell(length(x),1);
            orientations = positions;

            for i = 1:length(positions)
                positions{i} = [x(i),y(i),z(i)];
                orientations{i} = [a(i),b(i),c(i)];
            end%for i

        end%func

    end%Static Methods
end%class SliceTools