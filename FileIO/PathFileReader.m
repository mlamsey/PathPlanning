classdef PathFileReader
    properties(Constant)
        header_start_char = '!StartHeader!';
        header_end_char = '!EndHeader!';
        retract_move_char = 'R';
        linear_move_char = 'L';
        contour_move_char = 'C';
    end%properties
    methods(Static)
        function Read(absolute_file_path)
            full_text = fileread(absolute_file_path);
            header_beginnings = strfind(full_text,PathFileReader.header_start_char);
            n_headers = length(header_beginnings);
            
            for i = 1:n_headers - 1
                text_subset = full_text(header_beginnings(i):header_beginnings(i+1));
                header_data = PathFileReader.ParseHeader(text_subset);
            end%for i
            
        end%func Read
        
        function header_data = ParseHeader(header_text)
            header_data.op_id = 9;
            x = strfind(header_text,'\\n');
        end%func
    end%methods
end%class PathFileReader