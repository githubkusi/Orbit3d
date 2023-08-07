function hFig = clearUiFigure(hFig)
arguments
    hFig = gfx.currentUiFigure
end
clf(hFig);
hFig.UserData = [];