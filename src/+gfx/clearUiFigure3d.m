function hFig = clearUiFigure3d(hFig)
arguments
    hFig matlab.ui.Figure = gfx.currentUiFigure
end
gfx.clearUiFigure(hFig);
gfx.clearUiAxes3d(hFig);