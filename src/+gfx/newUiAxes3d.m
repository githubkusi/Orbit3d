function hAxes = newUiAxes3d(hParent)
% NEWUIAXES3D Create new uiaxes with enabled 3d orbit
%
% EXAMPLE multiple axes
%     hFig = gfx.clearUiFigure;
%     hGrid = uigridlayout(hFig, [2 1]);
%     ax1 = gfx.newUiAxes3d(hGrid);
%     ax2 = gfx.newUiAxes3d(hGrid);
%     obj1.plot('parent', ax1);
%     obj2.plot('parent', ax1);

arguments
    hParent = uifigure("HandleVisibility", "on");
end
hAxes = uiaxes(hParent, ...
    Units="normalized",...
    Position=[0.1300 0.1100 0.7750 0.8150]);
gfx.clearUiAxes3d(hAxes);
