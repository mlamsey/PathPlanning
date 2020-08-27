classdef LogFileWriter    
    methods(Static)        
        function WriteLog(log_file_path,path_file_path,log_string,build_string,part)
            if(~isa(part,'Part'))
                fprintf('PathFileWrite::WritePart: Input 4 not a part\n');
                return;
            end%if
            
            date_time = datetime('now','TimeZone','local','Format','MM/dd/yyyy, HH:mm:ss');
            
            file_id = fopen(log_file_path,'wt');
            format_spec = '%s\n';
            
            fprintf(file_id,format_spec,date_time);
            fprintf(file_id,'Export Path: %s\n\n',path_file_path);
            
            fprintf(file_id,format_spec,'Manifest Data:');
            fprintf(file_id,'|%d',part.segment_manifest{:});
            fprintf(file_id,'|',' ');
            fprintf(file_id,'%s\n\n',' ');
            
            fprintf(file_id,format_spec,'Build Stats:');
            fprintf(file_id,format_spec,build_string);
            
            fprintf(file_id,format_spec,' ');
            
            fprintf(file_id,format_spec,'Log Data:');
            fprintf(file_id,format_spec,log_string{:});
            
            fclose('all');
            
        end%func
    end%methods
end%class LogFileWriter

