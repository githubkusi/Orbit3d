function orbit3d(hAxes)
    %ORBIT3D Interactive axes for rotateable and editable 3d objects
    %   gfx.orbit3d(hAxes);
    %   
    %   USER INTERACTIONS
    %     Right mouse click & move: Rotate objects
    %     Right double-click:       Set rotation center
    %     Left click:               User defined callback
    %     Scroll wheel:             Zoom towards to/away from mouse pointer
    %     Key r:                    Reset view
    %     Key t:                    Toggle transparency of selected obj
    %     Key w:                    Toggle wireframe of selected patch
    %     Key c:                    Toggle color of selected obj
    %     Key h:                    Show help   
    %
    %   USER DEFINED RIGHT-CLICK
    %     hFig.UserData.RightButtonDownFcn is called on right mouse down with
    %     hFig.CurrentObject as parameter
    %     hFig.UserData.RightButtonUpFcn is called on right mouse up with
    %     hFig.CurrentObject as parameter
    %
    %   NOTES
    %     Instance of gfx.internal.Orbit3d is kept in hFigure.UserData.orbit3d
    %     Orbit3d works for both the old java-based axes and the new web-based 
    %     uiaxes()
    %
    %   AUTHOR
    %     Copyright 2022, Markus Leuthold, markus.leuthold@sonova.com
    %
    %   LICENSE
    %     BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)
    
hFig = ancestor(hAxes, 'figure');
if ~isfield(hFig.UserData, 'FigureEventDispatcher')
    hFig.UserData.FigureEventDispatcher = gfx.FigureEventDispatcher(hFig);
end

hAxes.UserData.orbit3d = gfx.internal.Orbit3d(hAxes, hFig.UserData.FigureEventDispatcher);
