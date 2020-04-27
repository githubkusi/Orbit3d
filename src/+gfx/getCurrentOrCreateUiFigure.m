function hFig = getCurrentOrCreateUiFigure
hRoot = groot;
if isempty(hRoot.CurrentFigure)
    hFig = uifigure("HandleVisibility", "on");
else
    hFig = hRoot.CurrentFigure;
end
