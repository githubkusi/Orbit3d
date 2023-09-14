function hFig = currentUiFigure
hRoot = groot;
hFig = hRoot.CurrentFigure;
if isempty(hFig) || hFig.Tag == "browser"
    hFig = uifigure("HandleVisibility", "on");
else
    hFig = hRoot.CurrentFigure;
end
