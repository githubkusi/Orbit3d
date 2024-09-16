function hAxes = newUiAxes3d(hParent)
arguments
    hParent = uifigure("HandleVisibility", "on");
end
hAxes = uiaxes(hParent, ...
    Units="normalized",...
    Position=[0.1300 0.1100 0.7750 0.8150]);
gfx.clearUiAxes3d(hAxes);
