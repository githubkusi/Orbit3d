function hFig = clearUiFigure3d(hFig)
arguments
    hFig = gfx.currentUiFigure
end
clf(hFig);
hFig.UserData = [];
gfx.clearUiAxes3d(hFig);