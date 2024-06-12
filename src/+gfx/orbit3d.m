function orbit3d(hAxes)
%ORBIT3D Interactive axes for rotateable and editable 3d objects
%   gfx.orbit3d(hAxes);
%
%   USER INTERACTIONS
%     Left mouse click & move:  Rotate objects
%     Double click:             Set rotation center
%     Right click:              User defined callback
%     Scroll wheel:             Zoom towards to/away from mouse pointer
%     Key r:                    Reset view
%     Key t:                    Toggle transparency of selected obj
%     Key w:                    Toggle wireframe of selected patch
%     Key c:                    Toggle color of selected obj
%     Key h:                    Show help
%
%   USER DEFINED KEYBOARD SHORTCUTS
%     Keyboards shortcuts are defined in the userdata propery of the axes
%     Example: Turn off the shortcut 'h' for help
%
%        hAxes.UserData.orbit3d.keyboardShortcuts.Help = 'off';
%
%   REGISTERING ADDITIONAL EVENTS
%     For registering additional keyboard or mouse callbacks, you must
%     use gfx.FigureEventDispatcher() in order not to destroy Orbit3d's
%     callbacks
%
%     Example of adding a right mouse click callback on hAxes
%        gfx.FigureEventDispatcher.addAxesEvent(...
%          "WindowMousePress", @(~,~)disp('right mouse btn'), hAxes, @(f,~)f.SelectionType == "alt");
%
%     Example of adding a global keyboard shortcut on hFigure
%        gfx.FigureEventDispatcher.addFigureEvent(...
%          "KeyPress", @(~,evnt)disp(evnt.Key), hFigure);
%
%
%   NOTES
%     Instance of gfx.internal.Orbit3d is kept in hFigure.UserData.orbit3d
%     Orbit3d works for both the old java-based axes and the new web-based
%     uiaxes()
%
%   AUTHOR
%     Copyright 2022-2023, Markus Leuthold, markus.leuthold@sonova.com
%
%   LICENSE
%     BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)

hFig = ancestor(hAxes, 'figure');
gfx.FigureEventDispatcher.setupFigureCallbacks(hFig);
hAxes.UserData.orbit3d = gfx.internal.Orbit3d(hAxes);
