function hFig = clearUiFigure(hFig)
arguments
    hFig matlab.ui.Figure = gfx.currentUiFigure
end
clf(hFig);
hFig.UserData = [];
hFig.HandleVisibility = "on";