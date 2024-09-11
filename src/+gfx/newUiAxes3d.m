function hAxes = newUiAxes3d(hParent)
arguments
    hParent = uifigure("HandleVisibility", "on");
end
hAxes = uiaxes(hParent);
gfx.clearUiAxes3d(hAxes);
