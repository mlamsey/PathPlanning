classdef PopoutFigure < handle 
    properties 
        parent_figure; 
        value; 
    end%properties 
  
    methods 
        function obj = PopoutFigure() 
            obj.parent_figure = PopoutFigure.Build(obj); 
        end%func Constructor 
    end%methods 
  
    methods(Static, Access = 'private') 
        function figure_ref = Build(obj) 
            % Constructs the figure and relevant uicontrol features 
            f = figure('position',[800,100,200,100]); 
            edit_value = uicontrol('parent',f,'style','edit',... 
                'units','normalized','position',[0.25,0.6,0.5,0.3]); 
  
            btn_set = uicontrol('parent',f,'style','pushbutton',... 
                'units','normalized','position',[0.25,0.1,0.5,0.3],'string','Set Value','callback',{@PopoutFigure.SetValue, obj, edit_value}); 
             
            % Assign return value 
            figure_ref = f; 
        end%func Build 

        function SetValue(source, eventdata, obj, edit_value) 
            % obj is the parent PopoutFigure handle 
            % edit_value is the uicontrol element that contains the editable value 
            value = str2double(edit_value.String); 
            obj.value = value; 
            
            % close the parent figure - this is not strictly necessary, but it works well with uiwait(). 
            close(obj.parent_figure); 
        end%func SetValue 
    end%static methods 
end 
